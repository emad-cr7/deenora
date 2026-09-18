import 'package:deenora/features/Azkar/azkar_details/azkar_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../azkar_model/azkar_model.dart';

class AzkarDetailsScreen extends StatelessWidget {
  final String title;
  final List<AzkarModel> zekrList;

  const AzkarDetailsScreen({
    super.key,
    required this.title,
    required this.zekrList,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AzkarDetailsController>(
      create: (BuildContext context) =>
          AzkarDetailsController(title, zekrList)..init(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: zekrList.isEmpty
            ? Center(
                child: Text(
                  'لا توجد أذكار في هذا القسم',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            : SafeArea(
                child: Consumer<AzkarDetailsController>(
                  builder:
                      (
                        BuildContext context,
                        AzkarDetailsController controller,
                        Widget? child,
                      ) {
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          itemCount: zekrList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final zekr = zekrList[index];
                            final remaining = controller.remainingCounts[index];
                            final isCompleted = remaining == 0;

                            return GestureDetector(
                              onTap: () => controller.decreaseCount(index),
                              child: Material(
                                color: Colors.transparent,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isCompleted
                                          ? [
                                              Colors.green.withValues(
                                                alpha: 0.08,
                                              ),
                                              Colors.green.withValues(
                                                alpha: 0.03,
                                              ),
                                            ]
                                          : [
                                              AppColors.emerald.withValues(
                                                alpha: 0.07,
                                              ),
                                              AppColors.amberGold.withValues(
                                                alpha: 0.04,
                                              ),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: isCompleted
                                          ? Colors.green.withValues(alpha: 0.3)
                                          : AppColors.emerald.withValues(
                                              alpha: 0.15,
                                            ),
                                      width: 2,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Text(
                                          zekr.text,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineMedium
                                              ?.copyWith(
                                                color: AppColors.deepTeal,
                                              ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Align(
                                        alignment: Alignment.center,
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          transitionBuilder:
                                              (child, animation) {
                                                return ScaleTransition(
                                                  scale: animation,
                                                  child: FadeTransition(
                                                    opacity: animation,
                                                    child: child,
                                                  ),
                                                );
                                              },
                                          child: isCompleted
                                              ? Container(
                                                  key: const ValueKey('done'),
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.green,
                                                    size: 28,
                                                  ),
                                                )
                                              : Container(
                                                  key: ValueKey(remaining),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 10,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.amberGold
                                                        .withValues(
                                                          alpha: 0.12,
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '$remaining مرة',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color: AppColors
                                                              .darkGold,
                                                        ),
                                                  ),
                                                ),
                                        ),
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
      ),
    );
  }
}
