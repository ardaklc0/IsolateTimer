import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  late double progress = 0;
  late double currentTimeInMinutes;
  String targetTime = "";
  late String currentTimeDisplay;
  int minuteDifference = 0;
  int secondDifference = 0;
  String text = "Start Timer";
  FlutterBackgroundService service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    service.startService();
    currentTimeDisplay = "";
    super.initState();
  }
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
                String currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString().padLeft(2, "0")}:00";
                if (isRunning) {
                  minuteDifference = DateTime.parse(targetTime).difference(time!).inMinutes;
                  secondDifference = DateTime.parse(targetTime).difference(time).inSeconds % 60;
                  currentTimeDisplay = "${minuteDifference.toString().padLeft(2,"0")}:${secondDifference.toString().padLeft(2,"0")}";
                  currentTimeInMinutes = minuteDifference.toDouble() + (secondDifference.toDouble() / 60);
                  progress = 1 -
                      (timerProvider.maxTimeInMinutes != 0 ? currentTimeInMinutes / timerProvider.maxTimeInMinutes : 5);
                }
                flutterLocalNotificationsPlugin.show(
                  888,
                  'Remaining Time',
                  'Countdown: $currentTimeDisplay',
                  const NotificationDetails(
                    android: AndroidNotificationDetails(
                      'my_foreground',
                      'MY FOREGROUND SERVICE',
                      icon: 'ic_bg_service_small',
                      ongoing: true,
                    ),
                  ),
                );
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text("time: $time"),
                    Divider(),
                    //Text("targetDateTime: $targetTime"),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.shortestSide * 0.5,
                          width: MediaQuery.of(context).size.shortestSide * 0.5,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                strokeWidth: 15.0,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                                backgroundColor: const Color.fromRGBO(242, 245, 234, 1),
                                value: progress,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    currentTimeDisplay,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                ],
                              ),
                            ]
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Divider(),
            ElevatedButton(
              child: const Text("Reset Timer"),
              onPressed: () {
                setState(() {
                  isRunning = false;
                  targetTime = "";
                  currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
                  progress = 0;
                });

              },
            ),
            ElevatedButton(
              child: const Text("Start Timer"),
              onPressed: () async {
                setState(() {
                  isRunning = true;
                  targetTime = DateTime.now().add(Duration(minutes: timerProvider.maxTimeInMinutes)).toString();
                });
              },
            ),
            //Text(timerProvider.maxTimeInMinutes.toString()),
            Divider(),
            const TimeandRoundWidget(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final service = FlutterBackgroundService();
          service.invoke("stopService");
          Navigator.pop(context);
        },
        child: const Icon(Icons.home_filled),
      )
    );
  }
}
