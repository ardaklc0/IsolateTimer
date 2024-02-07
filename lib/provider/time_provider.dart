import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isolate_timer/provider/slider_provider.dart';

class TimerProvider with ChangeNotifier {
  //final SoundSelectionProvider _audioProvider = SoundSelectionProvider();
  late Timer _timer;
  late int _currentTimeInMinutes;
  static String remainingTime = "";
  DateTime _currentDateTime = DateTime.now();
  bool _isRunning = false;
  bool _isCancel = false;
  TimerProvider() {
    resetTimer();
  }
  bool get isRunning => _isRunning;
  bool get isCancel => _isCancel;
  int get currentTimeInSeconds => _currentTimeInMinutes;
  DateTime get currentDateTime => _currentDateTime;
  int get maxTimeInMinutes => SliderProvider.studyDurationSliderValue;
  bool get isEqual => currentTimeInSeconds == maxTimeInMinutes;
  String get currentTimeDisplay {
    int minutes = _currentTimeInMinutes;
    int seconds = _currentTimeInMinutes % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  void setCurrentTimeDisplay(minutes, seconds) {
    remainingTime = '$minutes:${seconds.toString().padLeft(2, '0')}';
    notifyListeners();
  }

  void toggleTimer() {
    if (!_isRunning) {
      _isRunning = true;
      //WakelockPlus.enable();
      _timer = Timer.periodic(const Duration(seconds: 1), _updateTimer);
      notifyListeners();
    } else {
      _timer.cancel();
      _isRunning = false;
      //WakelockPlus.disable();
      notifyListeners();
    }
  }
  void cancelState() {
    if (!isRunning) {
      if (maxTimeInMinutes - currentTimeInSeconds >= 10) {
        _isCancel = true;
        notifyListeners();
      } else {
        _isCancel = false;
        notifyListeners();
      }
    } else {
      _timer.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }
  Future<void> _updateTimer(Timer timer) async {
    if (_currentTimeInMinutes > 0) {
      _currentTimeInMinutes--;
      notifyListeners();
    } else {
      _timer.cancel(); // previous timer
      _isRunning = false;
      notifyListeners();
      //if (AutoStartProvider.autoStart == false) {
      //  _timer.cancel(); // next timer
      //  _isRunning = false;
      //  notifyListeners();
      //}
      //if (NotificationProvider.isActive) {
      //  _audioProvider.playSelectedAudio();
      //}
      resetTimer();
    }
  }
  void resetTimer() {
    _currentTimeInMinutes = maxTimeInMinutes;
    _currentDateTime = DateTime.now();
    notifyListeners();
  }
  void resetDateTime() {
    _currentDateTime = DateTime.now();
    notifyListeners();
  }
}