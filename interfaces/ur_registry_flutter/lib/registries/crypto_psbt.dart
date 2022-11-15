import 'dart:ffi';

import 'package:convert/convert.dart';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';

import '../ur_encoder.dart';

const nativePrefix = "crypto_psbt";

typedef NativeGetData = Pointer<Response> Function(Pointer<Void>);
typedef NativeConstruct = Pointer<Response> Function(Pointer<Utf8>);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

class CryptoPSBT extends NativeObject {
  CryptoPSBT(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  late NativeGetData nativeGetData = lib
      .lookup<NativeFunction<NativeGetData>>("${nativePrefix}_get_data")
      .asFunction();

  late NativeConstruct nativeConstruct = lib
      .lookup<NativeFunction<NativeConstruct>>("${nativePrefix}_construct")
      .asFunction();

  late NativeGetUREncoder nativeGetUREncoder = lib
      .lookup<NativeFunction<NativeGetUREncoder>>(
          "${nativePrefix}_get_ur_encoder")
      .asFunction();

  CryptoPSBT.factory(List<int> psbt) : super() {
    final psbtStr = hex.encode(psbt);
    final response = nativeConstruct(psbtStr.toNativeUtf8()).ref;
    nativeObject = response.getObject();
  }

  UREncoder toUREncoder() {
    final response = nativeGetUREncoder(nativeObject).ref;
    return UREncoder(response.getObject());
  }

  String getData() {
    final response = nativeGetData(nativeObject).ref;
    return response.getString();
  }
}
