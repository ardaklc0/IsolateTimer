import 'dart:async';
import 'dart:isolate';

class CountdownTimer {
  final receivePort = ReceivePort();
  late Isolate _isolate;

  void stop() {
    receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  Future<void> start(Duration initialDuration) async {
    Map map = {
      'port': receivePort.sendPort,
      'initial_duration': initialDuration,
    };
    _isolate = await Isolate.spawn(_entryPoint, map);
    receivePort.sendPort.send(initialDuration);
  }

  static void _entryPoint(Map map) async {
    Duration initialTime = map['initial_duration'];
    SendPort port = map['port'];
    Timer.periodic(
      const Duration(seconds: 1), (timer) {
        if (timer.tick == initialTime.inSeconds) {
          timer.cancel();
          port.send(timer.tick);
          port.send('Timer finished');
        } else {
          port.send(timer.tick);
        }
      },
    );
  }
}