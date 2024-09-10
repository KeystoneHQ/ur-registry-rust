import 'package:ur_registry_flutter/ffi/ffi_factory.dart';

import 'package:convert/convert.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:uuid/uuid.dart';

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetSignature = Pointer<Response> Function(Pointer<Void>);

const nativePrefix = "eth_signature";

class EthSignature extends NativeObject {
  EthSignature(Pointer<Void> object) : super() {
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
}
