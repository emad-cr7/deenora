import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../audio_player/controller/audio_player_coordinator.dart';
import '../../audio_player/view/audio_player_view.dart';

class MiniPlayerAvatar extends StatelessWidget {
  const MiniPlayerAvatar({super.key});

  static const double size = 52.0;

  @override
  Widget build(BuildContext context) {
    return Selector<AudioPlayerCoordinator, String>(
      selector: (_, coordinator) => coordinator.reciter.imagePath,
      builder: (context, imagePath, _) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AudioPlayerView()),
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: Colors.white,
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    child: const Center(
                      child: Icon(
                        FlutterIslamicIcons.solidQuran2,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
