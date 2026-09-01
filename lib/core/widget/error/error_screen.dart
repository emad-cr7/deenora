import 'package:flutter/material.dart';

enum AppErrorType {
  noInternet,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  serverError,
  unknown,
}

class AppErrorScreen extends StatelessWidget {
  final AppErrorType type;
  final VoidCallback? onRetry;

  const AppErrorScreen({super.key, required this.type, this.onRetry});

  IconData get icon {
    switch (type) {
      case AppErrorType.noInternet:
        return Icons.wifi_off_rounded;

      case AppErrorType.timeout:
        return Icons.timer_off_outlined;

      case AppErrorType.badRequest:
        return Icons.warning_amber_rounded;

      case AppErrorType.unauthorized:
        return Icons.lock_outline_rounded;

      case AppErrorType.forbidden:
        return Icons.block_rounded;

      case AppErrorType.notFound:
        return Icons.search_off_rounded;

      case AppErrorType.serverError:
        return Icons.cloud_off_rounded;

      case AppErrorType.unknown:
        return Icons.error_outline_rounded;
    }
  }

  String get title {
    switch (type) {
      case AppErrorType.noInternet:
        return 'No Internet Connection';

      case AppErrorType.timeout:
        return 'Request Timeout';

      case AppErrorType.badRequest:
        return 'Bad Request';

      case AppErrorType.unauthorized:
        return 'Unauthorized';

      case AppErrorType.forbidden:
        return 'Access Denied';

      case AppErrorType.notFound:
        return 'Not Found';

      case AppErrorType.serverError:
        return 'Server Error';

      case AppErrorType.unknown:
        return 'Something Went Wrong';
    }
  }

  String get message {
    switch (type) {
      case AppErrorType.noInternet:
        return 'Please check your internet connection and try again.';

      case AppErrorType.timeout:
        return 'The request took too long. Please try again.';

      case AppErrorType.badRequest:
        return 'The request could not be processed.';

      case AppErrorType.unauthorized:
        return 'You are not authorized to access this data.';

      case AppErrorType.forbidden:
        return 'You do not have permission to access this data.';

      case AppErrorType.notFound:
        return 'The requested data could not be found.';

      case AppErrorType.serverError:
        return 'The server is currently unavailable. Please try again later.';

      case AppErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 70, color: Colors.redAccent),

            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),

            if (onRetry != null) ...[
              const SizedBox(height: 28),

              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 21),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E4F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
