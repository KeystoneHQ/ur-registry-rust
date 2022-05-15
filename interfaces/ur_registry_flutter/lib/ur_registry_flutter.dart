import 'dart:async';

import 'package:flutter/services.dart';

import 'dart:ffi';
import 'dart:io' show Platform;

DynamicLibrary load() {
  return Platform.isAndroid
      ? DynamicLibrary.open("libur_registry_ffi.so")
      : DynamicLibrary.process();
}

class UrRegistryFlutter {
  static final DynamicLibrary lib = load();
  static const MethodChannel _channel = MethodChannel('ur_registry_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
