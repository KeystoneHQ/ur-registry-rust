import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';

abstract class _State {}

class _InitialState extends _State {}

class _Cubit extends Cubit<_State> {
  final UREncoder urEncoder;

  late String currentQR;

  _Cubit(this.urEncoder) : super(_InitialState());

  void initial() {
    currentQR = urEncoder.nextPart();
    Timer.periodic(const Duration(milliseconds: 100), (_) {
      currentQR = urEncoder.nextPart();
    });
  }
}

class AnimatedQRCode extends StatelessWidget {
  final UREncoder urEncoder;

  const AnimatedQRCode({Key? key, required this.urEncoder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _Cubit(urEncoder),
      child: const _AnimatedQRCode(),
    );
  }
}

class _AnimatedQRCode extends StatefulWidget {
  const _AnimatedQRCode({Key? key}) : super(key: key);

  @override
  _AnimatedQRCodeState createState() => _AnimatedQRCodeState();
}

class _AnimatedQRCodeState extends State<_AnimatedQRCode> {
  _AnimatedQRCodeState();

  late _Cubit _cubit;

  @override
  void initState() {
    _cubit = BlocProvider.of(context);
    _cubit.initial();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: 250,
      padding: const EdgeInsets.symmetric(
        vertical: 24,
        horizontal: 24,
      ),
      child: QrImage(
        data: _cubit.currentQR,
        size: 200,
        backgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }
}
