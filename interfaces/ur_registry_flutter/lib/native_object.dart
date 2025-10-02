import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'package:ur_registry_flutter/ur_registry_flutter.dart';

class NativeObject {
  DynamicLibrary lib = UrRegistryFlutter.load();
  late Pointer<Void> nativeObject;
}