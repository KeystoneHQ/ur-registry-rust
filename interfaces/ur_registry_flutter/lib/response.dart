import 'dart:ffi';
import 'package:ffi/ffi.dart';

const success = 0;
const error = 1;

class Data extends Union {
  external Pointer<Void> _Object;

  @Bool()
  external bool _Boolean;

  @Uint32()
  external int _UInt32;

  external Pointer<Utf8> _String;

  external Pointer<Void> _Null;

  String getString() {
    return _String.toDartString();
  }

  int getUInt32() {
    return _UInt32.toUnsigned(32);
  }

  bool getBoolean() {
    return _Boolean;
  }

  Pointer<Void> getObject() {
    return _Object;
  }
}

class Response extends Struct {
  @Uint32()
  external int statusCode;

  external Pointer<Utf8> errorMessage;

  external Data data;

  bool isSuccess() {
    return statusCode == success;
  }

  bool isError() {
    return statusCode == error;
  }

  void throwIfPresent() {
    if(isError()) {
      throw Exception(getErrorMessage());
    }
  }

  String getErrorMessage() {
    return errorMessage.toDartString();
  }
}