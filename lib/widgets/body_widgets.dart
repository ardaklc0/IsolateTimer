import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/settings_page.dart';
import '../provider/time_provider.dart';

class MediaButtons extends StatefulWidget {
  const MediaButtons({
    super.key,
  });

  @override
  State<MediaButtons> createState() => _MediaButtonsState();
}

class _MediaButtonsState extends State<MediaButtons> {
  @override
  Widget build(BuildContext context) {
    void navigateSettingsPage() {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => const SettingsPage(),
      ));
    }
    final timerProvider = Provider.of<TimerProvider>(context);
    final deviceHeight = MediaQuery.of(context).size.height;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {
            if (timerProvider.isRunning) {
              timerProvider.toggleTimer();
              timerProvider.resetTimer();
            }
          },
          icon: Icon(Icons.replay,
              size: deviceHeight * 0.04),
        ),
        IconButton(
          onPressed: () async {
            timerProvider.toggleTimer();
            timerProvider.setTargetTime();
          },
          icon: Icon(
            timerProvider.isRunning ? Icons.pause : Icons.play_arrow,
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
    );
  }
}

