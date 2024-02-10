import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isolate_timer/pages/audio_provider.dart';
import 'package:isolate_timer/provider/slider_provider.dart';
import 'package:isolate_timer/provider/time_provider.dart';
import 'package:isolate_timer/widgets/body_widgets.dart';
import 'package:isolate_timer/widgets/slider_widgets.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';

class TestCountdown extends StatefulWidget {
  const TestCountdown({super.key});
  @override
  State<TestCountdown> createState() => _TestCountdownState();
}
class _TestCountdownState extends State<TestCountdown> {
  double progress = 0;
  bool isRunning = false;
  late double currentTimeInMinutes;
  late String currentTimeDisplay;
  int minuteDifference = 0;
  int secondDifference = 0;
  late DateTime targetTime;
  FlutterBackgroundService service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    service.startService();
    currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    TimerProvider timerProvider = Provider.of<TimerProvider>(context);
    SoundSelectionProvider soundSelectionProvider = Provider.of<SoundSelectionProvider>(context);
    void navigateSettingsPage() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ));
    }
    final deviceHeight = MediaQuery.of(context).size.height;
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
                  minuteDifference = targetTime.difference(time!).inMinutes;
                  secondDifference = targetTime.difference(time).inSeconds % 60;

                  currentTimeDisplay = "${minuteDifference.toString().padLeft(2,"0")}:${secondDifference.toString().padLeft(2,"0")}";
                  currentTimeInMinutes = minuteDifference.toDouble() + (secondDifference.toDouble() / 60);
                  progress = 1-(timerProvider.maxTimeInMinutes != 0 ? currentTimeInMinutes / timerProvider.maxTimeInMinutes : 5);

                  if (minuteDifference <= 0 && secondDifference <= 0) {
                    currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
                    progress = 0;
                    timerProvider.toggleTimer();
                    soundSelectionProvider.playSelectedAudio();
                  }
                }
                return Column(
                  children: [
                    Text(device ?? 'Unknown'),
                    Text("time: $time"),
                    const Divider(),
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
                                    isRunning ? currentTimeDisplay : timerProvider.currentTimeDisplay,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    //if (timerProvider.isRunning) {
                    //  timerProvider.toggleTimer();
                    //  timerProvider.resetTimer();
                    //}
                    setState(() {
                      isRunning = false;
                      currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
                      progress = 0;
                    });
                    print("RESET");
                  },
                  icon: Icon(Icons.replay,
                      size: deviceHeight * 0.04),
                ),
                IconButton(
                  onPressed: () async {
                    //timerProvider.toggleTimer();
                    //timerProvider.setTargetTime();
                    if (!isRunning) {
                      setState(() {
                        isRunning = true;
                        targetTime = DateTime.now().add(Duration(minutes: timerProvider.maxTimeInMinutes));
                      });
                      print("START");
                    } else {
                      setState(() {
                        if (timerProvider.maxTimeInMinutes * 60 - currentTimeInMinutes * 60 >= 10) {
                          print("YOU CANNOT PAUSE");
                        } else {
                          isRunning = false;
                          targetTime = DateTime.now().add(Duration(minutes: timerProvider.maxTimeInMinutes));
                          progress = 0;
                        }
                      });
                      print("PAUSE");
                    }
                  },
                  icon: Icon(
                    isRunning ? Icons.pause : Icons.play_arrow,
                    size: deviceHeight * 0.04,
                  ),
                ),
                IconButton(
                  onPressed: !timerProvider.isRunning ? navigateSettingsPage : null,
                  icon: Icon(
                    Icons.settings,
                    size: deviceHeight * 0.04,
                  ),
                )
              ],
            ),
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
