import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';

class AnimatedQRCodeStyle {
  final double size;

  AnimatedQRCodeStyle({
    this.size = 200,
  });

  const AnimatedQRCodeStyle.factory() : size = 200;
}

class AnimatedQRCode extends StatefulWidget {
  final UREncoder urEncoder;
  final AnimatedQRCodeStyle style;

  const AnimatedQRCode({super.key, required this.urEncoder, this.style = const AnimatedQRCodeStyle.factory()});

  @override
  State<AnimatedQRCode> createState() => _AnimatedQRCodeState();
}

class _AnimatedQRCodeState extends State<AnimatedQRCode> {
  late String _currentQR;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentQR = widget.urEncoder.nextPart();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        _currentQR = widget.urEncoder.nextPart();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: _currentQR,
      size: widget.style.size,
      backgroundColor: const Color(0xFFFFFFFF),
    );
  }
}
