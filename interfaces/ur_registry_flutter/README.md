# ur_registry_flutter

This is an FFI bridge for [`ur-registry-rust`](https://github.com/KeystoneHQ/ur-registry-rust) with flutter usage.

This plugin only support Android and iOS currently.

## Getting Started

This package has two components, `AnimatedQRCode` and `AnimatedQRScanner`.
And other UR registry types, please refer to the code source to see how to use them.

### AnimatedQRCode
This component is designed to show animated qr code.

When you want to use AnimatedQRCode to show your data, you shall assemble your data firstly. 

For example: 
```dart
final List<int> signData = [];
final String path = "M/44'/501'/1'/0'";
final String xfp = "12345678";
final Uint8List pubkey = base58.decode("any wallet address");
final SolSignRequest signRequest = SolSignRequest.factory(signData, path, xfp, pubkey, 'origin', isTransaction ? 1 : 2);
final urEncoder = signRequest.toUREncoder();
```

Then you can pass the assembled urEncoder to the component in your page: 
```dart
AnimatedQRCode(
  urEncoder: urEncoder
)
```

### AnimatedQRScanner
This component is designed to scan animated qr codes.

When you want to use this component, you should pass in expected UR type, a success callback and a failure callback to this component.

The supported types are listed at [`ur_decoder.dart`](./lib/ur_decoder.dart);

for example: 
```dart
AnimatedQRScanner(
  target: SupportedType.solSignRequest, 
  onSuccess: _cubit.onScanSuccess, 
  onFailed: _cubit.onScanFailed
),
```

the `onSuccess` callback will return a `NativeObject` instance then you can cast it to your expected type.

in this case: 
```dart
void onScanSuccess(NativeObject object) {
  final SolSignRequest solSignRequest = object as SolSignRequest;
  //...
}
```

## Build
See [ur-registry-rust](https://github.com/KeystoneHQ/ur-registry-rust) for more info.