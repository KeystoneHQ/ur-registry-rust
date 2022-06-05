import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:ur_registry_flutter/base.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "solana_sign_request";

typedef NativeNew = Pointer<Response> Function(Pointer<Utf8>, Pointer<Utf8>,
    Pointer<Utf8>, Uint32, Pointer<Utf8>, Pointer<Utf8>, Uint32);
typedef New = Pointer<Response> Function(Pointer<Utf8>, Pointer<Utf8>,
    Pointer<Utf8>, int, Pointer<Utf8>, Pointer<Utf8>, int);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

class SolSignRequest extends Base {
  int transaction = 1;
  int message = 2;
  late New nativeNew = lib
      .lookup<NativeFunction<NativeNew>>("${nativePrefix}_new")
      .asFunction<New>();
  late NativeGetUREncoder nativeGetUREncoder = lib
      .lookup<NativeFunction<NativeGetUREncoder>>(
          "${nativePrefix}_get_ur_encoder")
      .asFunction();
  late Pointer<Void> nativeInstance;

  late String uuid;

  SolSignRequest(List<int> signData, String path, String xfp, List<int> pubkey,
      String origin, int signType) {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);
    final signDataStr = hex.encode(signData);
    final pubkeyStr = hex.encode(pubkey);
    final xfpInt = int.parse(xfp, radix: 16);

    final response = nativeNew(
            uuidBufferStr.toNativeUtf8(),
            signDataStr.toNativeUtf8(),
            path.toNativeUtf8(),
            xfpInt,
            pubkeyStr.toNativeUtf8(),
            origin.toNativeUtf8(),
            signType)
        .ref;
    nativeInstance = response.getObject();
  }

  UREncoder toUREncoder() {
    final response = nativeGetUREncoder(nativeInstance).ref;
    return UREncoder(response.getObject());
  }
}
