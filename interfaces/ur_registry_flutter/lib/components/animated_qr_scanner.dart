import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/ur_decoder.dart';

typedef SuccessCallback = void Function(NativeObject);
typedef FailureCallback = void Function(String);

class AnimatedQRScanner extends StatefulWidget {
  final SupportedType target;
  final SuccessCallback onSuccess;
  final FailureCallback onFailed;
  final QrScannerOverlayShape? overlay;

  const AnimatedQRScanner({
    super.key,
    required this.target,
    required this.onSuccess,
    required this.onFailed,
    this.overlay,
  });

  @override
  State<AnimatedQRScanner> createState() => _AnimatedQRScannerState();
}

class _AnimatedQRScannerState extends State<AnimatedQRScanner> {
  final GlobalKey<State<StatefulWidget>> keyQr = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  URDecoder _urDecoder = URDecoder();
  bool _succeed = false;

  @override
  Future<void> reassemble() async {
    if (controller case final controller?) {
      if (Platform.isAndroid) {
        await controller.pauseCamera();
      }
      controller.resumeCamera();
    }
    super.reassemble();
  }

  void _receiveQRCode(String? code) {
    try {
      if (code != null) {
        _urDecoder.receive(code);
        if (_urDecoder.isComplete()) {
          final result = _urDecoder.resolve(widget.target);
          if (!_succeed) {
            widget.onSuccess(result);
            _succeed = true;
          }
        }
      }
    } catch (e) {
      widget.onFailed("Error when receiving UR $e");
      _reset();
    }
  }

  void _reset() {
    _urDecoder = URDecoder();
    _succeed = false;
  }

  @override
  Widget build(BuildContext context) {
    return QRView(
      key: keyQr,
      onQRViewCreated: onQRViewCreated,
      overlay: widget.overlay,
    );
  }

  Future<void> onQRViewCreated(QRViewController controller) async {
    setState(() => this.controller = controller);
    // The reassemble function call is needed because of the black screen error
    // https://github.com/juliuscanute/qr_code_scanner/issues/538#issuecomment-1133883828
    // https://github.com/juliuscanute/qr_code_scanner/issues/548
    reassemble();
    try {
      controller.scannedDataStream.listen((event) {
        _receiveQRCode(event.code);
      });
    } catch (e) {
      widget.onFailed("Error when receiving UR: $e");
      _reset();
    }
  }
}
