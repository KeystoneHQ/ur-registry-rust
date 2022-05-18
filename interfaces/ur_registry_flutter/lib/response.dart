import 'dart:ffi';
import 'package:ffi/ffi.dart';

const success = 0;
const error = 1;

class Data extends Union {
  external Pointer<Void> _object;

  @Bool()
  external bool _boolean;

  @Uint32()
  external int _uInt32;

  external Pointer<Utf8> _string;

  external Pointer<Void> _null;

  String getString() {
    return _string.toDartString();
  }

  int getUInt32() {
    return _uInt32.toUnsigned(32);
  }

  bool getBoolean() {
    return _boolean;
  }

  Pointer<Void> getObject() {
    return _object;
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