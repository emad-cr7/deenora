import 'package:flutter/material.dart';

// واجهة عرض الخطأ في تحميل التلاوة مع زر إعادة المحاولة
class PlayerErrorView extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const PlayerErrorView({super.key, this.errorMessage, required this.onRetry});

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
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // زر إعادة المحاولة
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                'Retry',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
