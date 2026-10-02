import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SharedSegmentedSwitch extends StatelessWidget {
  final TabController controller;
  final List<String> titles;
  final List<IconData> icons;

  const SharedSegmentedSwitch({
    super.key,
    required this.controller,
    required this.titles,
    required this.icons,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: SizedBox(
        height: 45,
        child: Theme(
          data: Theme.of(context).copyWith(
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: SegmentedTabControl(
            controller: controller,
            barDecoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(50),
            ),
            indicatorDecoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(50),
            ),
            tabTextColor: AppColors.textMuted,
            selectedTabTextColor: Colors.white,
            tabs: List.generate(titles.length, (index) {
              return SegmentTab(
                label: titles[index],
                labelBuilder: (context, color) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Icon(icons[index], size: 20, color: color),
                      const SizedBox(width: 8),
                      Text(
                        titles[index],
                        style: Theme.of(
                          context,
                        ).textTheme.titleSmall?.copyWith(color: color),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
