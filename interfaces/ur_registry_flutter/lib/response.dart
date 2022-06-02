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

  Pointer<Void>? getObject() {
    throwIfPresent();
    if (valueType.toDartString() == "OBJECT") return data._object;
    return null;
  }

  bool? getBoolean() {
    throwIfPresent();
    if (valueType.toDartString() == "BOOLEAN") return data._boolean;
    return null;
  }

  int? getUint32() {
    throwIfPresent();
    if(valueType.toDartString() == "UINT32") return data._uInt32;
    return null;
  }

  String? getString() {
    throwIfPresent();
    if(valueType.toDartString() == "STRING") return data._string.toDartString();
    return null;
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
