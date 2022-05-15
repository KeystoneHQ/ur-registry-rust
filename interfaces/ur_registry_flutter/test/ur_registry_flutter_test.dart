import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ur_registry_flutter/ur_registry_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ur_registry_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UrRegistryFlutter.platformVersion, '42');
  });
}
