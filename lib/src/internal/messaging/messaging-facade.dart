import 'package:dialect_sdk/src/messaging/messaging.interface.dart';
import 'package:dialect_sdk/src/sdk/errors.dart';

class MessagingFacade implements Messaging {
  final List<Messaging> messagingBackends;

  MessagingFacade(this.messagingBackends) {
    if (messagingBackends.isEmpty) {
      throw IllegalArgumentError(
          title: 'Expected to have at lease one messaging backend.');
    }
  }

  @override
  Future<Thread> create(CreateThreadCommand command) {
    final messaging = _getPreferableMessaging();
    return messaging.create(command);
  }

  @override
  Future<Thread?> find(FindThreadQuery query) async {
    for (var messaging in messagingBackends) {
      final thread = await messaging.find(query);
      if (thread != null) {
        return thread;
      }
    }
    return null;
  }

  @override
  Future<List<Thread>> findAll() async {
    List<List<Thread>> threads = [];
    List<String> errors = [];
    for (var backend in messagingBackends) {
      try {
        var result = await backend.findAll();
        threads.add(result);
      } catch (e) {
        errors.add(e.toString());
      }
    }
    if (errors.isNotEmpty) {
      print("Error finding dialects $errors");
    }
    var flatThreads = threads.expand((element) => element).toList();
    flatThreads.sort((a, b) =>
        b.updatedAt.millisecondsSinceEpoch -
        a.updatedAt.millisecondsSinceEpoch);
    return flatThreads;
  }

  Messaging _getPreferableMessaging() {
    try {
      final messaging = messagingBackends.first;
      return messaging;
    } catch (e) {
      throw IllegalStateError(title: 'Should not happen.');
    }
  }
}
