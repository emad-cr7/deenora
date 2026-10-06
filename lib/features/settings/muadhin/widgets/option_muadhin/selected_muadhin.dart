import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widget/error/error_screen.dart';
import '../../controllers/muadhin_controller.dart';
import '../muadhin_card/muadhin_card.dart';
import '../../../../../core/skeleton/muadhin_skeleton.dart';

class SelectedMuadhin extends StatelessWidget {
  final MuadhinController controller;

  const SelectedMuadhin({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.isLoading) {
      return const MuadhinSkeleton();
    }

    if (controller.hasError) {
      return AppErrorScreen(
        type: controller.errorType,
        onRetry: controller.retry,
      );
    }

    final muadhins = controller.currentMuadhins;

    if (muadhins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_off_rounded,
                  size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                'No recordings available currently',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      itemCount: muadhins.length,
      itemBuilder: (context, index) {
        final muadhin = muadhins[index];
        return MuadhinCard(
          key: ValueKey('${muadhin.id}_${controller.selectedType.name}'),
          muadhin: muadhin,
          selectedType: controller.selectedType,
          isExpanded: controller.isExpanded(muadhin.id),
          isPlaying: controller.playerController
              .isTrackPlaying(muadhin.id, controller.selectedType),
          playerController: controller.playerController,
          onTap: () => controller.toggleExpand(muadhin),
        );
      },
    );
  }
}
