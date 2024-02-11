import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:isolate_timer/pages/audio_provider.dart';
import 'package:isolate_timer/provider/slider_provider.dart';
import 'package:isolate_timer/provider/time_provider.dart';
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
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        isRunning = false;
        bool received = await dialogBuilder(context);
        if (received) {
          if (!context.mounted) return;
          Navigator.pop(context);
        } else {
          isRunning = true;
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<Map<String, dynamic>?>(
                stream: FlutterBackgroundService().on('update'),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.shortestSide * 0.5,
                        width: MediaQuery.of(context).size.shortestSide * 0.5,
                        child: const CircularProgressIndicator(
                          strokeWidth: 15.0,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          backgroundColor: Color.fromRGBO(242, 245, 234, 1),
                        ),
                      ),
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
                      soundSelectionProvider.playSelectedAudio();
                      isRunning = false;
                      Future.delayed(Duration.zero, () {
                        notifyTimerEnd();
                      });
                    }
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
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
                      ),
                    ],
                  );
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedSlide(
                    offset: isRunning ? const Offset(0, 10) : const Offset(0, 0),
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isRunning = false;
                          currentTimeDisplay = "${SliderProvider.studyDurationSliderValue.toString()}:00";
                          progress = 0;
                        });
                      },
                      icon: Icon(Icons.replay,
                          size: deviceHeight * 0.04),
                    ),
                  ),
                  AnimatedSlide(
                    offset: isRunning ? const Offset(0, 10) : const Offset(0, 0),
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: () async {
                        if (!isRunning) {
                          setState(() {
                            isRunning = true;
                            targetTime = DateTime.now().add(Duration(minutes: timerProvider.maxTimeInMinutes));
                          });
                        }
                      },
                      icon: Icon(
                        isRunning ? Icons.pause : Icons.play_arrow,
                        size: deviceHeight * 0.04,
                      ),
                    ),
                  ),
                  AnimatedSlide(
                    offset: isRunning ? const Offset(0, 10) : const Offset(0, 0),
                    curve: Curves.easeInOut,
                    duration: const Duration(milliseconds: 500),
                    child: IconButton(
                      onPressed: !isRunning ? navigateSettingsPage : null,
                      icon: Icon(
                        Icons.settings,
                        size: deviceHeight * 0.04,
                      ),
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
      ),
    );
  }
  void notifyTimerEnd() {
    // Use add() to send the update through the stream
    setState(() {

    });
  }
}

Future<bool> dialogBuilder(BuildContext context) async {
  bool confirm = false;
  Timer? timerCount;
  confirm = await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'Your progress will be deleted. Do you really want to cancel?',
        ),
        actions: <Widget>[
          StatefulBuilder(
            builder: (BuildContext context, setState) {
              timerCount ??= Timer.periodic(const Duration(seconds: 1), (timer) {
                debugPrint(timer.tick.toString());
                if (timer.tick == 10) {
                  timer.cancel();
                  final service = FlutterBackgroundService();
                  service.invoke("stopService");
                  Navigator.of(context).pop(true);
                }
                setState(() {});
              });
              return Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      timerCount?.cancel();
                      final service = FlutterBackgroundService();
                      service.invoke("stopService");
                      Navigator.of(context).pop(true);
                    },
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.labelLarge,
                    ),
                    child: Text(
                      "No, let's continue (${timerCount?.tick ?? 0})",
                      style: const TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    onPressed: () {
                      timerCount?.cancel();
                      Navigator.of(context).pop(false);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      );
    },
  );
  timerCount?.cancel();
  return confirm;
}
