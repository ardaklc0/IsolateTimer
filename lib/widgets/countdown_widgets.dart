import 'dart:async';
import 'dart:isolate';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isolate_timer/time_picker.dart';
class Countdown extends StatefulWidget {
  const Countdown({super.key});
  @override
  State<Countdown> createState() => _CountdownState();
}
class _CountdownState extends State<Countdown> {
  late Isolate? _isolate;
  bool _running = false;
  static int initialDuration = 0;
  String notification = "";
  final ReceivePort _receivePort = ReceivePort();
  final TextEditingController _controller = TextEditingController();

  void _start() async {
    Map map = {
      'port': _receivePort.sendPort,
      'initialDuration': initialDuration
    };
    _running = true;
    _isolate = await Isolate.spawn(_checkTimer, map);
    //_receivePort.sendPort.send(initialDuration);
    try {
      _receivePort.listen(_handleMessage);
    } catch (error) {
      debugPrint('Already listening to port.');
    }
  }

  static void _checkTimer(Map map) async {
    int initialTime = map['initialDuration'];
    SendPort sendPort = map['port'];
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      int hours = initialTime ~/ 3600;
      int minutes = (initialTime ~/ 60) % 60;
      int seconds = initialTime % 60;
      String msg = '$hours:$minutes:${seconds.toString().padLeft(2, '0')}';
      initialTime--;

      if (initialTime == 0) {
        t.cancel();
      }
      debugPrint('SEND: $msg');
      sendPort.send(msg);
    });
  }

  void _handleMessage(dynamic data) {
    debugPrint('RECEIVED: $data');
    setState(() {
      notification = "$data";
    });
    if (data == '0:00:00') {
      _stop();
      debugPrint("Done!");
    }
  }

  void _stop() {
    if (_isolate != null) {
      setState(() {
        _running = false;
        notification = '';
        initialDuration = 0;
        _controller.text = '';
      });
      //_receivePort.close();
      _isolate!.kill(priority: Isolate.immediate);
      _isolate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _controller,
              onEditingComplete: () {
                setState(() {
                  initialDuration = int.parse(_controller.text);
                  debugPrint("Last: $initialDuration");
                });
              },
            ),
            Text(
              notification.isEmpty ? "0:00:00" : notification,
              style: const TextStyle(fontSize: 30),
            ),
            ElevatedButton(onPressed: () async {
              int result = 0;
              result = await showDialog(context: context,
                builder: (context) {
                  return TimePicker(
                    deviceHeight: deviceHeight,
                    deviceWidth: deviceWidth,
                  );
                },
              );
              setState(() {
                initialDuration = result;
                _controller.text = initialDuration.toString();
              });
            }, child: const Text("Set Timer") ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _running ? _stop : _start,
        tooltip: _running ? 'Timer stop' : 'Timer start',
        child: _running ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
      ),
    );
  }
}