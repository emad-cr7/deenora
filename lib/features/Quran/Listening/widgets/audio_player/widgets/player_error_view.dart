import 'package:flutter/material.dart';

// واجهة عرض الخطأ في تحميل التلاوة مع زر إعادة المحاولة
class PlayerErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const PlayerErrorView({
    super.key,
    this.errorMessage,
    required this.onRetry,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة التنبيه بالخطأ
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 18),

            // نص رسالة الخطأ
            Text(
              errorMessage ?? 'Failed to play recitation. Please try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B1B1B),
              ),
            ),
            const SizedBox(height: 20),

            // زر إعادة المحاولة
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'Retry',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
