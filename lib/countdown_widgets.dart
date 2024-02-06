import 'dart:async';
import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:isolate_timer/countdown_timer.dart';

class Countdown extends StatefulWidget {
  const Countdown({super.key});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown> {
  late Isolate _isolate;
  bool _running = false;
  static int _maxMinutes = 240;
  String notification = "";
  late ReceivePort _receivePort;

  void _start() async {
    _running = true;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_checkTimer, _receivePort.sendPort);
    _receivePort.listen(_handleMessage, onDone:() {
      debugPrint("done!");
    });
  }

  static void _checkTimer(SendPort sendPort) async {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      _maxMinutes--;
      String msg = 'notification $_maxMinutes';
      debugPrint('SEND: $msg');
      sendPort.send(msg);
    });
  }

  void _handleMessage(dynamic data) {
    debugPrint('RECEIVED: $data');
    setState(() {
      notification = data;
    });
  }

  void _stop() {
    setState(() {
      _running = false;
      notification = '';
    });
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
    }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              notification,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _running ? _stop : _start,
        tooltip: _running ? 'Timer stop' : 'Timer start',
        child: _running ? new Icon(Icons.stop) : new Icon(Icons.play_arrow),
      ),
    );
  }
}
