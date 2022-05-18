import 'dart:ffi';

import 'base.dart';

class NativeObject extends Base {
  late Pointer<Void> nativeObject;

  NativeObject(Pointer<Void> object) {
    nativeObject = object;
  }
}