import 'package:flutter/material.dart';
import 'package:mmt_auto/src/system/welcome.dart';
import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    MediaKit.ensureInitialized();
    return MaterialApp(
      title: 'MMT_WW',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        checkboxTheme: CheckboxThemeData(
          checkColor: MaterialStateProperty.all(Colors.black),
          fillColor: MaterialStateProperty.all(Colors.white),
        ),
        useMaterial3: true,
      ),
      home:
        WelcomeScreen(),
        // const MainDesktop(),
    );
  }
}
