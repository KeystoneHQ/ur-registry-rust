import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "cardano_sign_request";

typedef NativeConstruct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);

typedef Construct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);

typedef NativeNew = Pointer<Response> Function();

class CardanoSignRequest extends NativeObject {
  late Construct nativeConstruct = lib
      .lookup<NativeFunction<NativeConstruct>>("${nativePrefix}_construct")
      .asFunction<Construct>();
  late NativeGetUREncoder nativeGetUREncoder = lib
      .lookup<NativeFunction<NativeGetUREncoder>>(
          "${nativePrefix}_get_ur_encoder")
      .asFunction();
  late NativeNew nativeNew =
      lib.lookup<NativeFunction<NativeNew>>("${nativePrefix}_new").asFunction();
  late NativeGetRequestId nativeGetRequestId = lib
      .lookup<NativeFunction<NativeGetRequestId>>(
          "${nativePrefix}_get_request_id")
      .asFunction();

  late String uuid;

  CardanoSignRequest(Pointer<Void> object) : super() {
    nativeObject = object;
    final response = nativeGetRequestId(nativeObject).ref;
    final uuidBuffer = response.getString();
    uuid = Uuid.unparse(hex.decode(uuidBuffer));
  }

  CardanoSignRequest.factory(
    List<int> signData,
    String utxos,
    String cert_keys,
    String origin,
  ) : super() {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);
    final signDataStr = hex.encode(signData);

    final response = nativeConstruct(
            uuidBufferStr.toNativeUtf8(),
            signDataStr.toNativeUtf8(),
            utxos.toNativeUtf8(),
            cert_keys.toNativeUtf8(),
            origin.toNativeUtf8())
        .ref;

    nativeObject = response.getObject();
  }

  UREncoder toUREncoder() {
    final response = nativeGetUREncoder(nativeObject).ref;
    return UREncoder(response.getObject());
  }

  String getRequestId() {
    return uuid;
  }
}
