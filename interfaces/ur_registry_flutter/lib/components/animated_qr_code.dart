import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';

abstract class _State {}

class _InitialState extends _State {}

class _AnimatedQRDataState extends _State {
  final String data;

  _AnimatedQRDataState(this.data);
}

class _Cubit extends Cubit<_State> {
  final UREncoder urEncoder;
  final PrettyQrDecoration? decoration;

  late String _currentQR;
  late Timer timer;

  _Cubit(this.urEncoder, this.decoration) : super(_InitialState());

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
    super.close();
  }

  String get currentQR => _currentQR;
}

class AnimatedQRCode extends StatelessWidget {
  final UREncoder urEncoder;
  final PrettyQrDecoration? decoration;

  const AnimatedQRCode({
    super.key,
    required this.urEncoder,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => _Cubit(urEncoder, decoration),
      child: const _AnimatedQRCode(),
    );
  }
}

class _AnimatedQRCode extends StatefulWidget {
  const _AnimatedQRCode();

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
      if (state is _AnimatedQRDataState) {
        return PrettyQrView.data(
          data: state.data,
          decoration: _cubit.decoration,
        );
      }
      return PrettyQrView.data(
        data: _cubit.currentQR,
        decoration: _cubit.decoration,
      );
    });
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
