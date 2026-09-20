import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/data/local_data/hive_manager.dart';
import '../../../../core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import '../../../../core/widget/error/error_screen.dart';
import '../models/dhikr_model.dart';

/// Controller responsible for managing Tasbeeh state, API data fetching,
/// active dhikr selection, and local counter logic.
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

  // Local counter state
  int _selectedIndex = 0;
  int _count = 0;
  int? _customTarget;

  // Getters for network & dataset state
  bool get isLoading => _isLoading;

  bool get hasError => _errorMessage != null;

  AppErrorType get errorType => _errorType ?? AppErrorType.unknown;

  List<DhikrModel> get dhikrList => _dhikrList;

  String get attribution => _attribution;

  // Active Dhikr getters
  int get selectedIndex => _selectedIndex;

  DhikrModel? get currentDhikr =>
      _dhikrList.isNotEmpty && _selectedIndex < _dhikrList.length
      ? _dhikrList[_selectedIndex]
      : null;

  // Counter getters
  int get count => _count;

  /// Whether a given dhikr is a user-created custom dhikr.
  bool isCustomDhikr(DhikrModel dhikr) => dhikr.isCustom;

  /// Returns the active target count.
  /// If [customTarget] was explicitly set by the user, returns that.
  /// If the current dhikr is a custom dhikr, returns its personal goal.
  /// Otherwise, if the dhikr has a [narratedCount], returns it.
  /// If [narratedCount] is null and no custom target is set, returns null (open counter).
  int? get targetCount {
    if (_customTarget != null) return _customTarget;
    final dhikr = currentDhikr;
    if (dhikr != null && dhikr.customGoal != null) {
      return dhikr.customGoal;
    }
    return dhikr?.narratedCount;
  }

  /// Whether a specific target count is active.
  bool get hasTarget => targetCount != null && targetCount! > 0;

  /// Whether the user has completed the target count.
  bool get isCompleted => hasTarget && _count >= targetCount!;

  /// Progress ratio from 0.0 to 1.0 towards target (or 0.0 if open counter).
  double get progress {
    final target = targetCount;
    if (target == null || target <= 0) return 0.0;
    return (_count / target).clamp(0.0, 1.0);
  }

  /// Merges user-created custom dhikrs with default/API dhikrs,
  /// filtering out any default items that share the same name as custom dhikrs.
  List<DhikrModel> _mergeAndDeduplicate(List<DhikrModel> defaults) {
    final customTexts = _customDhikrs
        .map((d) => d.name.trim().toLowerCase())
        .toSet();
    final filteredDefaults = defaults.where((defaultDhikr) {
      return !customTexts.contains(defaultDhikr.name.trim().toLowerCase());
    }).toList();
    return [..._customDhikrs, ...filteredDefaults];
  }

  /// Ensures current selection index remains valid and updates active custom target.
  void _syncSelectionState() {
    if (_selectedIndex >= _dhikrList.length) {
      _selectedIndex = _dhikrList.isNotEmpty ? _dhikrList.length - 1 : 0;
    }
    final dhikr = currentDhikr;
    _customTarget = dhikr?.customGoal;
  }

  /// Loads saved custom dhikrs and cached default dhikrs from Hive into memory.
  void loadSavedCustomDhikrs() {
    _customDhikrs.clear();
    _customDhikrs.addAll(_hiveManager.loadCustomDhikrs());

    final cachedDefaults = _hiveManager.loadDefaultDhikrs();
    if (_customDhikrs.isNotEmpty || cachedDefaults.isNotEmpty) {
      _dhikrList = _mergeAndDeduplicate(cachedDefaults);
      _syncSelectionState();
    }
  }

  void init() {
    loadSavedCustomDhikrs();
    loadDhikr();
  }

  /// Loads dhikr dataset from the API service.
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

      // Save default dhikrs to Hive so they remain available offline
      await _hiveManager.saveDefaultDhikrs(data.dhikrList);

      _dhikrList = _mergeAndDeduplicate(data.dhikrList);
      _isLoading = false;
      _syncSelectionState();
      notifyListeners();
    } catch (e) {
      _isLoading = false;

      final cachedDefaults = _hiveManager.loadDefaultDhikrs();
      if (_customDhikrs.isNotEmpty || cachedDefaults.isNotEmpty) {
        _dhikrList = _mergeAndDeduplicate(cachedDefaults);
        _errorMessage = null;
        _errorType = null;
        _syncSelectionState();
      } else {
        _errorMessage = e.toString();
        if (e is DioException) {
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            _errorType = AppErrorType.timeout;
          } else if (e.type == DioExceptionType.connectionError) {
            _errorType = AppErrorType.noInternet;
          } else {
            _errorType = AppErrorType.serverError;
          }
        } else {
          final msg = e.toString().toLowerCase();
          if (msg.contains('network') ||
              msg.contains('socket') ||
              msg.contains('connection error')) {
            _errorType = AppErrorType.noInternet;
          } else if (msg.contains('timeout')) {
            _errorType = AppErrorType.timeout;
          } else {
            _errorType = AppErrorType.serverError;
          }
        }
      }

      notifyListeners();
    }
  }

  /// Increments the local counter by 1.
  /// If a target exists (narrated or personal) and the count has already reached
  /// that target, it stops and prevents further increments.
  void increment() {
    if (hasTarget && _count >= targetCount!) {
      return;
    }
    _count++;
    notifyListeners();
  }

  /// Resets the local count back to 0.
  void reset() {
    _count = 0;
    notifyListeners();
  }

  /// Sets a user-defined custom target count (or null for open counting).
  void setCustomTarget(int? target) {
    _customTarget = target;
    notifyListeners();
  }

  /// Creates and adds a personal custom Dhikr to the list,
  /// selects it immediately, and resets the counter with the personal goal.
  bool addCustomDhikr({required String text, required int count}) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || count <= 0) {
      return false;
    }

    // 1. Check whether the same user-created dhikr already exists
    final existingIndex = _customDhikrs.indexWhere(
      (d) => d.name.trim().toLowerCase() == trimmedText.toLowerCase(),
    );

    if (existingIndex != -1) {
      // Already exists: update goal/count if necessary and select it
      final existingDhikr = _customDhikrs[existingIndex];
      final updatedDhikr = DhikrModel(
        id: existingDhikr.id,
        name: existingDhikr.name,
        arabic: existingDhikr.arabic,
        narratedCount: existingDhikr.narratedCount,
        customGoal: count,
      );

      _customDhikrs[existingIndex] = updatedDhikr;
      _hiveManager.saveCustomDhikr(updatedDhikr);

      final listIndex = _dhikrList.indexWhere((d) => d.id == existingDhikr.id);
      if (listIndex != -1) {
        _dhikrList[listIndex] = updatedDhikr;
        selectDhikr(listIndex);
      } else {
        _dhikrList.insert(0, updatedDhikr);
        selectDhikr(0);
      }

      return true;
    }

    // 2. Does not exist: create unique ID, save to Hive, add to in-memory list
    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final customDhikr = DhikrModel(
      id: customId,
      name: trimmedText,
      arabic: trimmedText,
      narratedCount: null,
      customGoal: count,
    );

    _customDhikrs.insert(0, customDhikr);
    _dhikrList = [customDhikr, ..._dhikrList];
    _hiveManager.saveCustomDhikr(customDhikr);

    _selectedIndex = 0;
    _count = 0;
    _customTarget = count;
    notifyListeners();
    return true;
  }

  /// Updates an existing user-created custom Dhikr and persists to Hive.
  bool editCustomDhikr({
    required String id,
    required String text,
    required int count,
  }) {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || count <= 0) {
      return false;
    }

    final customIndex = _customDhikrs.indexWhere((d) => d.id == id);
    if (customIndex == -1) return false;

    final updatedDhikr = DhikrModel(
      id: id,
      name: trimmedText,
      arabic: trimmedText,
      narratedCount: null,
      customGoal: count,
    );

    _customDhikrs[customIndex] = updatedDhikr;

    final listIndex = _dhikrList.indexWhere((d) => d.id == id);
    if (listIndex != -1) {
      _dhikrList[listIndex] = updatedDhikr;
    }

    _hiveManager.saveCustomDhikr(updatedDhikr);

    if (currentDhikr?.id == id) {
      _customTarget = count;
    }

    notifyListeners();
    return true;
  }

  /// Deletes a user-created custom Dhikr by ID from memory and Hive.
  bool deleteCustomDhikr(String id) {
    final customIndex = _customDhikrs.indexWhere((d) => d.id == id);
    if (customIndex == -1) return false;

    _customDhikrs.removeAt(customIndex);

    final listIndex = _dhikrList.indexWhere((d) => d.id == id);
    if (listIndex != -1) {
      _dhikrList.removeAt(listIndex);
    }

    _hiveManager.deleteCustomDhikr(id);

    if (_selectedIndex >= _dhikrList.length) {
      _selectedIndex = _dhikrList.isNotEmpty ? _dhikrList.length - 1 : 0;
      _count = 0;
    } else if (listIndex == _selectedIndex) {
      _count = 0;
    }

    final dhikr = currentDhikr;
    _customTarget = dhikr?.customGoal;

    notifyListeners();
    return true;
  }

  /// Selects a dhikr from the list by [index] and resets current count.
  void selectDhikr(int index) {
    if (index >= 0 && index < _dhikrList.length) {
      _selectedIndex = index;
      _count = 0;
      final dhikr = currentDhikr;
      _customTarget = dhikr?.customGoal;
      notifyListeners();
    }
  }

  /// Advances to the next dhikr in the list.
  void nextDhikr() {
    if (_dhikrList.isNotEmpty) {
      final nextIndex = (_selectedIndex + 1) % _dhikrList.length;
      selectDhikr(nextIndex);
    }
  }

  /// Moves to the previous dhikr in the list.
  void previousDhikr() {
    if (_dhikrList.isNotEmpty) {
      final prevIndex =
          (_selectedIndex - 1 + _dhikrList.length) % _dhikrList.length;
      selectDhikr(prevIndex);
    }
  }
}
