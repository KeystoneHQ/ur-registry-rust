import 'dart:ffi';

import 'package:ur_registry_flutter/ur_registry_flutter.dart';

class Base {
  DynamicLibrary lib = UrRegistryFlutter.load();
}
