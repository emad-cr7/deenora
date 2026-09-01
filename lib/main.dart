import 'package:flutter/material.dart';
import 'main/main_screen.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarThemeData(backgroundColor: Color(0xff003527)),
        scaffoldBackgroundColor: Color(0xFFF6F3EE)
      ),
      title: 'Deenora',
      home: MainScreen(),
    );
  }
}
