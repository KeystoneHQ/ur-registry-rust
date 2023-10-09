import 'dart:ffi';
import 'package:ur_registry_flutter/native_object.dart';

import '../response.dart';

const nativePrefix = "crypto_hd_key";

typedef NativeGetKeyData = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetAccountIndex = Pointer<Response> Function(
    Pointer<Void>, Uint32);
typedef FNGetAccountIndex = Pointer<Response> Function(Pointer<Void>, int);
typedef NativeGetSourceFingerprint = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetName = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetPath = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetChildrenPath = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetDepth = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetChainCode = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetBip32Xpub = Pointer<Response> Function(Pointer<Void>);

class CryptoHDKey extends NativeObject {
  CryptoHDKey(Pointer<Void> object) : super() {
    nativeObject = object;
  }

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
  late NativeGetChildrenPath nativeGetChildrenPath = lib
      .lookup<NativeFunction<NativeGetChildrenPath>>(
          "${nativePrefix}_get_children_path")
      .asFunction();
  late NativeGetDepth nativeGetDepth = lib
      .lookup<NativeFunction<NativeGetDepth>>("${nativePrefix}_get_depth")
      .asFunction();
  late NativeGetChainCode nativeGetChainCode = lib
      .lookup<NativeFunction<NativeGetChainCode>>(
          "${nativePrefix}_get_chain_code")
      .asFunction();

  late NativeGetBip32Xpub nativeGetBip32Xpub = lib
      .lookup<NativeFunction<NativeGetBip32Xpub>>(
          "${nativePrefix}_get_bip32_xpub")
      .asFunction();

  String getKeyData() {
    final response = nativeGetKeyData(nativeObject).ref;
    return response.getString();
  }

  int getAccountIndex(int level) {
    final response = fnGetAccountIndex(nativeObject, level).ref;
    return response.getUint32();
  }

  String getName() {
    final response = nativeGetName(nativeObject).ref;
    return response.getString();
  }

  String getPath() {
    final response = nativeGetPath(nativeObject).ref;
    return response.getString();
  }

  String? getChildrenPath() {
    try {
      final response = nativeGetChildrenPath(nativeObject).ref;
      return response.getString();
    } catch (e) {
      return null;
    }
  }

  String getSourceFingerprint() {
    final response = nativeGetSourceFingerprint(nativeObject).ref;
    return response.getString();
  }

  int getDepth() {
    final response = nativeGetDepth(nativeObject).ref;
    return response.getUint32();
  }

  String? getChainCode() {
    try {
      return nativeGetChainCode(nativeObject).ref.getString();
    } catch (e) {
      return null;
    }
  }

  String getBip32Xpub() {
    return nativeGetBip32Xpub(nativeObject).ref.getString();
  }
}
