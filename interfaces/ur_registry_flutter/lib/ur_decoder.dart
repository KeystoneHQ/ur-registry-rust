import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/base.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/crypto_account.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/registries/crypto_psbt.dart';
import 'package:ur_registry_flutter/registries/ethereum/eth_sign_request.dart';
import 'package:ur_registry_flutter/registries/ethereum/eth_signature.dart';
import 'package:ur_registry_flutter/registries/extend/crypto_multi_accounts.dart';
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
  cryptoHDKey,
  cryptoAccount,
  cryptoPSBT,
  cryptoMultiAccounts,
  solSignRequest,
  solSignature,
  ethSignRequest,
  ethSignature,
}

const _cryptoHDKey = 'crypto-hdkey';
const _cryptoAccount = 'crypto-account';
const _cryptoPSBT = 'crypto-psbt';
const _cryptoMultiAccounts = 'crypto-multi-accounts';
const _solSignRequest = 'sol-sign-request';
const _solSignature = 'sol-signature';
const _ethSignRequest = 'eth-sign-request';
const _ethSignature = 'eth-signature';

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
    decoder = response.getObject();
  }

  void receive(String ur) {
    final response = nativeReceive(decoder, ur.toNativeUtf8()).ref;
    response.throwIfPresent();
  }

  bool isComplete() {
    final response = nativeIsComplete(decoder).ref;
    return response.getBoolean();
  }

  String result() {
    final response = nativeResult(decoder).ref;
    return response.getString();
  }

  NativeObject resolve(SupportedType type) {
    switch (type) {
      case SupportedType.cryptoHDKey:
        final response =
            nativeResolve(decoder, _cryptoHDKey.toNativeUtf8()).ref;
        return CryptoHDKey(response.getObject());
      case SupportedType.cryptoAccount:
        final response =
            nativeResolve(decoder, _cryptoAccount.toNativeUtf8()).ref;
        return CryptoAccount(response.getObject());
      case SupportedType.cryptoPSBT:
        final response = nativeResolve(decoder, _cryptoPSBT.toNativeUtf8()).ref;
        return CryptoPSBT(response.getObject());
      case SupportedType.cryptoMultiAccounts:
        final response =
            nativeResolve(decoder, _cryptoMultiAccounts.toNativeUtf8()).ref;
        return CryptoMultiAccounts(response.getObject());
      case SupportedType.solSignRequest:
        final response =
            nativeResolve(decoder, _solSignRequest.toNativeUtf8()).ref;
        return SolSignRequest(response.getObject());
      case SupportedType.solSignature:
        final response =
            nativeResolve(decoder, _solSignature.toNativeUtf8()).ref;
        return SolSignature(response.getObject());
      case SupportedType.ethSignRequest:
        final response =
            nativeResolve(decoder, _ethSignRequest.toNativeUtf8()).ref;
        return EthSignRequest(response.getObject());
      case SupportedType.ethSignature:
        final response =
            nativeResolve(decoder, _ethSignature.toNativeUtf8()).ref;
        return EthSignature(response.getObject());
      default:
        throw Exception("type $type is not supported");
    }
  }
}
