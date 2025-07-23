import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/response.dart';

typedef NativeNextPart = Pointer<Response> Function(Pointer<Void>);

const nativePrefix = "ur_encoder";

class UREncoder extends NativeObject {
  late NativeNextPart nativeNextPart = lib
      .lookup<NativeFunction<NativeNextPart>>("${nativePrefix}_next_part")
      .asFunction();

  UREncoder(Pointer<Void> object) : super() {
    nativeObject = object;
  }

  String nextPart() {
    final response = nativeNextPart(nativeObject).ref;
    final resultStr = response.getString().toUpperCase();
    return resultStr;
  }
}
