import 'dart:ffi';
import 'package:ffi/ffi.dart';

const success = 0;
const error = 1;

class Response extends Struct {
  @Uint32()
  external int statusCode;

  external Pointer<Utf8> errorMessage;

  external Pointer<Void> data;

  bool isSuccess() {
    return statusCode == success;
  }

  String getErrorMessage() {
    return errorMessage.toDartString();
  }
}