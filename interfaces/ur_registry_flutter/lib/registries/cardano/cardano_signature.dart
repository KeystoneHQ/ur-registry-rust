import 'dart:ffi';

import 'package:convert/convert.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:uuid/uuid.dart';

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetWitnessSet = Pointer<Response> Function(Pointer<Void>);

const nativePrefix = "cardano_signature";

class CardanoSignature extends NativeObject {
  CardanoSignature(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  late NativeGetRequestId nativeGetRequestId = lib
      .lookup<NativeFunction<NativeGetRequestId>>(
          "${nativePrefix}_get_request_id")
      .asFunction();
  late NativeGetWitnessSet nativeGetWitnessSet = lib
      .lookup<NativeFunction<NativeGetWitnessSet>>(
          "${nativePrefix}_get_witness_set")
      .asFunction();

  String getRequestId() {
    final response = nativeGetRequestId(nativeObject).ref;
    final String requestIdBufferStr = response.getString();
    return Uuid.unparse(hex.decode(requestIdBufferStr));
  }

  List<int> getWitnessSet() {
    final response = nativeGetWitnessSet(nativeObject).ref;
    final String witnessSet = response.getString();
    return hex.decode(witnessSet);
  }
}
