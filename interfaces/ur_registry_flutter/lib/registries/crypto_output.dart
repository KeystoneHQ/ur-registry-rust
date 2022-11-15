import 'dart:ffi';

import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';

import '../response.dart';

const nativePrefix = "crypto_account";

typedef NativeGetKey = Pointer<Response> Function(Pointer<Void>);

class CryptoOutput extends NativeObject {
  CryptoOutput(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  late NativeGetKey nativeGetKey = lib
      .lookup<NativeFunction<NativeGetKey>>("${nativePrefix}_get_hd_key")
      .asFunction();

  CryptoHDKey getKey() {
    final response = nativeGetKey(nativeObject).ref;
    return CryptoHDKey(response.getObject());
  }
}
