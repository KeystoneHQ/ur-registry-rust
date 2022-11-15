import 'dart:ffi';

import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/registries/crypto_output.dart';

import '../response.dart';

const nativePrefix = "crypto_account";

typedef NativeGetLength = Pointer<Response> Function(Pointer<Void>);

typedef NativeGetAccount = Pointer<Response> Function(Pointer<Void>, Uint32);
typedef FNGetAccount = Pointer<Response> Function(Pointer<Void>, int);

typedef NativeGetMasterFingerprint = Pointer<Response> Function(Pointer<Void>);

class CryptoAccount extends NativeObject {
  CryptoAccount(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  late NativeGetLength nativeGetLength = lib
      .lookup<NativeFunction<NativeGetLength>>(
          "${nativePrefix}_get_accounts_len")
      .asFunction();

  late FNGetAccount getAccount = lib
      .lookup<NativeFunction<NativeGetAccount>>("${nativePrefix}_get_account")
      .asFunction<FNGetAccount>();

  late NativeGetMasterFingerprint nativeGetMasterFingerprint = lib
      .lookup<NativeFunction<NativeGetMasterFingerprint>>(
          "${nativePrefix}_get_master_fingerprint")
      .asFunction();

  String getMasterFingerprint() {
    final response = nativeGetMasterFingerprint(nativeObject).ref;
    return response.getString();
  }

  List<CryptoHDKey> getKeys() {
    Response response = nativeGetLength(nativeObject).ref;
    final length = response.getUint32();
    List<CryptoHDKey> cryptoHDKeys = [];
    for (int i = 0; i < length; i++) {
      response = getAccount(nativeObject, i).ref;
      cryptoHDKeys.add(CryptoOutput(response.getObject()).getKey());
    }
    return cryptoHDKeys;
  }
}
