import 'dart:ffi';
import 'package:ur_registry_flutter/native_object.dart';

import 'response.dart';

const nativePrefix = "crypto_hd_key";

typedef NativeGetKeyData = Pointer<Response> Function(Pointer<Void>);

class CryptoHDKey extends NativeObject {
  CryptoHDKey(Pointer<Void> object) : super(object);

  late NativeGetKeyData nativeGetKeyData = lib.lookup<NativeFunction<NativeGetKeyData>>("${nativePrefix}_get_key_data").asFunction();

  String getKeyData() {
    final response = nativeGetKeyData(nativeObject).ref;
    response.throwIfPresent();
    return response.data.getString();
  }
}