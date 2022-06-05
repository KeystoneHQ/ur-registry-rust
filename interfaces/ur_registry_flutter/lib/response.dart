import 'dart:ffi';
import 'package:ffi/ffi.dart';

const success = 0;
const error = 1;

const typeObject = "OBJECT";
const typeBoolean = "BOOLEAN";
const typeUInt32 = "UINT32";
const typeString = "STRING";

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

  bool isNull() {
    return _null.address == 0;
  }
}

class Response extends Struct {
  @Uint32()
  external int statusCode;

  external Pointer<Utf8> errorMessage;

  external Pointer<Utf8> valueType;

  external Data data;

  bool isSuccess() {
    return statusCode == success;
  }

  bool isError() {
    return statusCode == error;
  }

  void checkValueType(String target) {
    if(valueType.toDartString() != target) throw Exception("Wrong response type, expected $target, received ${valueType.toDartString()}");
  }

  Pointer<Void> getObject() {
    throwIfPresent();
    checkValueType(typeObject);
    return data._object;
  }

  bool getBoolean() {
    throwIfPresent();
    checkValueType(typeBoolean);
    return data._boolean;
  }

  int getUint32() {
    throwIfPresent();
    checkValueType(typeUInt32);
    return data._uInt32;
  }

  String getString() {
    throwIfPresent();
    checkValueType(typeString);
    return data._string.toDartString();
  }

  void throwIfPresent() {
    if (isError()) {
      throw Exception(getErrorMessage());
    }
  }

  String getErrorMessage() {
    return errorMessage.toDartString();
  }
}
