import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/base.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/solana/crypto_multi_accounts.dart';
import 'package:ur_registry_flutter/registries/solana/sol_signature.dart';
import 'package:ur_registry_flutter/response.dart';

import 'registries/solana/sol_sign_request.dart';

const nativePrefix = "ur_decoder";

typedef NativeNew = Pointer<Response> Function();
typedef NativeReceive = Pointer<Response> Function(
    Pointer<Void>, Pointer<Utf8>);
typedef NativeResult = Pointer<Response> Function(Pointer<Void>);
typedef NativeIsComplete = Pointer<Response> Function(Pointer<Void>);
typedef NativeResolve = Pointer<Response> Function(
    Pointer<Void>, Pointer<Utf8>);

enum SupportedType {
  cryptoMultiAccounts,
  solSignRequest,
  solSignature,
}

const _cryptoMultiAccounts = 'crypto-multi-accounts';
const _solSignRequest = 'sol-sign-request';
const _solSignature = 'sol-signature';

class URDecoder extends Base {
  late NativeNew nativeNew =
      lib.lookup<NativeFunction<NativeNew>>("${nativePrefix}_new").asFunction();
  late NativeReceive nativeReceive = lib
      .lookup<NativeFunction<NativeReceive>>("${nativePrefix}_receive")
      .asFunction();
  late NativeIsComplete nativeIsComplete = lib
      .lookup<NativeFunction<NativeIsComplete>>("${nativePrefix}_is_complete")
      .asFunction();
  late NativeResult nativeResult = lib
      .lookup<NativeFunction<NativeResult>>("${nativePrefix}_result")
      .asFunction();
  late NativeResolve nativeResolve = lib
      .lookup<NativeFunction<NativeResolve>>("${nativePrefix}_resolve")
      .asFunction();

  late Pointer<Void> decoder;

  URDecoder() {
    final response = nativeNew().ref;
    response.throwIfPresent();
    decoder = response.data.getObject();
  }

  void receive(String ur) {
    final response = nativeReceive(decoder, ur.toNativeUtf8()).ref;
    response.throwIfPresent();
  }

  bool isComplete() {
    final response = nativeIsComplete(decoder).ref;
    response.throwIfPresent();
    return response.data.getBoolean();
  }

  String result() {
    final response = nativeResult(decoder).ref;
    response.throwIfPresent();
    final resultStr = response.data.getString();
    return resultStr;
  }

  NativeObject resolve(SupportedType type) {
    switch (type) {
      case SupportedType.cryptoMultiAccounts:
        final response = nativeResolve(decoder, _cryptoMultiAccounts.toNativeUtf8()).ref;
        return CryptoMultiAccounts(response.getObject());
      case SupportedType.solSignRequest:
        final response = nativeResolve(decoder, _solSignRequest.toNativeUtf8()).ref;
        return SolSignRequest(response.getObject());
      case SupportedType.solSignature:
        final response = nativeResolve(decoder, _solSignature.toNativeUtf8()).ref;
        return SolSignature(response.getObject());
      default: throw Exception("type $type is not supported");
    }
  }
}
