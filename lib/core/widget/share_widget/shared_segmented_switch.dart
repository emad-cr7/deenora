import 'package:animated_segmented_tab_control/animated_segmented_tab_control.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class SharedSegmentedSwitch extends StatefulWidget {
  final List<String> titles;
  final List<IconData> icons;
  final List<Widget> children;
  final ValueChanged<int>? onTabChanged;

  const SharedSegmentedSwitch({
    super.key,
    required this.titles,
    required this.icons,
    required this.children,
    this.onTabChanged,
  });

  @override
  State<SharedSegmentedSwitch> createState() => _SharedSegmentedSwitchState();
}

class _SharedSegmentedSwitchState extends State<SharedSegmentedSwitch>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: widget.children.length, vsync: this);
    _controller.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_controller.index == _selectedIndex) return;
    _selectedIndex = _controller.index;
    widget.onTabChanged?.call(_selectedIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.titles.length == widget.icons.length);
    assert(widget.titles.length == widget.children.length);

    return Column(
      children: [
        Padding(
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
                controller: _controller,
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
                tabs: List.generate(widget.titles.length, (index) {
                  return SegmentTab(
                    label: widget.titles[index],
                    labelBuilder: (context, color) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Icon(widget.icons[index], size: 20, color: color),
                          const SizedBox(width: 8),
                          Text(
                            widget.titles[index],
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
        ),
        Expanded(
          child: TabBarView(controller: _controller, children: widget.children),
        ),
      ],
    );
  }
}
