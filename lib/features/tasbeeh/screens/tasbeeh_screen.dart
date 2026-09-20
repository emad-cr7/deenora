import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widget/error/error_screen.dart';
import '../controllers/tasbeeh_controller.dart';
import '../widgets/buttons/counter_button.dart';
import '../widgets/buttons/tasbeeh_actions_bar.dart';
import '../widgets/cards/dhikr_card.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/display/counter_display.dart';
import '../widgets/skeletons/tasbeeh_skeleton.dart';
import 'tasbeeh_selection_screen.dart';

class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      Provider.of<TasbeehController>(context, listen: false);
      return const _TasbeehScreenContent();
    } catch (_) {
      return ChangeNotifierProvider<TasbeehController>(
        create: (_) => TasbeehController()..init(),
        child: const _TasbeehScreenContent(),
      );
    }
  }
}

class _TasbeehScreenContent extends StatelessWidget {
  const _TasbeehScreenContent();

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
                  return Center(
                    child: Text(
                      'No dhikr data available.',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                }

                // 3. Loaded State
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 30,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              DhikrCard(
                                dhikr: currentDhikr,
                                currentIndex: controller.selectedIndex,
                                totalCount: controller.dhikrList.length,
                                customTarget: currentDhikr.narratedCount == null
                                    ? controller.targetCount
                                    : null,
                                isCustom: currentDhikr.isCustom,
                              ),

                              const SizedBox(height: 10),

                              CounterDisplay(
                                count: controller.count,
                                targetCount: controller.targetCount,
                                hasTarget: controller.hasTarget,
                                isCompleted: controller.isCompleted,
                                progress: controller.progress,
                              ),

                              const SizedBox(height: 50),

                              CounterButton(
                                onTap: controller.increment,
                                isCompleted: controller.isCompleted,
                              ),

                              const Spacer(),

                              TasbeehActionsBar(
                                onReset: () => showDialog(
                                  context: context,
                                  builder: (_) => ConfirmDialog(
                                    title: 'Reset Counter?',
                                    content:
                                        'Are you sure you want to reset the current count back to 0?',
                                    confirmText: 'Reset',
                                    onConfirm: controller.reset,
                                  ),
                                ),
                                onPrevious: controller.previousDhikr,
                                onNext: controller.nextDhikr,
                                onSelectDhikr: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ChangeNotifierProvider.value(
                                              value: controller,
                                              child:
                                                  const TasbeehSelectionScreen(),
                                            ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
