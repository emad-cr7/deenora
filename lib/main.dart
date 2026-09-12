import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'main/main_screen.dart';
import 'core/theme/app_colors.dart';
import 'core/data/local_data/hive_manager.dart';

import 'package:provider/provider.dart';
import 'features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'features/Quran/Listening/widgets/audio_player/services/quran_audio_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager().init();

  final audioHandler = await AudioService.init(
    builder: () => QuranAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.deenora.app.channel.audio',
      androidNotificationChannelName: 'تشغيل التلاوة',
      androidNotificationChannelDescription: 'التحكم في تشغيل تلاوة القرآن الكريم',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
      androidShowNotificationBadge: true,
    ),
  );

  runApp(MyApp(audioHandler: audioHandler));
}

class MyApp extends StatelessWidget {
  final QuranAudioHandler audioHandler;

  const MyApp({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioPlayerCoordinator>(
      create: (_) => AudioPlayerCoordinator(audioHandler: audioHandler)..init(),
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            centerTitle: true,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          scaffoldBackgroundColor: const Color(0xFFF6F8F7),
        ),
        title: 'Deenora',
        home: const MainScreen(),
      ),
    );
  }
}
