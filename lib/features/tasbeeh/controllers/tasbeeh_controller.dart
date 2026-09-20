import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import '../../../../core/widget/error/error_screen.dart';
import '../models/dhikr_model.dart';

class TasbeehController extends ChangeNotifier {
  final TasbeehService _tasbeehService;
  final HiveManager _hiveManager;

  TasbeehController({TasbeehService? tasbeehService, HiveManager? hiveManager})
    : _tasbeehService = tasbeehService ?? TasbeehService(),
      _hiveManager = hiveManager ?? HiveManager();

  bool _isLoading = false;
  String? _errorMessage;
  AppErrorType? _errorType;
  String _attribution = 'Tasbih.info (https://tasbih.info)';
  List<DhikrModel> _dhikrList = [];
  final List<DhikrModel> _customDhikrs = [];

  int _selectedIndex = 0;
  int _count = 0;
  int? _customTarget;

  bool get isLoading => _isLoading;

  bool get hasError => _errorMessage != null;

  AppErrorType get errorType => _errorType ?? AppErrorType.unknown;

  List<DhikrModel> get dhikrList => _dhikrList;

  String get attribution => _attribution;

  int get selectedIndex => _selectedIndex;

  int get count => _count;

  DhikrModel? get currentDhikr =>
      _selectedIndex < _dhikrList.length ? _dhikrList[_selectedIndex] : null;

  bool isCustomDhikr(DhikrModel dhikr) => dhikr.isCustom;

  int? get targetCount =>
      _customTarget ?? currentDhikr?.customGoal ?? currentDhikr?.narratedCount;

  bool get hasTarget => (targetCount ?? 0) > 0;

  bool get isCompleted => hasTarget && _count >= targetCount!;

  double get progress =>
      hasTarget ? (_count / targetCount!).clamp(0.0, 1.0) : 0.0;

  List<DhikrModel> _mergeAndDeduplicate(List<DhikrModel> defaults) {
    final customNames = _customDhikrs
        .map((d) => d.name.trim().toLowerCase())
        .toSet();
    return [
      ..._customDhikrs,
      ...defaults.where(
        (d) => !customNames.contains(d.name.trim().toLowerCase()),
      ),
    ];
  }

  void _syncSelectionState() {
    if (_selectedIndex >= _dhikrList.length) {
      _selectedIndex = _dhikrList.isNotEmpty ? _dhikrList.length - 1 : 0;
    }
    _customTarget = currentDhikr?.customGoal;
  }

  void loadSavedCustomDhikrs() {
    _customDhikrs.clear();
    _customDhikrs.addAll(_hiveManager.loadCustomDhikrs());

    final cached = _hiveManager.loadDefaultDhikrs();
    if (_customDhikrs.isNotEmpty || cached.isNotEmpty) {
      _dhikrList = _mergeAndDeduplicate(cached);
      _syncSelectionState();
    }
  }

  void init() {
    loadSavedCustomDhikrs();
    loadDhikr();
  }

  Future<void> loadDhikr({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _errorType = null;
    notifyListeners();

    try {
      final data = await _tasbeehService.getTasbihData(
        forceRefresh: forceRefresh,
      );
      _attribution = data.attribution;
      await _hiveManager.saveDefaultDhikrs(data.dhikrList);
      _dhikrList = _mergeAndDeduplicate(data.dhikrList);
      _syncSelectionState();
    } catch (e) {
      final cached = _hiveManager.loadDefaultDhikrs();
      if (_customDhikrs.isNotEmpty || cached.isNotEmpty) {
        _dhikrList = _mergeAndDeduplicate(cached);
        _syncSelectionState();
      } else {
        _errorMessage = e.toString();
        _errorType = _classifyError(e);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  AppErrorType _classifyError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return AppErrorType.timeout;
      }
      return e.type == DioExceptionType.connectionError
          ? AppErrorType.noInternet
          : AppErrorType.serverError;
    }
    final msg = e.toString().toLowerCase();
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection error')) {
      return AppErrorType.noInternet;
    }
    if (msg.contains('timeout')) return AppErrorType.timeout;
    return AppErrorType.serverError;
  }

  void increment() {
    if (hasTarget && _count >= targetCount!) return;
    _count++;
    notifyListeners();
  }

  void reset() {
    _count = 0;
    notifyListeners();
  }

  void setCustomTarget(int? target) {
    _customTarget = target;
    notifyListeners();
  }

  bool addCustomDhikr({required String text, required int count}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || count <= 0) return false;

    final existingIndex = _customDhikrs.indexWhere(
      (d) => d.name.trim().toLowerCase() == trimmed.toLowerCase(),
    );

    if (existingIndex != -1) {
      final existing = _customDhikrs[existingIndex];
      final updated = DhikrModel(
        id: existing.id,
        name: existing.name,
        arabic: existing.arabic,
        narratedCount: existing.narratedCount,
        customGoal: count,
      );

      _customDhikrs[existingIndex] = updated;
      _hiveManager.saveCustomDhikr(updated);

      final listIndex = _dhikrList.indexWhere((d) => d.id == existing.id);
      if (listIndex != -1) {
        _dhikrList[listIndex] = updated;
        selectDhikr(listIndex);
      } else {
        _dhikrList.insert(0, updated);
        selectDhikr(0);
      }
      return true;
    }

    final customDhikr = DhikrModel(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: trimmed,
      arabic: trimmed,
      customGoal: count,
    );

    _customDhikrs.insert(0, customDhikr);
    _dhikrList.insert(0, customDhikr);
    _hiveManager.saveCustomDhikr(customDhikr);
    selectDhikr(0);
    return true;
  }

  bool editCustomDhikr({
    required String id,
    required String text,
    required int count,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || count <= 0) return false;

    final customIndex = _customDhikrs.indexWhere((d) => d.id == id);
    if (customIndex == -1) return false;

    final updated = DhikrModel(
      id: id,
      name: trimmed,
      arabic: trimmed,
      customGoal: count,
    );

    _customDhikrs[customIndex] = updated;

    final listIndex = _dhikrList.indexWhere((d) => d.id == id);
    if (listIndex != -1) _dhikrList[listIndex] = updated;

    _hiveManager.saveCustomDhikr(updated);

    if (currentDhikr?.id == id) _customTarget = count;

    notifyListeners();
    return true;
  }

  bool deleteCustomDhikr(String id) {
    final customIndex = _customDhikrs.indexWhere((d) => d.id == id);
    if (customIndex == -1) return false;

    _customDhikrs.removeAt(customIndex);
    _dhikrList.removeWhere((d) => d.id == id);
    _hiveManager.deleteCustomDhikr(id);

    if (_selectedIndex >= _dhikrList.length) {
      _selectedIndex = _dhikrList.isNotEmpty ? _dhikrList.length - 1 : 0;
      _count = 0;
    } else if (currentDhikr?.id == id) {
      _count = 0;
    }

    _customTarget = currentDhikr?.customGoal;
    notifyListeners();
    return true;
  }

  void selectDhikr(int index) {
    if (index >= 0 && index < _dhikrList.length) {
      _selectedIndex = index;
      _count = 0;
      _customTarget = currentDhikr?.customGoal;
      notifyListeners();
    }
  }

  void nextDhikr() {
    if (_dhikrList.isNotEmpty) {
      selectDhikr((_selectedIndex + 1) % _dhikrList.length);
    }
  }

  void previousDhikr() {
    if (_dhikrList.isNotEmpty) {
      selectDhikr((_selectedIndex - 1 + _dhikrList.length) % _dhikrList.length);
    }
  }
}
