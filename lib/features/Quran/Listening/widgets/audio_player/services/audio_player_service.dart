import 'dart:async';
import 'package:just_audio/just_audio.dart';

import 'audio_background_handler.dart';

// خدمة إدارة مشغل الصوت ومصادره والتحكم بالتشغيل
class AudioPlayerService {
  final AudioPlayer _player;

  AudioPlayerService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  // الحصول على كائن مشغل الصوت الداخلي عند الحاجة
  AudioPlayer get player => _player;

  // تدفقات حالة المشغل وموقع الصوت
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;

  // الخصائص الحالية للمشغل
  Duration get duration => _player.duration ?? Duration.zero;
  Duration get position => _player.position;
  Duration get bufferedPosition => _player.bufferedPosition;
  double get speed => _player.speed;
  LoopMode get loopMode => _player.loopMode;
  bool get isPlaying => _player.playing;
  bool get isLooping => _player.loopMode == LoopMode.one;

  // تحميل مصدر الصوت وتحديث البيانات التعريفية للخلفية
  Future<void> loadAudioSource({
    required String url,
    required String title,
    required String artist,
    String album = 'The Holy Quran',
  }) async {
    await _player.setAudioSource(
      AudioSource.uri(
        Uri.parse(url),
        tag: AudioBackgroundHandler.buildMediaItem(
          url: url,
          title: title,
          artist: artist,
          album: album,
        ),
      ),
    );
  }

  // بدء تشغيل الصوت
  Future<void> play() => _player.play();

  // إيقاف الصوت مؤقتاً
  Future<void> pause() => _player.pause();

  // الانتقال إلى موضع زمني محدد
  Future<void> seek(Duration targetPosition) => _player.seek(targetPosition);

  // إرجاع الصوت للخلف بمدة محددة
  Future<void> rewind(Duration offset) async {
    final newPosition = _player.position - offset;
    await _player.seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  // تقديم الصوت للأمام بمدة محددة
  Future<void> forward(Duration offset) async {
    final maxDuration = _player.duration ?? Duration.zero;
    final newPosition = _player.position + offset;
    await _player.seek(newPosition > maxDuration ? maxDuration : newPosition);
  }

  // ضبط سرعة التشغيل
  Future<void> setSpeed(double newSpeed) => _player.setSpeed(newSpeed);

  // ضبط وضع تكرار الصوت
  Future<void> setLoopMode(LoopMode mode) => _player.setLoopMode(mode);

  // تنظيف موارد المشغل
  Future<void> dispose() => _player.dispose();
}
