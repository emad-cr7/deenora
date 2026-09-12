import 'package:flutter/material.dart';
import '../../../../reading/models/surah_model.dart';

class SurahSequenceBar extends StatelessWidget {
  final bool hasPrevious;
  final SurahModel? previousSurah;
  final VoidCallback? onPreviousPressed;
  final bool hasNext;
  final SurahModel? nextSurah;
  final VoidCallback? onNextPressed;

  const SurahSequenceBar({
    super.key,
    required this.hasPrevious,
    this.previousSurah,
    this.onPreviousPressed,
    required this.hasNext,
    this.nextSurah,
    this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _SurahSequenceItem(
            isPrevious: true,
            isEnabled: hasPrevious,
            surah: previousSurah,
            onPressed: onPreviousPressed,
          ),
          Container(
            height: 28,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            color: Colors.grey[200],
          ),
          _SurahSequenceItem(
            isPrevious: false,
            isEnabled: hasNext,
            surah: nextSurah,
            onPressed: onNextPressed,
          ),
        ],
      ),
    );
  }
}

// عنصر تنقل فردي للسورة السابقة أو التالية
class _SurahSequenceItem extends StatelessWidget {
  final bool isPrevious;
  final bool isEnabled;
  final SurahModel? surah;
  final VoidCallback? onPressed;

  const _SurahSequenceItem({
    required this.isPrevious,
    required this.isEnabled,
    required this.surah,
    required this.onPressed,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    final title = isPrevious ? 'Previous' : 'Next';
    final fallbackText = isPrevious ? 'Start of Quran' : 'End of Quran';
    final surahText = isEnabled && surah != null
        ? '${surah!.number}. ${surah!.englishName}'
        : fallbackText;

    final icon = Icon(
      isPrevious
          ? Icons.arrow_back_ios_rounded
          : Icons.arrow_forward_ios_rounded,
      size: 13,
      color: isEnabled ? primaryColor : Colors.grey[350],
    );

    final textColumn = Expanded(
      child: Column(
        crossAxisAlignment:
            isPrevious ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isEnabled ? primaryColor : Colors.grey[400],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            surahText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isEnabled ? const Color(0xFF1B1B1B) : Colors.grey[400],
            ),
          ),
        ],
      ),
    );

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: isEnabled ? onPressed : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
          child: Row(
            mainAxisAlignment:
                isPrevious ? MainAxisAlignment.start : MainAxisAlignment.end,
            children: isPrevious
                ? [icon, const SizedBox(width: 6), textColumn]
                : [textColumn, const SizedBox(width: 6), icon],
          ),
        ),
      ),
    );
  }
}
