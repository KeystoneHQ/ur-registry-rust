import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'package:ur_registry_flutter/ur_registry_flutter.dart';

typedef URDecoderNewFFI = Pointer<Void> Function();
typedef URDecoderNew = Pointer<Void> Function();

typedef ErrorCallback = Handle Function(Pointer<Utf8>);

typedef URDecoderReceiveFFI = Pointer<Void> Function(
    Pointer<Void>, Pointer<Utf8>, Pointer<NativeFunction<ErrorCallback>>);
typedef URDecoderReceive = Pointer<Void> Function(
    Pointer<Void>, Pointer<Utf8>, Pointer<NativeFunction<ErrorCallback>>);

typedef URDecoderResultFFI = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<NativeFunction<ErrorCallback>>);
typedef URDecoderResult = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<NativeFunction<ErrorCallback>>);

typedef URDecoderIsComplete = Pointer<Bool> Function(Pointer<Void>);

class URDecoder {
  late Pointer<Void> decoder;

  URDecoder() {
    URDecoderNew urDecoderNew = UrRegistryFlutter.lib
        .lookup<NativeFunction<URDecoderNewFFI>>("ur_decoder_new")
        .asFunction();
    decoder = urDecoderNew();
  }

  static void handleError(Pointer<Utf8> error) {
    print(error.toDartString());
  }

  void receive(String ur) {
    URDecoderReceive urDecoderReceive = UrRegistryFlutter.lib
        .lookup<NativeFunction<URDecoderReceive>>("ur_decoder_receive")
        .asFunction();
    urDecoderReceive(
        decoder,
        ur.toNativeUtf8(),
        Pointer.fromFunction<ErrorCallback>(handleError));
  }

  bool isComplete() {
    URDecoderIsComplete urDecoderIsComplete = UrRegistryFlutter.lib.lookup<NativeFunction<URDecoderIsComplete>>("ur_decoder_is_complete").asFunction();
    return urDecoderIsComplete(decoder).value;
  }

  String result() {
    URDecoderResult urDecoderResult = UrRegistryFlutter.lib.lookup<NativeFunction<URDecoderResult>>("ur_decoder_result").asFunction();
    Pointer<Utf8> result = urDecoderResult(decoder, Pointer.fromFunction<ErrorCallback>(URDecoder.handleError));
    final resultStr = result.toDartString();
    return resultStr;
  }
}
