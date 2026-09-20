import 'package:flutter/material.dart';
import 'core/init_main/init_audio_service.dart';
import 'core/theme/light_theme.dart';
import 'features/main/main_screen.dart';
import 'core/data/local_data/hive_manager.dart';
import 'package:provider/provider.dart';
import 'features/Quran/Listening/widgets/audio_player/controller/audio_player_coordinator.dart';
import 'features/Quran/Listening/widgets/audio_player/services/quran_audio_handler.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveManager().init();
  final audioHandler = await initAudioService();
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
        theme: lightTheme,
        title: 'Deenora',
        home: const MainScreen(),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child!,
          );
        },
      ),
    );
  }
}
