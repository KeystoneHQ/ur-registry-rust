import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/response.dart';
import '../../native_object.dart';

const nativePrefix = "extend_crypto_multi_accounts";

typedef NativeGetMasterFingerprint = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetDevice = Pointer<Response> Function(Pointer<Void>);
typedef NativeGetKey = Pointer<Response> Function(Pointer<Void>, Uint32);
typedef GetKey = Pointer<Response> Function(Pointer<Void>, int);
typedef NativeGetKeysLen = Pointer<Response> Function(Pointer<Void>);
typedef GetKeysLen = Pointer<Response> Function(Pointer<Void>);

class CryptoMultiAccounts extends NativeObject {
  CryptoMultiAccounts(Pointer<Void> object) : super(){
    nativeObject = object;
  }

  late final NativeGetDevice nativeGetDevice = lib
      .lookup<NativeFunction<NativeGetMasterFingerprint>>(
          "${nativePrefix}_get_device")
      .asFunction();

  late final NativeGetMasterFingerprint nativeGetMasterFingerprint = lib
      .lookup<NativeFunction<NativeGetMasterFingerprint>>(
          "${nativePrefix}_get_master_fingerprint")
      .asFunction();

  late final GetKey getKey = lib
      .lookup<NativeFunction<NativeGetKey>>("${nativePrefix}_get_key")
      .asFunction();

  late final GetKeysLen getKeysLen = lib
      .lookup<NativeFunction<NativeGetKeysLen>>("${nativePrefix}_get_keys_len")
      .asFunction();

  String getDevice() {
    final response = nativeGetDevice(nativeObject).ref;
    return response.getString();
  }

  String getMasterFingerprint() {
    final response = nativeGetMasterFingerprint(nativeObject).ref;
    return response.getString();
  }

  List<CryptoHDKey> getKeys() {
    Response response = getKeysLen(nativeObject).ref;
    response.throwIfPresent();
    final length = response.data.getUInt32();
    List<CryptoHDKey> cryptoHDKeys = [];
    for (int i = 0; i < length; i++) {
      response = getKey(nativeObject, i).ref;
      response.throwIfPresent();
      cryptoHDKeys.add(CryptoHDKey(response.data.getObject()));
    }
    return cryptoHDKeys;
  }
}
