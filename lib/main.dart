import 'package:flutter/material.dart';
import 'core/data/remote_data/quran_listening_service.dart';
import 'main/main_screen.dart';
import 'core/data/local_data/hive_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarThemeData(backgroundColor: Color(0xFF1B5E4F)),
        scaffoldBackgroundColor: Color(0xFFF6F3EE),
      ),
      title: 'Deenora',
      home: MainScreen(),
    );
  }
}
