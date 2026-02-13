import 'dart:async';

import 'package:flutter/services.dart';

import 'package:ur_registry_flutter/ffi/ffi_factory.dart';
import 'dart:io' show Platform;

class UrRegistryFlutter {
  static DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("libur_registry_ffi.so");
    }
    // macOS is not an officially supported platform for this plugin.
    // This path exists only to allow running flutter tests locally via `make test`.
    if (Platform.isMacOS) {
      return DynamicLibrary.open("libur_registry_ffi.dylib");
    }
    // iOS — static library is linked into the app binary
    return DynamicLibrary.process();
  }
  static const MethodChannel _channel = MethodChannel('ur_registry_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
