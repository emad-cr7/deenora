import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'main/main_screen.dart';
import 'core/data/local_data/hive_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager().init();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.deenora.app.channel.audio',
    androidNotificationChannelName: 'تشغيل التلاوة',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarThemeData(
          backgroundColor: Color(0xFF1B5E4F),
          centerTitle: true,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(fontWeight: FontWeight.bold , fontSize: 22),
        ),
        scaffoldBackgroundColor: Color(0xFFF6F8F7),
      ),
      title: 'Deenora',
      home: MainScreen(),
    );
  }
}
