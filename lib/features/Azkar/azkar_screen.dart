import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/skeleton/azkar_item_skeleton.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widget/error/error_screen.dart';
import '../../core/widget/share_widget/future_builder_share.dart';
import 'azkar_controller.dart';
import 'azkar_details/azkar_details_screen.dart';
import 'azkar_model/azekr_category.dart';
import 'enum_askar/enum_azkar_category.dart';

class AzkarScreen extends StatelessWidget {
  const AzkarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AzkarController>(
      create: (BuildContext context) => AzkarController()..init(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Azkar')),
        body: Consumer<AzkarController>(
          builder:
              (
                BuildContext context,
                AzkarController controller,
                Widget? child,
              ) {
                return FutureBuilderShare<AzekrCategory>(
                  future: controller.azkarFuture,
                  loading: AzkarItemSkeleton(),
                  error: AppErrorScreen(type: AppErrorType.serverError),
                  builder: (model) {
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: AzkarCategory.values.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final category = AzkarCategory.values[index];
                        final count = category.getList(model).length;
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AzkarDetailsScreen(
                                  title: category.englishName,
                                  zekrList: category.getList(model),
                                ),
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.emerald.withValues(alpha: 0.07),
                                    AppColors.amberGold.withValues(alpha: 0.04),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.emerald.withValues(
                                    alpha: 0.15,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.emerald.withValues(
                                        alpha: 0.10,
                                      ),
                                    ),
                                    child: Icon(
                                      category.icon,
                                      size: 26,
                                      color: AppColors.emerald,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          category.englishName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: AppColors.deepTeal,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: AppColors.amberGold
                                                    .withValues(alpha: 0.12),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '$count Dhikr',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelSmall
                                                    ?.copyWith(
                                                      color: AppColors.darkGold,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 20,
                                    color: AppColors.emerald,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
        ),
      ),
    );
  }
}
