import 'dart:ffi';

import 'package:ur_registry_flutter/ffi/ffi_interface.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:uuid/uuid.dart';
import 'package:convert/convert.dart';

const nativePrefix = "cardano_catalyst_voting_registration";
typedef NativeConstruct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Uint8,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Uint8,
);

typedef Construct = Pointer<Response> Function(
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  Pointer<Utf8>,
  int,
  Pointer<Utf8>,
  Pointer<Utf8>,
  int,
);
typedef NativeGetUREncoder = Pointer<Response> Function(Pointer<Void>);

typedef NativeGetRequestId = Pointer<Response> Function(Pointer<Void>);

typedef NativeNew = Pointer<Response> Function();

class CardanoCatalystVotingRegistration extends NativeObject {
  late Construct nativeConstruct = lib
      .lookup<NativeFunction<NativeConstruct>>("${nativePrefix}_construct") //
      .asFunction<Construct>();
  late NativeGetUREncoder nativeGetUREncoder = lib
      .lookup<NativeFunction<NativeGetUREncoder>>(
          "${nativePrefix}_get_ur_encoder") //
      .asFunction();
  late NativeNew nativeNew = lib
      .lookup<NativeFunction<NativeNew>>("${nativePrefix}_new") //
      .asFunction();
  late NativeGetRequestId nativeGetRequestId = lib
      .lookup<NativeFunction<NativeGetRequestId>>(
          "${nativePrefix}_get_request_id") //
      .asFunction();

  late String uuid;

  CardanoCatalystVotingRegistration(Pointer<Void> object) : super() {
    nativeObject = object;
    final response = nativeGetRequestId(nativeObject).ref;
    final uuidBuffer = response.getString();
    uuid = Uuid.unparse(hex.decode(uuidBuffer));
  }
// request_id: PtrString,
// mfp: PtrString,
// delegations: PtrString,
// stake_pub: PtrString,
// payment_address: PtrString,
// nonce: PtrString,
// voting_purpose: u8,
// derivation_path: PtrString,
// origin: PtrString,
// sign_type: u8,
  CardanoCatalystVotingRegistration.factory(
    String mfp,
    String delegations,
    String paymentAddress,
    String stakePub,
    String nonce,
    int votingPurpose,
    String derivationPath,
    String origin,
    int signType,
  ) : super() {
    uuid = const Uuid().v4();
    final buffer = Uuid.parse(uuid);
    final uuidBufferStr = hex.encode(buffer);

    final response = nativeConstruct(
      uuidBufferStr.toNativeUtf8(),
      mfp.toNativeUtf8(),
      delegations.toNativeUtf8(),
      paymentAddress.toNativeUtf8(),
      stakePub.toNativeUtf8(),
      nonce.toNativeUtf8(),
      votingPurpose,
      derivationPath.toNativeUtf8(),
      origin.toNativeUtf8(),
      signType,
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
