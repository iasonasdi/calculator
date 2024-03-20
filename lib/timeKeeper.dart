import 'dart:async';

class TimeKeeper {
  late Timer _timer;
  late DateTime _lastCalledTime;

  TimeKeeper() {
    _lastCalledTime = DateTime.now();
  }

  bool checkElapsedTime() {
    DateTime currentTime = DateTime.now();
    Duration difference = currentTime.difference(_lastCalledTime);
    if (difference.inMinutes >= 10) {
      return true;
    }
    return false;
  }

  void updateLastCalledTime() {
    _lastCalledTime = DateTime.now();
  }

  void cancelTimer() {
    _timer.cancel();
  }
}
