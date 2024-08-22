import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/cardano/cardano_signature.dart';
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
  // sol
  solSignRequest,
  solSignature,
  // eth
  ethSignRequest,
  ethSignature,
  // cardano
  cardanoUTXO,
  cardanoSignRequest,
  cardanoSignature,
  cardanoCertKey,
  cardanoSignDataRequest,
  cardanoSignDataSignature,
  cardanoCatalystVotingRegistration,
  cardanoCatalystVotingRegistrationSignature,
}

const _cryptoHDKey = 'crypto-hdkey';
const _cryptoAccount = 'crypto-account';
const _cryptoPSBT = 'crypto-psbt';
const _cryptoMultiAccounts = 'crypto-multi-accounts';
const _solSignRequest = 'sol-sign-request';
const _solSignature = 'sol-signature';
const _ethSignRequest = 'eth-sign-request';
const _ethSignature = 'eth-signature';

const _cardanoUTXO = 'cardano-utxo';
const _cardanoSignRequest = 'cardano-sign-request';
const _cardanoSignature = 'cardano-signature';
const _cardanoCertKey = 'cardano-cert-key';
const _cardanoSignDataRequest = 'cardano-sign-data-request';
const _cardanoSignDataSignature = 'cardano-sign-data-signature';
const _cardanoCatalystVotingRegistration = 'cardano-catalyst-voting-registration';
const _cardanoCatalystVotingRegistrationSignature = 'cardano-catalyst-voting-registration-signature';

class URDecoder extends NativeObject {
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

  URDecoder() : super() {
    final response = nativeNew().ref;
    nativeObject = response.getObject();
  }

  void receive(String ur) {
    final response = nativeReceive(nativeObject, ur.toNativeUtf8()).ref;
    response.throwIfPresent();
  }

  bool isComplete() {
    final response = nativeIsComplete(nativeObject).ref;
    return response.getBoolean();
  }

  String result() {
    final response = nativeResult(nativeObject).ref;
    return response.getString();
  }

  NativeObject resolve(SupportedType type) {
    switch (type) {
      case SupportedType.cryptoHDKey:
        final response =
            nativeResolve(nativeObject, _cryptoHDKey.toNativeUtf8()).ref;
        return CryptoHDKey(response.getObject());
      case SupportedType.cryptoAccount:
        final response =
            nativeResolve(nativeObject, _cryptoAccount.toNativeUtf8()).ref;
        return CryptoAccount(response.getObject());
      case SupportedType.cryptoPSBT:
        final response = nativeResolve(nativeObject, _cryptoPSBT.toNativeUtf8()).ref;
        return CryptoPSBT(response.getObject());
      case SupportedType.cryptoMultiAccounts:
        final response =
            nativeResolve(nativeObject, _cryptoMultiAccounts.toNativeUtf8()).ref;
        return CryptoMultiAccounts(response.getObject());
      // sol
      case SupportedType.solSignRequest:
        final response =
            nativeResolve(nativeObject, _solSignRequest.toNativeUtf8()).ref;
        return SolSignRequest(response.getObject());
      case SupportedType.solSignature:
        final response =
            nativeResolve(nativeObject, _solSignature.toNativeUtf8()).ref;
        return SolSignature(response.getObject());
      // eth
      case SupportedType.ethSignRequest:
        final response =
            nativeResolve(nativeObject, _ethSignRequest.toNativeUtf8()).ref;
        return EthSignRequest(response.getObject());
      case SupportedType.ethSignature:
        final response =
            nativeResolve(nativeObject, _ethSignature.toNativeUtf8()).ref;
        return EthSignature(response.getObject());
      // cardano
      // case SupportedType.cardanoUTXO:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoUTXO.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      // case SupportedType.cardanoSignRequest:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoSignRequest.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      case SupportedType.cardanoSignature:
        final response =
            nativeResolve(nativeObject, _cardanoSignature.toNativeUtf8()).ref;
        return CardanoSignature(response.getObject());
      // case SupportedType.cardanoCertKey:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoCertKey.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      // case SupportedType.cardanoSignDataRequest:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoSignDataRequest.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      // case SupportedType.cardanoSignDataSignature:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoSignDataSignature.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      // case SupportedType.cardanoCatalystVotingRegistration:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoCatalystVotingRegistration.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      // case SupportedType.cardanoCatalystVotingRegistrationSignature:
      //   final response =
      //       nativeResolve(nativeObject, _cardanoCatalystVotingRegistrationSignature.toNativeUtf8()).ref;
      //   return CryptoAccount(response.getObject());
      default:
        throw Exception("type $type is not supported");
    }
  }
}
