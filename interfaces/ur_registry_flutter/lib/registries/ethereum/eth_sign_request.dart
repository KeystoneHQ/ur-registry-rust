import 'package:ur_registry_flutter/ffi/ffi_factory.dart';

import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "eth_sign_request";

typedef NativeConstruct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Uint32,
  Uint32,
  Pointer<Utf8>,
  Uint32,
  Pointer<Utf8>,
  Pointer<Utf8>,
);
typedef Construct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  int,
  int,
  Pointer<Utf8>,
  int,
  Pointer<Utf8>,
  Pointer<Utf8>,
);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);

typedef NativeNew = Pointer<Response> Function();

class EthSignRequest extends NativeObject {
  static int transaction = 1;
  static int typedData = 2;
  static int personalMessage = 3;
  static int typedTransaction = 4;
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

  EthSignRequest(Pointer<Void> object) : super() {
    nativeObject = object;
    final response = nativeGetRequestId(nativeObject).ref;
    final uuidBuffer = response.getString();
    uuid = Uuid.unparse(hex.decode(uuidBuffer));
  }

  EthSignRequest.factory(
    List<int> signData,
    int signType,
    int chainId,
    String path,
    String xfp,
    String address,
    String origin,
  ) : super() {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);
    final signDataStr = hex.encode(signData);
    final xfpInt = int.parse(xfp, radix: 16);

    final response = nativeConstruct(
            uuidBufferStr.toNativeUtf8(),
            signDataStr.toNativeUtf8(),
            signType,
            chainId,
            path.toNativeUtf8(),
            xfpInt,
            address.toNativeUtf8(),
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
