import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widget/error/error_screen.dart';
import '../controllers/tasbeeh_controller.dart';
import '../models/dhikr_model.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/sheets/add_custom_dhikr_sheet.dart';
import '../widgets/skeletons/tasbeeh_skeleton.dart';
import '../widgets/tiles/dhikr_list_tile.dart';
import 'tasbeeh_screen.dart';

class TasbeehSelectionScreen extends StatelessWidget {
  const TasbeehSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      Provider.of<TasbeehController>(context, listen: false);
      return const _TasbeehSelectionContent();
    } catch (_) {
      return ChangeNotifierProvider<TasbeehController>(
        create: (_) => TasbeehController()..init(),
        child: const _TasbeehSelectionContent(),
      );
    }
  }
}

class _TasbeehSelectionContent extends StatefulWidget {
  const _TasbeehSelectionContent();

  @override
  State<_TasbeehSelectionContent> createState() =>
      _TasbeehSelectionContentState();
}

class _TasbeehSelectionContentState extends State<_TasbeehSelectionContent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectDhikr(int index) {
    final controller = context.read<TasbeehController>();
    controller.selectDhikr(index);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: controller,
          child: const TasbeehScreen(),
        ),
      ),
    );
  }

  Future<void> _openAddCustomDhikr() async {
    final controller = context.read<TasbeehController>();
    bool added = false;
    await AddCustomDhikrSheet.show(
      context: context,
      onAdd: (text, count) {
        added = controller.addCustomDhikr(text: text, count: count);
      },
    );
    if (added && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: controller,
            child: const TasbeehScreen(),
          ),
        ),
      );
    }
  }

  void _openEditCustomDhikr(DhikrModel dhikr) {
    final controller = context.read<TasbeehController>();
    AddCustomDhikrSheet.show(
      context: context,
      title: 'Edit Personal Dhikr',
      buttonText: 'Save Changes',
      initialText: dhikr.name,
      initialCount: dhikr.customGoal,
      onAdd: (text, count) {
        controller.editCustomDhikr(id: dhikr.id, text: text, count: count);
      },
    );
  }

  void _confirmDeleteCustomDhikr(DhikrModel dhikr) {
    final controller = context.read<TasbeehController>();
    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Delete Dhikr?',
        content: 'Are you sure you want to delete "${dhikr.name}"?',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () => controller.deleteCustomDhikr(dhikr.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TasbeehController>(
      builder: (context, controller, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Tasbeeh')),
          body: SafeArea(
            child: Builder(
              builder: (context) {
                // 1. Initial Loading State
                if (controller.isLoading && controller.dhikrList.isEmpty) {
                  return const TasbeehSkeleton();
                }

                // 2. Error State
                if (controller.hasError && controller.dhikrList.isEmpty) {
                  return AppErrorScreen(
                    type: controller.errorType,
                    onRetry: () => controller.loadDhikr(),
                  );
                }

                if (controller.dhikrList.isEmpty) {
                  return Center(
                    child: Text(
                      'No dhikr data available.',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                }

                // Filter items by search query
                final filtered = controller.dhikrList.asMap().entries.where((
                  entry,
                ) {
                  if (_query.isEmpty) return true;
                  final d = entry.value;
                  final q = _query.toLowerCase();
                  return d.name.toLowerCase().contains(q) ||
                      d.arabic.toLowerCase().contains(q);
                }).toList();

                return Column(
                  children: [
                    // Search Field at the top
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _query = val),
                        decoration: InputDecoration(
                          hintText: 'Search dhikr...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: AppColors.textMuted,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),

                    // Scrollable Dhikr List in the middle
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final originalIndex = filtered[idx].key;
                          final dhikr = filtered[idx].value;
                          final isSelected =
                              originalIndex == controller.selectedIndex;
                          final isUserCreated = dhikr.isCustom;

                          return DhikrListTile(
                            dhikr: dhikr,
                            index: originalIndex,
                            isSelected: isSelected,
                            onTap: () => _onSelectDhikr(originalIndex),
                            onEdit: isUserCreated
                                ? () => _openEditCustomDhikr(dhikr)
                                : null,
                            onDelete: isUserCreated
                                ? () => _confirmDeleteCustomDhikr(dhikr)
                                : null,
                          );
                        },
                      ),
                    ),

                    // Fixed Add Dhikr Button at the very bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _openAddCustomDhikr,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Add Dhikr',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}
