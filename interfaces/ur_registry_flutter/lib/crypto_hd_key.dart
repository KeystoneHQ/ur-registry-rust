import 'dart:ffi';
import 'package:ur_registry_flutter/native_object.dart';

import 'response.dart';

const nativePrefix = "crypto_hd_key";

typedef NativeGetKeyData = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetAccountIndex = Pointer<Response> Function(Pointer<Void>, Uint32);
typedef FNGetAccountIndex = Pointer<Response> Function(Pointer<Void>, int);
typedef NativeGetSourceFingerprint = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetName = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetPath = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetDepth = Pointer<Response> Function(Pointer<Void>);

class CryptoHDKey extends NativeObject {
  CryptoHDKey(Pointer<Void> object) : super(object);

  late NativeGetKeyData nativeGetKeyData = lib
      .lookup<NativeFunction<NativeGetKeyData>>("${nativePrefix}_get_key_data")
      .asFunction();
  late FNGetAccountIndex fnGetAccountIndex = lib
      .lookup<NativeFunction<NativeGetAccountIndex>>(
          "${nativePrefix}_get_account_index")
      .asFunction<FNGetAccountIndex>();
  late NativeGetSourceFingerprint nativeGetSourceFingerprint = lib
      .lookup<NativeFunction<NativeGetSourceFingerprint>>(
          "${nativePrefix}_get_source_fingerprint")
      .asFunction();
  late NativeGetName nativeGetName = lib
      .lookup<NativeFunction<NativeGetName>>("${nativePrefix}_get_name")
      .asFunction();
  late NativeGetPath nativeGetPath = lib
      .lookup<NativeFunction<NativeGetPath>>("${nativePrefix}_get_path")
      .asFunction();
  late NativeGetDepth nativeGetDepth = lib
      .lookup<NativeFunction<NativeGetDepth>>("${nativePrefix}_get_depth")
      .asFunction();

  String getKeyData() {
    final response = nativeGetKeyData(nativeObject).ref;
    response.throwIfPresent();
    return response.data.getString();
  }

  int? getAccountIndex(int level) {
    final response = fnGetAccountIndex(nativeObject, level).ref;
    response.throwIfPresent();
    print("getAccountIndex, ${response.data}");
    print("getAccountIndex, ${response.data.isNull()}");
    if (response.data.isNull()) return null;
    return response.data.getUInt32();
  }

  String? getName() {
    final response = nativeGetName(nativeObject).ref;
    response.throwIfPresent();
    if (response.data.isNull()) return null;
    return response.data.getString();
  }

  String? getPath() {
    final response = nativeGetPath(nativeObject).ref;
    response.throwIfPresent();
    if (response.data.isNull()) return null;
    return response.data.getString();
  }

  String? getSourceFingerprint() {
    final response = nativeGetSourceFingerprint(nativeObject).ref;
    response.throwIfPresent();
    if (response.data.isNull()) return null;
    return response.data.getString();
  }

  int? getDepth() {
    final response = nativeGetDepth(nativeObject).ref;
    response.throwIfPresent();
    if (response.data.isNull()) return null;
    return response.data.getUInt32();
  }
}
