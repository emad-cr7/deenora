import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:deenora/core/widget/error/error_screen.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/repository/muadhin_repository.dart';
import 'muadhin_player_controller.dart';

class MuadhinController extends ChangeNotifier {
  final MuadhinRepository _repository;
  final MuadhinPlayerController playerController;
  final bool _ownsPlayerController;

  String selectedType = 'adhan';
  List<MuadhinModel> allMuadhins = [];
  bool isLoading = false;
  String? errorMessage;
  AppErrorType errorType = AppErrorType.unknown;
  String? expandedMuadhinId;

  MuadhinController({
    MuadhinRepository? repository,
    MuadhinPlayerController? playerController,
  }) : _repository = repository ?? MuadhinRepository(),
       playerController = playerController ?? MuadhinPlayerController(),
       _ownsPlayerController = playerController == null;

  bool hasError() => errorMessage != null;

  List<MuadhinModel> currentMuadhins() => muadhinsForType(selectedType);

  List<MuadhinModel> muadhinsForType(String type) {
    return allMuadhins
        .where((m) => MuadhinRepository.hasAudioFor(m, type))
        .toList();
  }

  // --- Actions ---

  Future<void> loadMuadhins({bool forceRefresh = false}) async {
    isLoading = true;
    errorMessage = null;
    errorType = AppErrorType.unknown;
    notifyListeners();

    try {
      allMuadhins = await _repository.getMuadhins(forceRefresh: forceRefresh);
    } catch (e) {
      errorMessage = e.toString();
      errorType = _classifyError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => loadMuadhins(forceRefresh: true);

  void switchType(String type) {
    if (selectedType == type) return;

    playerController.stop();
    selectedType = type;
    expandedMuadhinId = null;
    notifyListeners();
  }

  Future<void> toggleExpand(MuadhinModel muadhin) async {
    if (expandedMuadhinId == muadhin.id) {
      // Collapse card and pause playback
      expandedMuadhinId = null;
      await playerController.pause();
      notifyListeners();
      return;
    }

    // Expand the new card
    expandedMuadhinId = muadhin.id;
    notifyListeners();

    // Auto-play the corresponding audio track if available
    final audio = MuadhinRepository.getAudio(muadhin, selectedType);
    final audioUrl = MuadhinRepository.getEffectiveAudioUrl(audio);
    if (audioUrl != null) {
      await playerController.playMuadhin(
        audioUrl: audioUrl,
        muadhinId: muadhin.id,
        type: selectedType,
      );
    }
  }

  bool isExpanded(String muadhinId) => expandedMuadhinId == muadhinId;

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
    if (_ownsPlayerController) {
      playerController.dispose();
    }
    super.dispose();
  }
}
