import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class RepeatController extends ChangeNotifier {
  LoopMode _loopMode;

  RepeatController({LoopMode initialMode = LoopMode.off})
      : _loopMode = initialMode;

  LoopMode get loopMode => _loopMode;
  bool get isLooping => _loopMode == LoopMode.one;

  void setLoopMode(LoopMode mode) {
    if (_loopMode == mode) return;
    _loopMode = mode;
    notifyListeners();
  }

  Future<void> toggleLoop({
    required Future<void> Function(LoopMode nextMode) onLoopModeChanged,
  }) async {
    final nextMode = isLooping ? LoopMode.off : LoopMode.one;
    _loopMode = nextMode;
    notifyListeners();
    await onLoopModeChanged(nextMode);
  }
}
