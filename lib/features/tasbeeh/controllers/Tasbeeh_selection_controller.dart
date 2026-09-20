import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../main.dart';
import '../models/dhikr_model.dart';
import '../screens/tasbeeh_screen.dart';
import '../widgets/dialogs/confirm_dialog.dart';
import '../widgets/sheets/add_custom_dhikr_sheet.dart';
import 'tasbeeh_controller.dart';


class TasbeehSelectionController extends ChangeNotifier {
  final TasbeehController tasbeeh;

  TasbeehSelectionController(this.tasbeeh);

  // ---------- Search ----------
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  String get searchQuery => _searchQuery;

  /// القائمة بعد الفلترة، مع الاحتفاظ بالـ index الأصلي لكل عنصر
  List<MapEntry<int, DhikrModel>> get filteredDhikrs {
    final entries = tasbeeh.dhikrList.asMap().entries;
    if (_searchQuery.isEmpty) return entries.toList();

    final q = _searchQuery.toLowerCase();
    return entries
        .where(
          (e) =>
      e.value.name.toLowerCase().contains(q) ||
          e.value.arabic.toLowerCase().contains(q),
    )
        .toList();
  }

  void updateSearch(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    notifyListeners();
  }

  // ---------- Navigation / UI actions (via navigatorKey) ----------
  void _pushTasbeehScreen() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: tasbeeh,
          child: const TasbeehScreen(),
        ),
      ),
    );
  }

  /// اختيار الذكر + فتح شاشة العد
  void openDhikr(int index) {
    tasbeeh.selectDhikr(index);
    _pushTasbeehScreen();
  }

  /// فتح شيت الإضافة، ولو اتضاف يفتح شاشة العد
  Future<void> openAddCustomDhikr() async {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    bool added = false;
    await AddCustomDhikrSheet.show(
      context: context,
      onAdd: (text, count) {
        added = tasbeeh.addCustomDhikr(text: text, count: count);
      },
    );
    if (added) _pushTasbeehScreen();
  }

  /// فتح شيت التعديل
  void openEditCustomDhikr(DhikrModel dhikr) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    AddCustomDhikrSheet.show(
      context: context,
      title: 'Edit Personal Dhikr',
      buttonText: 'Save Changes',
      initialText: dhikr.name,
      initialCount: dhikr.customGoal,
      onAdd: (text, count) {
        tasbeeh.editCustomDhikr(id: dhikr.id, text: text, count: count);
      },
    );
  }

  /// تأكيد الحذف
  void confirmDeleteCustomDhikr(DhikrModel dhikr) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      builder: (_) => ConfirmDialog(
        title: 'Delete Dhikr?',
        content: 'Are you sure you want to delete "${dhikr.name}"?',
        confirmText: 'Delete',
        isDestructive: true,
        onConfirm: () => tasbeeh.deleteCustomDhikr(dhikr.id),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}