import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:deenora/core/data/local_data/hive_manager.dart';

import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/repository/muadhin_repository.dart';
import 'muadhin_player_controller.dart';

/// State management controller for the Muadhin selection feature.
class MuadhinController extends ChangeNotifier {
  final MuadhinRepository _repository;
  final MuadhinPlayerController _playerController;
  final bool _ownsPlayerController;
  final HiveManager _hiveManager;
  bool _disposed = false;

  String _selectedType = 'adhan';
  List<MuadhinModel> _allMuadhins = [];
  bool _isLoading = false;
  String? _errorMessage;
  AppErrorType? _errorType;
  String? _expandedMuadhinId;

  MuadhinController({
    MuadhinRepository? repository,
    MuadhinPlayerController? playerController,
    HiveManager? hiveManager,
  }) : _repository = repository ?? MuadhinRepository(),
       _playerController = playerController ?? MuadhinPlayerController(),
       _ownsPlayerController = playerController == null,
       _hiveManager = hiveManager ?? HiveManager();

  // --- Getters ---
  String get selectedType => _selectedType;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  AppErrorType get errorType => _errorType ?? AppErrorType.unknown;
  String? get expandedMuadhinId => _expandedMuadhinId;
  MuadhinPlayerController get playerController => _playerController;
  List<MuadhinModel> get allMuadhins => _allMuadhins;
  String? get selectedMuadhinId => _hiveManager.loadSelectedMuadhinId();

  /// A missing recording never silently substitutes another Muadhin.
  bool get isSelectedMuadhinUnavailable =>
      selectedMuadhinId != null &&
      !_allMuadhins.any(
        (m) =>
            m.id == selectedMuadhinId &&
            MuadhinRepository.hasAudioFor(m, 'adhan'),
      );

  Future<void> selectMuadhin(String id) async {
    if (!_allMuadhins.any(
      (m) => m.id == id && MuadhinRepository.hasAudioFor(m, 'adhan'),
    )) {
      return;
    }
    if (selectedMuadhinId == id) return;
    await _hiveManager.saveSelectedMuadhinId(id);
    if (!_disposed) notifyListeners();
  }

  /// Returns the Muadhins available for the currently selected audio type ('adhan' or 'iqama').
  /// For Adhan: all Muadhins with Adhan audio.
  /// For Iqama: all Muadhins with Iqama audio available.
  List<MuadhinModel> get currentMuadhins {
    return _allMuadhins
        .where((m) => MuadhinRepository.hasAudioFor(m, _selectedType))
        .toList();
  }

  // --- Actions ---

  /// Loads Muadhins from the repository.
  Future<void> loadMuadhins({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    _errorType = null;
    notifyListeners();

    try {
      final list = await _repository.getMuadhins(forceRefresh: forceRefresh);
      _allMuadhins = list;
    } catch (e) {
      _errorMessage = e.toString();
      _errorType = _classifyError(e);
    } finally {
      _isLoading = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Retries loading Muadhins.
  Future<void> retry() => loadMuadhins(forceRefresh: true);

  /// Switches between Adhan and Iqama tabs ('adhan' or 'iqama').
  /// Stops any currently playing audio and collapses any expanded card.
  void switchType(String type) {
    if (_selectedType == type) return;

    _playerController.stop();
    _selectedType = type;
    _expandedMuadhinId = null;
    notifyListeners();
  }

  /// Toggles card expansion for a given [MuadhinModel].
  /// If the card is already expanded: collapses it and pauses audio.
  /// If tapping a new card: expands it and automatically starts playing the selected audio.
  Future<void> toggleExpand(MuadhinModel muadhin) async {
    if (_expandedMuadhinId == muadhin.id) {
      // Collapse card and pause playback
      _expandedMuadhinId = null;
      await _playerController.pause();
      notifyListeners();
      return;
    }

    // Expand the new card
    _expandedMuadhinId = muadhin.id;
    notifyListeners();

    // Auto-play the corresponding audio track if available
    final audio = MuadhinRepository.getAudio(muadhin, _selectedType);
    final audioUrl = MuadhinRepository.getEffectiveAudioUrl(audio);
    if (audioUrl != null && audioUrl.isNotEmpty) {
      await _playerController.playMuadhin(
        audioUrl: audioUrl,
        muadhinId: muadhin.id,
        type: _selectedType,
      );
    }
  }

  /// Checks if a given Muadhin's card is currently expanded.
  bool isExpanded(String muadhinId) => _expandedMuadhinId == muadhinId;

  /// Classifies errors into [AppErrorType] for consistent UI error presentation.
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
        msg.contains('connection') ||
        msg.contains('internet')) {
      return AppErrorType.noInternet;
    }
    if (msg.contains('timeout')) {
      return AppErrorType.timeout;
    }
    return AppErrorType.serverError;
  }

  @override
  void dispose() {
    _disposed = true;
    if (_ownsPlayerController) {
      _playerController.dispose();
    }
    super.dispose();
  }
}
