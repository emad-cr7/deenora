import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widget/error/error_screen.dart';
import '../controllers/tasbeeh_controller.dart';
import '../controllers/tasbeeh_selection_controller.dart';
import '../widgets/skeletons/tasbeeh_skeleton.dart';
import '../widgets/tiles/dhikr_list_tile.dart';

class TasbeehSelectionScreen extends StatelessWidget {
  const TasbeehSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TasbeehController>(
          create: (_) => TasbeehController()..init(),
        ),
        ChangeNotifierProvider<TasbeehSelectionController>(
          create: (ctx) => TasbeehSelectionController(
            ctx.read<TasbeehController>(),
          ),
        ),
      ],
      child: Consumer2<TasbeehController, TasbeehSelectionController>(
        builder: (context, tasbeeh, selection, _) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tasbeeh')),
            body: SafeArea(child: _buildBody(context, tasbeeh, selection)),
          );
        },
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      TasbeehController tasbeeh,
      TasbeehSelectionController selection,
      ) {
    // 1. Initial Loading State
    if (tasbeeh.isLoading && tasbeeh.dhikrList.isEmpty) {
      return const TasbeehSkeleton();
    }

    // 2. Error State
    if (tasbeeh.hasError && tasbeeh.dhikrList.isEmpty) {
      return AppErrorScreen(
        type: tasbeeh.errorType,
        onRetry: () => tasbeeh.loadDhikr(),
      );
    }

    // 3. Empty State
    if (tasbeeh.dhikrList.isEmpty) {
      return Center(
        child: Text(
          'No dhikr data available.',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      );
    }

    final filtered = selection.filteredDhikrs;

    return Column(
      children: [
        // Search Field
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: selection.searchController,
            onChanged: selection.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search dhikr...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
              suffixIcon: selection.searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(
                  Icons.clear_rounded,
                  color: AppColors.textMuted,
                  size: 18,
                ),
                onPressed: selection.clearSearch,
              )
                  : null,
            ),
          ),
        ),

        // Dhikr List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            itemCount: filtered.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final originalIndex = filtered[idx].key;
              final dhikr = filtered[idx].value;
              final isUserCreated = dhikr.isCustom;

              return DhikrListTile(
                dhikr: dhikr,
                index: originalIndex,
                isSelected: originalIndex == tasbeeh.selectedIndex,
                onTap: () => selection.openDhikr(originalIndex),
                onEdit: isUserCreated
                    ? () => selection.openEditCustomDhikr(dhikr)
                    : null,
                onDelete: isUserCreated
                    ? () => selection.confirmDeleteCustomDhikr(dhikr)
                    : null,
              );
            },
          ),
        ),

        // Add Dhikr Button
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: selection.openAddCustomDhikr,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Add Dhikr',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
  }
}