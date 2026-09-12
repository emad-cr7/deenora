import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

// صف أزرار التحكم الرئيسية بالتشغيل (السابقة، تقديم/تأخير، تشغيل/إيقاف، التالية)
class PlayerControlsRow extends StatelessWidget {
  final Stream<PlayerState> playerStateStream;
  final bool isLoadingSurah;
  final bool hasPrevious;
  final VoidCallback? onPreviousPressed;
  final bool hasNext;
  final VoidCallback? onNextPressed;
  final VoidCallback onRewindPressed;
  final VoidCallback onForwardPressed;
  final ValueChanged<bool> onPlayPausePressed;

  const PlayerControlsRow({
    super.key,
    required this.playerStateStream,
    required this.isLoadingSurah,
    required this.hasPrevious,
    this.onPreviousPressed,
    required this.hasNext,
    this.onNextPressed,
    required this.onRewindPressed,
    required this.onForwardPressed,
    required this.onPlayPausePressed,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // زر السورة السابقة مع التعطيل الصريح عند السورة الأولى
        IconButton(
          iconSize: 34,
          tooltip: 'Previous Surah',
          color: primaryColor,
          disabledColor: Colors.grey[300],
          icon: const Icon(Icons.skip_previous_rounded),
          onPressed: hasPrevious && !isLoadingSurah ? onPreviousPressed : null,
        ),

        // زر التقديم 10 ثواني للخلف
        IconButton(
          iconSize: 28,
          tooltip: 'Rewind 10s',
          color: primaryColor,
          icon: const Icon(Icons.replay_10_rounded),
          onPressed: onRewindPressed,
        ),

        // زر التشغيل والإيقاف المؤقت
        _PlayPauseButton(
          playerStateStream: playerStateStream,
          isLoadingSurah: isLoadingSurah,
          onPlayPausePressed: onPlayPausePressed,
        ),

        // زر التقديم 10 ثواني للأمام
        IconButton(
          iconSize: 28,
          tooltip: 'Forward 10s',
          color: primaryColor,
          icon: const Icon(Icons.forward_10_rounded),
          onPressed: onForwardPressed,
        ),

        // زر السورة التالية مع التعطيل الصريح عند السورة الأخيرة
        IconButton(
          iconSize: 34,
          tooltip: 'Next Surah',
          color: primaryColor,
          disabledColor: Colors.grey[300],
          icon: const Icon(Icons.skip_next_rounded),
          onPressed: hasNext && !isLoadingSurah ? onNextPressed : null,
        ),
      ],
    );
  }
}

// زر التشغيل والإيقاف المؤقت الدائري المتوهج مع مؤشر التحميل
class _PlayPauseButton extends StatelessWidget {
  final Stream<PlayerState> playerStateStream;
  final bool isLoadingSurah;
  final ValueChanged<bool> onPlayPausePressed;

  const _PlayPauseButton({
    required this.playerStateStream,
    required this.isLoadingSurah,
    required this.onPlayPausePressed,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);
  static const Color primaryDark = Color(0xFF103D33);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 66,
      height: 66,
      child: StreamBuilder<PlayerState>(
        stream: playerStateStream,
        builder: (context, snapshot) {
          final playing = snapshot.data?.playing ?? false;
          final processingState = snapshot.data?.processingState;

          // التحقق من حالة التحميل أو التخزين المؤقت
          final isBufferingOrLoading =
              (processingState == ProcessingState.loading ||
                      processingState == ProcessingState.buffering) &&
                  (playing || isLoadingSurah);

          final isLoading = isLoadingSurah ||
              (isBufferingOrLoading &&
                  processingState != ProcessingState.completed);

          return Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor, primaryDark],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: isLoading
                ? Center(
                    child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                : IconButton(
                    iconSize: 36,
                    color: Colors.white,
                    icon: Icon(
                      playing
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                    ),
                    onPressed: () => onPlayPausePressed(playing),
                  ),
          );
        },
      ),
    );
  }
}
