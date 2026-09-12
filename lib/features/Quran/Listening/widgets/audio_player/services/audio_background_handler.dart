import 'package:just_audio_background/just_audio_background.dart';

class AudioBackgroundHandler {
  AudioBackgroundHandler._();

  /// Builds a [MediaItem] metadata object for notification and lock screen controls
  static MediaItem buildMediaItem({
    required String url,
    required String title,
    required String artist,
    String album = 'The Holy Quran',
  }) {
    return MediaItem(
      id: url,
      title: title,
      artist: artist,
      album: album,
      displayTitle: title,
      displaySubtitle: artist,
    );
  }
}
