import 'package:flutter/material.dart';
import 'package:isolate_timer/provider/slider_provider.dart';
import 'package:isolate_timer/provider/time_provider.dart';
import 'dart:async';
import 'package:isolate_timer/test.dart';
import 'package:isolate_timer/widgets/test_widgets.dart';
import 'package:provider/provider.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  final sliderProvider = SliderProvider();
  runApp(MultiProvider(providers: [
        ChangeNotifierProvider.value(value: sliderProvider),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
      ],
      child: const MyApp()
    )
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      home: TestApp(),
    );
  }
}
