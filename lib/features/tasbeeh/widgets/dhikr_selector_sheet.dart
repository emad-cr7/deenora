import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/dhikr_model.dart';
import 'add_custom_dhikr_sheet.dart';

class DhikrSelectorSheet extends StatefulWidget {
  final List<DhikrModel> dhikrList;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final void Function(String text, int count)? onAddCustom;
  final String? attribution;

  const DhikrSelectorSheet({
    super.key,
    required this.dhikrList,
    required this.selectedIndex,
    required this.onSelect,
    this.onAddCustom,
    this.attribution,
  });

  static Future<void> show({
    required BuildContext context,
    required List<DhikrModel> dhikrList,
    required int selectedIndex,
    required ValueChanged<int> onSelect,
    void Function(String text, int count)? onAddCustom,
    String? attribution,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DhikrSelectorSheet(
        dhikrList: dhikrList,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
        onAddCustom: onAddCustom,
        attribution: attribution,
      ),
    );
  }

  @override
  State<DhikrSelectorSheet> createState() => _DhikrSelectorSheetState();
}

class _DhikrSelectorSheetState extends State<DhikrSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.dhikrList.asMap().entries.where((entry) {
      if (_query.isEmpty) return true;
      final d = entry.value;
      final q = _query.toLowerCase();
      return d.name.toLowerCase().contains(q) || d.arabic.contains(_query);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF9FBFA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: const Color(0xFFD4DDD8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),

          // Header: Title & Close
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Select Dhikr',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.deepForest,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${widget.dhikrList.length}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // "+ Add Custom Dhikr" button
          if (widget.onAddCustom != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: InkWell(
                onTap: () {
                  AddCustomDhikrSheet.show(
                    context: context,
                    onAdd: (text, count) {
                      widget.onAddCustom!(text, count);
                      Navigator.pop(context); // close selector sheet
                    },
                  );
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Custom Dhikr',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
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
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8E4)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE2E8E4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFEBEFEA)),

          // Dhikr List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No matching dhikr found',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final originalIndex = filtered[idx].key;
                      final dhikr = filtered[idx].value;
                      final isSelected = originalIndex == widget.selectedIndex;
                      final isCustom = dhikr.id.startsWith('custom_');
                      final hasNarrated = dhikr.narratedCount != null;

                      return InkWell(
                        onTap: () {
                          widget.onSelect(originalIndex);
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.08)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.borderSubtle,
                              width: isSelected ? 1.8 : 1.0,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Number index badge
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : const Color(0xFFEDF2EE),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${originalIndex + 1}',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.textMuted,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Content: Names, Arabic, Target badge
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            dhikr.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  color: isSelected
                                                      ? AppColors.primary
                                                      : AppColors.textDark,
                                                ),
                                          ),
                                        ),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle_rounded,
                                            size: 25,
                                            color: AppColors.primary,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    // Target information badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isCustom
                                            ? const Color(0xFFE8F4F8)
                                            : (hasNarrated
                                                  ? AppColors.champagneGold
                                                        .withValues(alpha: 0.25)
                                                  : const Color(0xFFEFF2F0)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isCustom
                                            ? 'Personal Goal'
                                            : (hasNarrated
                                                  ? 'Narrated: ${dhikr.narratedCount} times'
                                                  : 'Open count (unspecified)'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: isCustom
                                                  ? AppColors.badgeBlue
                                                  : (hasNarrated
                                                        ? AppColors.darkGold
                                                        : AppColors.textMuted),
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
