import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isolate_timer/provider/slider_provider.dart';

class TimerProvider with ChangeNotifier {
  //final SoundSelectionProvider _audioProvider = SoundSelectionProvider();
  late Timer _timer;
  //late int _currentTimeInMinutes;
  String remainingTime = "";
  DateTime _currentDateTime = DateTime.now();
  bool _isRunning = false;
  bool _isCancel = false;

  DateTime _targetTime = DateTime.now();


  TimerProvider() {
    resetTimer();
  }
  bool get isRunning => _isRunning;
  bool get isCancel => _isCancel;
  //int get currentTimeInSeconds => _currentTimeInMinutes;
  DateTime get currentDateTime => _currentDateTime;
  int get maxTimeInMinutes => SliderProvider.studyDurationSliderValue;
  //bool get isEqual => currentTimeInSeconds == maxTimeInMinutes;

  DateTime get targetTime => _targetTime;

  String get currentTimeDisplay {
    return "${SliderProvider.studyDurationSliderValue.toString()}:00";
  }
  void setTargetTime() {
    _targetTime = DateTime.now().add(Duration(minutes: maxTimeInMinutes));
    notifyListeners();
  }
  void setRemainingTime(DateTime? time) {
    remainingTime = "${(targetTime.difference(time!).inMinutes).toString().padLeft(2,"0")}:${(targetTime.difference(time).inSeconds % 60).toString().padLeft(2,"0")}";
    notifyListeners();
  }



  void toggleTimer() {
    if (!_isRunning) {
      _isRunning = true;
      notifyListeners();
    } else {
      _isRunning = false;
      notifyListeners();
    }
  }
  void cancelState() {
    if (!isRunning) {
      //if (maxTimeInMinutes - currentTimeInSeconds >= 10) {
      //  _isCancel = true;
      //  notifyListeners();
      //} else {
      //  _isCancel = false;
      //  notifyListeners();
      //}
    } else {
      _timer.cancel();
      _isRunning = false;
      notifyListeners();
    }
  }
  void resetTimer() {
    //_currentTimeInMinutes = maxTimeInMinutes;
    //_currentDateTime = DateTime.now();
    _targetTime = DateTime.now();
    notifyListeners();
  }
  void resetDateTime() {
    _currentDateTime = DateTime.now();
    notifyListeners();
  }
}