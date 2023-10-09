import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';

abstract class _State {}

class _InitialState extends _State {}

class _AnimatedQRDataState extends _State {
  final String data;
  _AnimatedQRDataState(this.data);
}

class _Cubit extends Cubit<_State> {
  final UREncoder urEncoder;
  final AnimatedQRCodeStyle style;

  late String _currentQR;
  late Timer timer;

  _Cubit(this.urEncoder, this.style) : super(_InitialState());

  void initial() {
    _currentQR = urEncoder.nextPart();
    emit(_AnimatedQRDataState(_currentQR));
    timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      _currentQR = urEncoder.nextPart();
      emit(_AnimatedQRDataState(_currentQR));
    });
  }

  @override
  Future<void> close() async {
    timer.cancel();
  }

  String get currentQR => _currentQR;
}

class AnimatedQRCodeStyle {
  final double size;

  AnimatedQRCodeStyle({
    this.size = 200,
  });

  const AnimatedQRCodeStyle.factory()
      : size = 200;
}

class AnimatedQRCode extends StatelessWidget {
  final UREncoder urEncoder;
  final AnimatedQRCodeStyle style;

  const AnimatedQRCode(
      {Key? key,
      required this.urEncoder,
      this.style = const AnimatedQRCodeStyle.factory()})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _Cubit(urEncoder, style),
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
    return BlocBuilder<_Cubit, _State>(builder: (context, state) {
      if(state is _AnimatedQRDataState) {
        return QrImageView(
          data: state.data,
          size: _cubit.style.size,
          backgroundColor: const Color(0xFFFFFFFF),
        );
      }
      return QrImageView(
        data: _cubit.currentQR,
        size: _cubit.style.size,
        backgroundColor: const Color(0xFFFFFFFF),
      );
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
