import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/hadith_day_model.dart';

class HadithDetailsBottomSheet extends StatelessWidget {
  final HadithDayModel hadith;

  const HadithDetailsBottomSheet({super.key, required this.hadith});

  static Future<void> show(BuildContext context, HadithDayModel hadith) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => HadithDetailsBottomSheet(hadith: hadith),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: hadith.textArabic));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Hadith copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareHadith() {
    final attribution = StringBuffer(
      '— ${_formatCollection(hadith.collection)} • Hadith ${hadith.hadithNumber}',
    );
    if (hadith.bookNumber.isNotEmpty) {
      attribution.write(' (Book ${hadith.bookNumber})');
    }
    attribution.write(' —');

    final shareText = '« ${hadith.textArabic} »\n\n$attribution';
    SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    final chapterTitle = hadith.chapterTitleAr.isNotEmpty
        ? hadith.chapterTitleAr
        : hadith.chapterTitleEn;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  const Icon(
                    FlutterIslamicIcons.islam,
                    color: AppColors.darkGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hadith of the Day',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.darkGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: AppColors.textMuted,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),

              const Divider(color: AppColors.borderSubtle, height: 20),

              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Chapter Title (if available)
                      if (chapterTitle.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.amberGold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.amberGold.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Text(
                            chapterTitle,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],

                      // Hadith Text (Arabic)
                      Text(
                        '« ${hadith.textArabic} »',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(context),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.darkGold,
                        side: const BorderSide(color: AppColors.amberGold),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareHadith,
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatCollection(String slug) {
    switch (slug.toLowerCase().trim()) {
      case 'bukhari':
        return 'Sahih al-Bukhari';
      case 'muslim':
        return 'Sahih Muslim';
      case 'nasai':
        return "Sunan an-Nasa'i";
      case 'tirmidhi':
        return "Jami` at-Tirmidhi";
      case 'abudawud':
        return 'Sunan Abi Dawud';
      case 'ibnmajah':
        return 'Sunan Ibn Majah';
      case 'malik':
        return 'Muwatta Malik';
      case 'ahmad':
        return 'Musnad Ahmad';
      default:
        if (slug.isEmpty) return 'Hadith';
        return slug[0].toUpperCase() + slug.substring(1);
    }
  }
}
