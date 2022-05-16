import 'dart:ffi';

import 'package:ur_registry_flutter/ur_registry_flutter.dart';

typedef NativeFree = Pointer<Void> Function(
    Pointer<Void>);

class Utils {
  DynamicLibrary lib = UrRegistryFlutter.load();
  late NativeFree nativeFree = lib.lookup<NativeFunction<NativeFree>>("utils_free").asFunction();

  void free(Pointer pointer) {
    nativeFree(Pointer.fromAddress(pointer.address));
  }
}