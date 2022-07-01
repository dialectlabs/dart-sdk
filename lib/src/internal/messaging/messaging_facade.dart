import 'package:async/async.dart';
import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';

class MessagingBackend {
  Messaging messaging;
  Backend backend;
  MessagingBackend(this.messaging, this.backend);
}

class MessagingFacade implements Messaging {
  final List<MessagingBackend> messagingBackends;

  MessagingFacade(this.messagingBackends) {
    if (messagingBackends.isEmpty) {
      throw IllegalArgumentError(
          title: 'Expected to have at lease one messaging backend.');
    }
  }

  @override
  Future<Thread> create(CreateThreadCommand command) {
    final messagingBackend = _getPreferableMessaging(command.backend);
    return messagingBackend.messaging.create(command);
  }

  @override
  Future<Thread?> find(FindThreadQuery query) async {
    if (query is FindThreadByIdQuery && query.id.backend != null) {
      final messagingBackend = _lookUpMessagingBackend(query.id.backend!);
      return messagingBackend.messaging.find(query);
    }
    for (var messagingBackend in messagingBackends) {
      try {
        final thread = await messagingBackend.messaging.find(query);
        if (thread != null) {
          return thread;
        }
      } catch (e) {
        print(e);
      }
    }
    return null;
  }

  @override
  Future<List<Thread>> findAll() async {
    final allSettled = await Future.wait(
        messagingBackends.map((e) => Result.capture(e.messaging.findAll())));
    final fulfilled = allSettled
        .where((element) => element.isValue)
        .map((e) => e.asValue!.value);
    final failed = allSettled
        .where((element) => element.isError)
        .map((e) => e.asError!.error.toString());
    if (failed.isNotEmpty) {
      print("Error findind dialects: ${failed.map((e) => e)}");
    }
    var flatThreads = fulfilled.expand((element) => element).toList();
    flatThreads.sort((a, b) =>
        b.updatedAt.millisecondsSinceEpoch -
        a.updatedAt.millisecondsSinceEpoch);
    return flatThreads;
  }

  MessagingBackend _getFirstAccordingToPriority() {
    if (messagingBackends.isEmpty) {
      throw IllegalStateError(title: "SDK requires a backend");
    }
    return messagingBackends.first;
  }

  MessagingBackend _getPreferableMessaging(Backend? backend) {
    if (backend != null) {
      return _lookUpMessagingBackend(backend);
    }
    return _getFirstAccordingToPriority();
  }

  MessagingBackend _lookUpMessagingBackend(Backend backend) {
    final messagingBackend = messagingBackends
        .where((element) => element.backend.index == backend.index);
    if (messagingBackend.isEmpty) {
      throw IllegalArgumentError(
          title: "Backend $backend is not configured in sdk");
    }
    return messagingBackend.first;
  }
}
