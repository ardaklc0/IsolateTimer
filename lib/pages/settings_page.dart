import 'package:flutter/material.dart';

import '../widgets/slider_widgets.dart';



class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TimeandRoundWidget(),
          //NotificationSoundWidget(),
          //SettingsNotificationSwitch(),
          //AutoStartSwitch(),
        ],
      ),
      floatingActionButton: _floatingActionButton(const Color.fromRGBO(242, 245, 234, 1), context),
    );
  }
}

Widget _floatingActionButton(Color floatingActionButtonColor, BuildContext context) => FloatingActionButton(
  backgroundColor: floatingActionButtonColor,
  child: const Icon(Icons.home),
  onPressed: () {
    Navigator.pop(context);
  },
);