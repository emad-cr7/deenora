import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/error/error_screen.dart';
import 'controllers/tasbeeh_controller.dart';
import 'widgets/counter_button.dart';
import 'widgets/counter_display.dart';
import 'widgets/dhikr_card.dart';
import 'widgets/dhikr_selector_sheet.dart';
import 'widgets/tasbeeh_actions_bar.dart';
import 'widgets/tasbeeh_skeleton.dart';

class TasbeehScreen extends StatelessWidget {
  final TasbeehController? controller;

  const TasbeehScreen({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null) {
      return ChangeNotifierProvider<TasbeehController>.value(
        value: controller!,
        child: const _TasbeehScreenContent(),
      );
    }
    return ChangeNotifierProvider<TasbeehController>(
      create: (_) => TasbeehController()..init(),
      child: const _TasbeehScreenContent(),
    );
  }
}

class _TasbeehScreenContent extends StatelessWidget {
  const _TasbeehScreenContent();

  void _confirmReset(BuildContext context, TasbeehController controller) {
    if (controller.count == 0) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Reset Counter?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: AppColors.deepForest,
            fontSize: 17,
          ),
        ),
        content: const Text(
          'Are you sure you want to reset the current count back to 0?',
          style: TextStyle(fontSize: 14, color: Color(0xFF556861)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              controller.reset();
              Navigator.pop(ctx);
            },
            child: const Text(
              'Reset',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasbeehController>(
      builder: (context, controller, _) {
        final currentDhikr = controller.currentDhikr;

        return Scaffold(
          appBar: AppBar(title: const Text('Tasbeeh')),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                // 1. Initial Loading State
                if (controller.isLoading && currentDhikr == null) {
                  return const TasbeehSkeleton();
                }

                // 2. Error State (No data loaded and error occurred)
                if (controller.hasError && currentDhikr == null) {
                  return AppErrorScreen(
                    type: controller.errorType,
                    onRetry: () => controller.loadDhikr(),
                  );
                }

                if (currentDhikr == null) {
                  return const Center(
                    child: Text(
                      'No dhikr data available.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  );
                }

                // 3. Loaded State with Pull-To-Refresh
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      // Dhikr Hero Card (focused on English Dhikr & meaning)
                      DhikrCard(
                        dhikr: currentDhikr,
                        currentIndex: controller.selectedIndex,
                        totalCount: controller.dhikrList.length,
                        customTarget: currentDhikr.narratedCount == null
                            ? controller.targetCount
                            : null,
                        isCustom: controller.isCustomDhikr(currentDhikr),
                        onPrevious: controller.previousDhikr,
                        onNext: controller.nextDhikr,
                      ),

                      const SizedBox(height: 8),

                      // Numerical Counter and Target Progress
                      CounterDisplay(
                        count: controller.count,
                        targetCount: controller.targetCount,
                        hasTarget: controller.hasTarget,
                        isCompleted: controller.isCompleted,
                        progress: controller.progress,
                      ),

                      const SizedBox(height: 25),

                      // Large Circular Counter Tap Button
                      CounterButton(
                        onTap: controller.increment,
                        isCompleted: controller.isCompleted,
                      ),

                      const SizedBox(height: 30),

                      // Action Toolbar (Reset, Prev, Next, Select Dhikr below)
                      TasbeehActionsBar(
                        onReset: () => _confirmReset(context, controller),
                        onPrevious: controller.previousDhikr,
                        onNext: controller.nextDhikr,
                        onSelectDhikr: () {
                          DhikrSelectorSheet.show(
                            context: context,
                            dhikrList: controller.dhikrList,
                            selectedIndex: controller.selectedIndex,
                            onSelect: controller.selectDhikr,
                            onAddCustom: (text, count) {
                              controller.addCustomDhikr(
                                text: text,
                                count: count,
                              );
                            },
                            attribution: controller.attribution,
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
