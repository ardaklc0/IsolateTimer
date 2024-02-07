import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:isolate_timer/provider/time_provider.dart';
import 'package:isolate_timer/widgets/slider_widgets.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class TestApp extends StatefulWidget {
  const TestApp({Key? key}) : super(key: key);

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  String text = "Stop Service";
  bool isRunning = false;
  String targetTime = "";
  String currentTimeDisplay = "";
  int minuteDifference = 0;
  int secondDifference = 0;

  @override
  Widget build(BuildContext context) {
    final TimerProvider timerProvider = Provider.of<TimerProvider>(context);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Service App'),
        ),
        body: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: FlutterBackgroundService().on('update'),
              builder: (context, snapshot) {
               if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
               }
               final data = snapshot.data!;
               String? device = data["device"];
               DateTime? time = DateTime.tryParse(data["current_date"]);

               if (isRunning) {
                 minuteDifference = DateTime.parse(targetTime).difference(time!).inMinutes;
                 secondDifference = DateTime.parse(targetTime).difference(time).inSeconds % 60;
                 currentTimeDisplay = "${minuteDifference.toString().padLeft(2,"0")}:${secondDifference.toString().padLeft(2,"0")}";
               }
               return Column(
                 children: [
                   //Text(device ?? 'Unknown'),
                   //Text("time: $time"),
                   //Text("targetDateTime: $targetTime"),
                   Text(
                     currentTimeDisplay,
                     style: const TextStyle(fontSize: 30),
                   ),
                 ],
               );
              },
            ),
            ElevatedButton(
              child: const Text("Reset Timer"),
              onPressed: () {
                setState(() {
                  isRunning = false;
                  targetTime = "";
                  currentTimeDisplay = "00:00";
                });
              },
            ),
            ElevatedButton(
              child: const Text("Resume Timer"),
              onPressed: () {
                setState(() {

                });
              },
            ),
            ElevatedButton(
              child: const Text("Start Timer"),
              onPressed: () {
                setState(() {
                  isRunning = true;
                  targetTime = DateTime.now().add(Duration(minutes: timerProvider.maxTimeInMinutes)).toString();
                });
              },
            ),
            ElevatedButton(
              child: const Text("Foreground Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsForeground");
              },
            ),
            ElevatedButton(
              child: const Text("Background Mode"),
              onPressed: () {
                FlutterBackgroundService().invoke("setAsBackground");
              },
            ),
            ElevatedButton(
              child: Text(text),
              onPressed: () async {
                final service = FlutterBackgroundService();
                var isRunning = await service.isRunning();
                if (isRunning) {
                  service.invoke("stopService");
                } else {
                  service.startService();
                }

                if (!isRunning) {
                  text = 'Stop Service';
                } else {
                  text = 'Start Service';
                }
                setState(() {});
              },
            ),
            Text(timerProvider.maxTimeInMinutes.toString()),
            TimeandRoundWidget()
          ],
        ),
      ),
    );
  }
}

class LogView extends StatefulWidget {
  const LogView({Key? key}) : super(key: key);

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  late final Timer timer;
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final SharedPreferences sp = await SharedPreferences.getInstance();
      await sp.reload();
      logs = sp.getStringList('log') ?? [];
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs.elementAt(index);
        return Text(log);
      },
    );
  }
}