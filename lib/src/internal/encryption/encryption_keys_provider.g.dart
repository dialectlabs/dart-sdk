// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'encryption_keys_provider.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiffieHellmanKeys _$DiffieHellmanKeysFromJson(Map<String, dynamic> json) =>
    DiffieHellmanKeys(
      publicKey:
          const Uint8ListConverter().fromJson(json['publicKey'] as List<int>),
      secretKey:
          const Uint8ListConverter().fromJson(json['secretKey'] as List<int>),
    );

Map<String, dynamic> _$DiffieHellmanKeysToJson(DiffieHellmanKeys instance) =>
    <String, dynamic>{
      'publicKey': const Uint8ListConverter().toJson(instance.publicKey),
      'secretKey': const Uint8ListConverter().toJson(instance.secretKey),
    };
