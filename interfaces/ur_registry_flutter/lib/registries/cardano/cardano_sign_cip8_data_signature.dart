import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:convert/convert.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:uuid/uuid.dart';

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetSignature = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetPublicKey = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetAddressField = Pointer<Response> Function(Pointer<Void>);

const nativePrefix = "cardano_sign_cip8_data_signature";

class CardanoSignCip8DataSignature extends NativeObject {
  CardanoSignCip8DataSignature(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  late NativeGetRequestId nativeGetRequestId = lib
      .lookup<NativeFunction<NativeGetRequestId>>(
          "${nativePrefix}_get_request_id")
      .asFunction();
  late NativeGetSignature nativeGetSignature = lib
      .lookup<NativeFunction<NativeGetSignature>>(
          "${nativePrefix}_get_signature")
      .asFunction();
  late NativeGetPublicKey nativeGetPublicKey = lib
      .lookup<NativeFunction<NativeGetPublicKey>>(
          "${nativePrefix}_get_public_key")
      .asFunction();
  late NativeGetAddressField nativeGetAddressField = lib
      .lookup<NativeFunction<NativeGetAddressField>>(
          "${nativePrefix}_get_address_field")
      .asFunction();

  String getRequestId() {
    final response = nativeGetRequestId(nativeObject).ref;
    final String requestIdBufferStr = response.getString();
    return Uuid.unparse(hex.decode(requestIdBufferStr));
  }

  List<int> getSignature() {
    final response = nativeGetSignature(nativeObject).ref;
    final String signature = response.getString();
    return hex.decode(signature);
  }

  List<int> getPublicKey() {
    final response = nativeGetPublicKey(nativeObject).ref;
    final String publicKey = response.getString();
    return hex.decode(publicKey);
  }

  List<int> getAddressField() {
    final response = nativeGetAddressField(nativeObject).ref;
    final String addressField = response.getString();
    return hex.decode(addressField);
  }
}
