import 'package:flutter/foundation.dart';

import '../../../../../../core/data/remote_data/tasbeeh/tasbeeh_service.dart';
import '../../../../../../core/widget/error/error_screen.dart';
import '../models/dhikr_model.dart';

/// Controller responsible for managing Tasbeeh state, API data fetching,
/// active dhikr selection, and local counter logic.
class TasbeehController extends ChangeNotifier {
  final TasbeehService _tasbeehService;

  TasbeehController({TasbeehService? tasbeehService})
    : _tasbeehService = tasbeehService ?? TasbeehService();

  bool _isLoading = false;
  String? _errorMessage;
  AppErrorType? _errorType;
  TasbihDatasetModel? _dataset;
  List<DhikrModel> _dhikrList = [];
  final List<DhikrModel> _customDhikrs = [];
  final Map<String, int> _customGoals = {};

  // Local counter state
  int _selectedIndex = 0;
  int _count = 0;
  int? _customTarget;

  // Getters for network & dataset state
  bool get isLoading => _isLoading;

  bool get hasError => _errorMessage != null;

  String? get errorMessage => _errorMessage;

  AppErrorType get errorType => _errorType ?? AppErrorType.unknown;

  TasbihDatasetModel? get dataset => _dataset;

  List<DhikrModel> get dhikrList => _dhikrList;

  List<DhikrModel> get customDhikrs => List.unmodifiable(_customDhikrs);

  String get attribution =>
      _dataset?.attribution ?? 'Tasbih.info (https://tasbih.info)';

  // Active Dhikr getters
  int get selectedIndex => _selectedIndex;

  DhikrModel? get currentDhikr =>
      _dhikrList.isNotEmpty && _selectedIndex < _dhikrList.length
      ? _dhikrList[_selectedIndex]
      : null;

  // Counter getters
  int get count => _count;

  /// Whether a given dhikr is a user-created custom dhikr.
  bool isCustomDhikr(DhikrModel dhikr) => _customGoals.containsKey(dhikr.id);

  /// Returns personal goal set for a custom dhikr, or null if none.
  int? getCustomGoal(DhikrModel dhikr) => _customGoals[dhikr.id];

  /// Returns the active target count.
  /// If [customTarget] was explicitly set by the user, returns that.
  /// If the current dhikr is a custom dhikr, returns its personal goal.
  /// Otherwise, if the dhikr has a [narratedCount], returns it.
  /// If [narratedCount] is null and no custom target is set, returns null (open counter).
  int? get targetCount {
    if (_customTarget != null) return _customTarget;
    final dhikr = currentDhikr;
    if (dhikr != null && _customGoals.containsKey(dhikr.id)) {
      return _customGoals[dhikr.id];
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

  void init() {
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
      _dataset = data;
      _dhikrList = [..._customDhikrs, ...data.dhikrList];
      _isLoading = false;

      // Ensure index is valid
      if (_selectedIndex >= _dhikrList.length) {
        _selectedIndex = 0;
      }
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

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

    final customId = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    final customDhikr = DhikrModel(
      id: customId,
      name: trimmedText,
      arabic: trimmedText,
      narratedCount: null,
    );

    _customGoals[customId] = count;
    _customDhikrs.insert(0, customDhikr);
    _dhikrList = [customDhikr, ..._dhikrList];
    _selectedIndex = 0;
    _count = 0;
    _customTarget = count;
    notifyListeners();
    return true;
  }

  /// Selects a dhikr from the list by [index] and resets current count.
  void selectDhikr(int index) {
    if (index >= 0 && index < _dhikrList.length) {
      _selectedIndex = index;
      _count = 0;
      final dhikr = currentDhikr;
      _customTarget = dhikr != null ? _customGoals[dhikr.id] : null;
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
