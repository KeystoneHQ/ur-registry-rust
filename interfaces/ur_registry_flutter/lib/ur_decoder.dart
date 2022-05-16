import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/response.dart';

import 'package:ur_registry_flutter/ur_registry_flutter.dart';

typedef NativeNew = Pointer<Response> Function();
typedef NativeReceive = Pointer<Void> Function(
    Pointer<Void>, Pointer<Utf8>, Pointer<NativeFunction<ErrorCallback>>);
typedef NativeResult = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<NativeFunction<ErrorCallback>>);
typedef NativeIsComplete = Pointer<Bool> Function(Pointer<Void>);
typedef NativeText = Pointer<Utf8> Function();
typedef NativeU32 = Pointer<Uint32> Function();

typedef ErrorCallback = Handle Function(Pointer<Utf8>);

class URDecoder {
  DynamicLibrary lib = UrRegistryFlutter.load();
  late NativeNew nativeNew = lib.lookup<NativeFunction<NativeNew>>("ur_decoder_new").asFunction();
  late NativeReceive nativeReceive = lib.lookup<NativeFunction<NativeReceive>>("ur_decoder_receive").asFunction();
  late NativeIsComplete nativeIsComplete = lib.lookup<NativeFunction<NativeIsComplete>>("ur_decoder_is_complete").asFunction();
  late NativeResult nativeResult = lib.lookup<NativeFunction<NativeResult>>("ur_decoder_result").asFunction();

  late Pointer<Void> decoder;

  URDecoder() {
    final response = nativeNew().ref;
    decoder = response.data;
  }

  static void handleError(Pointer<Utf8> error) {
    print(error.toDartString());
  }

  void receive(String ur) {
    nativeReceive(
        decoder,
        ur.toNativeUtf8(),
        Pointer.fromFunction<ErrorCallback>(handleError));
  }

  bool isComplete() {
    return nativeIsComplete(decoder).value;
  }

  String result() {
    Pointer<Utf8> result = nativeResult(decoder, Pointer.fromFunction<ErrorCallback>(URDecoder.handleError));
    final resultStr = result.toDartString();
    return resultStr;
  }
}
