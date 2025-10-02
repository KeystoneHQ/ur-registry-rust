import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/ur_decoder.dart';

abstract class _State {}

class _InitialState extends _State {}

typedef SuccessCallback = void Function(NativeObject);
typedef FailureCallback = void Function(String);

class _Cubit extends Cubit<_State> {
  late final SupportedType target;
  final SuccessCallback onSuccess;
  final FailureCallback onFailed;
  final Widget? overlay;
  URDecoder urDecoder = URDecoder();
  bool succeed = false;

  _Cubit(
    this.target,
    this.onSuccess,
    this.onFailed, {
    this.overlay,
  }) : super(_InitialState());

  void receiveQRCode(String? code) {
    try {
      if (code != null) {
        urDecoder.receive(code);
        if (urDecoder.isComplete()) {
          final result = urDecoder.resolve(target);
          if (!succeed) {
            onSuccess(result);
            succeed = true;
          }
        }
      }
    } catch (e) {
      onFailed("Error when receiving UR $e");
      reset();
    }
  }

  void reset() {
    urDecoder = URDecoder();
    succeed = false;
  }
}

class AnimatedQRScanner extends StatelessWidget {
  final SupportedType target;
  final SuccessCallback onSuccess;
  final FailureCallback onFailed;
  final Widget? overlay;

  const AnimatedQRScanner(
      {super.key,
      required this.target,
      required this.onSuccess,
      required this.onFailed,
      this.overlay});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>
          _Cubit(target, onSuccess, onFailed, overlay: overlay),
      child: _AnimatedQRScanner(),
    );
  }
}

class _AnimatedQRScanner extends StatefulWidget {
  @override
  _AnimatedQRScannerState createState() => _AnimatedQRScannerState();
}

class _AnimatedQRScannerState extends State<_AnimatedQRScanner> {
  final MobileScannerController controller =
      MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
  late final _Cubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: controller,
      overlayBuilder:
          _cubit.overlay != null ? (context, _) => _cubit.overlay! : null,
      onDetect: (BarcodeCapture capture) {
        for (final barcode in capture.barcodes) {
          _cubit.receiveQRCode(barcode.rawValue);
        }
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
