import 'package:flutter/material.dart';
import 'package:deenora/core/theme/app_colors.dart';
import 'package:deenora/core/theme/app_sizes.dart';
import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/core/widget/share_widget/shared_segmented_switch.dart';
import 'package:deenora/features/settings/muadhin/controllers/muadhin_controller.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';
import 'muadhin_card.dart';
import 'muadhin_skeleton.dart';

/// Modal bottom sheet allowing users to browse Muadhins, switch between
/// Adhan and Iqama, and play audio inline without leaving the bottom sheet.
class MuadhinSelectionBottomSheet extends StatefulWidget {
  const MuadhinSelectionBottomSheet({super.key});

  /// Displays the Muadhin selection modal bottom sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const MuadhinSelectionBottomSheet(),
    );
  }

  @override
  State<MuadhinSelectionBottomSheet> createState() =>
      _MuadhinSelectionBottomSheetState();
}

class _MuadhinSelectionBottomSheetState
    extends State<MuadhinSelectionBottomSheet>
    with SingleTickerProviderStateMixin {
  late final MuadhinController _controller;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _controller = MuadhinController()..loadMuadhins();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final selectedType = _tabController.index == 0
        ? MuadhinType.adhan
        : MuadhinType.iqama;
    if (_controller.selectedType != selectedType) {
      _controller.switchType(selectedType);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.88;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Sheet Header: Title, Description & Close Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Muadhin',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontSize: AppSizes.sp18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Listen and choose Adhan or Iqama audio',
                            style: TextStyle(
                              fontSize: AppSizes.sp12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textMuted,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ),

                // Adhan / Iqama Shared Segmented Switch
                SharedSegmentedSwitch(
                  controller: _tabController,
                  titles: const ['Adhan', 'Iqama'],
                  icons: const [
                    Icons.volume_up_rounded,
                    Icons.notifications_active_rounded,
                  ],
                ),

                Expanded(
                  child: _buildBody(context),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_controller.isLoading) {
      return const MuadhinSkeleton();
    }

    if (_controller.hasError) {
      return AppErrorScreen(
        type: _controller.errorType,
        onRetry: () => _controller.retry(),
      );
    }

    final muadhins = _controller.currentMuadhins;

    if (muadhins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.volume_off_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
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
        final isExpanded = _controller.isExpanded(muadhin.id);
        final isPlaying = _controller.playerController.isTrackPlaying(
          muadhin.id,
          _controller.selectedType,
        );

        return MuadhinCard(
          key: ValueKey('${muadhin.id}_${_controller.selectedType.name}'),
          muadhin: muadhin,
          selectedType: _controller.selectedType,
          isExpanded: isExpanded,
          isPlaying: isPlaying,
          playerController: _controller.playerController,
          onTap: () => _controller.toggleExpand(muadhin),
        );
      },
    );
  }
}
