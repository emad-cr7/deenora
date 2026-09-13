import 'package:audio_service/audio_service.dart';

import '../../features/Quran/Listening/widgets/audio_player/services/quran_audio_handler.dart';

Future<QuranAudioHandler> initAudioService() async {
  return await AudioService.init(
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
}