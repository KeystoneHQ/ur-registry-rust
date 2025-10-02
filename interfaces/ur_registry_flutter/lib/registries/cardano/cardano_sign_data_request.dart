import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "cardano_sign_data_request";
typedef NativeConstruct = Pointer<Response> Function(
  Pointer<Utf8>,
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
  Pointer<Utf8>,
);

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

class CardanoSignDataRequest extends NativeObject {
  late Construct nativeConstruct = lib
      .lookup<NativeFunction<NativeConstruct>>("${nativePrefix}_construct") //
      .asFunction<Construct>();

  late NativeGetUREncoder nativeGetUREncoder = lib
      .lookup<NativeFunction<NativeGetUREncoder>>("${nativePrefix}_get_ur_encoder") //
      .asFunction();      

  late NativeGetRequestId nativeGetRequestId = lib
      .lookup<NativeFunction<NativeGetRequestId>>(
          "${nativePrefix}_get_request_id")
      .asFunction();

  late String uuid;

  CardanoSignDataRequest(Pointer<Void> object) : super() {
    nativeObject = object;
    final response = nativeGetRequestId(nativeObject).ref;
    final uuidBuffer = response.getString();
    uuid = Uuid.unparse(hex.decode(uuidBuffer));
  }

  CardanoSignDataRequest.factory(
    String mfp,
    List<int> signData,
    String derivationPath,
    String origin,
    String xpub,
  ) : super() {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);
    final signDataStr = hex.encode(signData);

    final response = nativeConstruct(
      uuidBufferStr.toNativeUtf8(),
      mfp.toNativeUtf8(),
      signDataStr.toNativeUtf8(),
      derivationPath.toNativeUtf8(),
      origin.toNativeUtf8(),
      xpub.toNativeUtf8(),
    ).ref;

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
