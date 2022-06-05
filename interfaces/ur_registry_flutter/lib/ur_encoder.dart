import 'dart:ffi';

import 'package:ur_registry_flutter/base.dart';
import 'package:ur_registry_flutter/response.dart';

typedef NativeNextPart = Pointer<Response> Function(Pointer<Void>);

const nativePrefix = "ur_encoder";

class UREncoder extends Base {
  late NativeNextPart nativeNextPart = lib.lookup<NativeFunction<NativeNextPart>>("${nativePrefix}_next_part").asFunction();
  late Pointer<Void> encoder;

  UREncoder(this.encoder);

  String nextPart() {
    final response = nativeNextPart(encoder).ref;
    response.throwIfPresent();
    final resultStr = response.data.getString().toUpperCase();
    return resultStr;
  }
}