import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:isolate_timer/provider/slider_provider.dart';
import 'package:isolate_timer/provider/time_provider.dart';
import 'package:isolate_timer/widgets/slider_widgets.dart';
import 'package:provider/provider.dart';

class TestCountdown extends StatefulWidget {
  const TestCountdown({super.key});

  @override
  State<TestCountdown> createState() => _TestCountdownState();
}

class _TestCountdownState extends State<TestCountdown> {
  bool isRunning = false;
  String targetTime = "";
  String currentTimeDisplay = "";
  int minuteDifference = 0;
  int secondDifference = 0;

  @override
  Widget build(BuildContext context) {
    TimerProvider timerProvider = Provider.of<TimerProvider>(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    Text(device ?? 'Unknown'),
                    Text("time: $time"),
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
                  currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
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
            Text(timerProvider.maxTimeInMinutes.toString()),
            const TimeandRoundWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Icon(Icons.home_filled),
      )
    );
  }
}
