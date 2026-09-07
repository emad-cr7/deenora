import 'package:deenora/features/Azkar/azkar_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/enum/azkar_model/azkar_model.dart';

class AzkarDetailScreen extends StatelessWidget {
  final String title;
  final List<AzkarModel> zekrList;

  const AzkarDetailScreen({
    super.key,
    required this.title,
    required this.zekrList,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AzkarDetailController>(
      create: (BuildContext context) =>
          AzkarDetailController(title, zekrList)..init(),
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: zekrList.isEmpty
            ? const Center(child: Text('لا توجد أذكار في هذا القسم'))
            : SafeArea(
                child: Consumer<AzkarDetailController>(
                  builder:
                      (
                        BuildContext context,
                        AzkarDetailController controller,
                        Widget? child,
                      ) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: zekrList.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final zekr = zekrList[index];
                            final remaining = controller.remainingCounts[index];
                            final isCompleted = remaining == 0;
                            return GestureDetector(
                              onTap: () => controller.decreaseCount(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF0E5B4A).withValues(
                                        alpha: isCompleted ? 0.12 : 0.07,
                                      ),
                                      const Color(0xFFC9A24B).withValues(
                                        alpha: isCompleted ? 0.08 : 0.04,
                                      ),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: isCompleted
                                        ? Colors.green.withValues(alpha: 0.4)
                                        : const Color(
                                            0xFF0E5B4A,
                                          ).withValues(alpha: 0.15),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        zekr.text,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          height: 1.7,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF163B33),
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        transitionBuilder: (child, animation) {
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
                                                      .withValues(alpha: 0.12),
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
                                                      vertical: 7,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFC9A24B,
                                                  ).withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  '$remaining مرة',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF8A6D1D),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
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
