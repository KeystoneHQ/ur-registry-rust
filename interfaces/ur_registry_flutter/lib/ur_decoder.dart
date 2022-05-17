import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/response.dart';

import 'package:ur_registry_flutter/ur_registry_flutter.dart';

typedef NativeNew = Pointer<Response> Function();
typedef NativeReceive = Pointer<Response> Function(
    Pointer<Void>, Pointer<Utf8>);
typedef NativeResult = Pointer<Response> Function(Pointer<Void>);
typedef NativeIsComplete = Pointer<Response> Function(Pointer<Void>);

class URDecoder {
  DynamicLibrary lib = UrRegistryFlutter.load();
  late NativeNew nativeNew =
      lib.lookup<NativeFunction<NativeNew>>("ur_decoder_new").asFunction();
  late NativeReceive nativeReceive = lib
      .lookup<NativeFunction<NativeReceive>>("ur_decoder_receive")
      .asFunction();
  late NativeIsComplete nativeIsComplete = lib
      .lookup<NativeFunction<NativeIsComplete>>("ur_decoder_is_complete")
      .asFunction();
  late NativeResult nativeResult = lib
      .lookup<NativeFunction<NativeResult>>("ur_decoder_result")
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
}
