import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audio_service/audio_service.dart';

class AudioBackgroundHandler {
  AudioBackgroundHandler._();

  static final Map<String, Uri> _artworkCache = {};

  /// Caches a bundled asset image to a temporary file so that Android's MediaSession
  /// and NotificationCompat can load it as a native Uri.file.
  static Future<Uri?> resolveArtworkUri(String? assetPath) async {
    if (assetPath == null || assetPath.isEmpty) return null;

    if (_artworkCache.containsKey(assetPath)) {
      return _artworkCache[assetPath];
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final fileName = assetPath.split('/').last;
      final file = File('${tempDir.path}/$fileName');

      if (!await file.exists()) {
        await file.writeAsBytes(
          byteData.buffer.asUint8List(
            byteData.offsetInBytes,
            byteData.lengthInBytes,
          ),
        );
      }

      final uri = Uri.file(file.path);
      _artworkCache[assetPath] = uri;
      return uri;
    } catch (e) {
      debugPrint('Error resolving artwork URI for $assetPath: $e');
      return null;
    }
  }

  /// Builds a rich [MediaItem] metadata object for notification and lock screen controls
  static MediaItem buildMediaItem({
    required String id,
    required String title,
    required String artist,
    String? arabicSurahName,
    String? arabicReciterName,
    String album = 'القرآن الكريم',
    Duration? duration,
    Uri? artUri,
  }) {
    final displayTitle = arabicSurahName != null && arabicSurahName.isNotEmpty
        ? '$title ($arabicSurahName)'
        : title;

    final displaySubtitle =
        arabicReciterName != null && arabicReciterName.isNotEmpty
            ? '$artist - $arabicReciterName'
            : artist;

    return MediaItem(
      id: id,
      album: album,
      title: displayTitle,
      artist: displaySubtitle,
      duration: duration,
      artUri: artUri,
      displayTitle: displayTitle,
      displaySubtitle: displaySubtitle,
      displayDescription: 'تلاوة مباركة بصوت القارئ $artist',
    );
  }
}
