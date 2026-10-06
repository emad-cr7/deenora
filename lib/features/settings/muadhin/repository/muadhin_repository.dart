import 'package:deenora/core/data/remote_data/muadhin/muadhin_service.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_model.dart';
import 'package:deenora/features/settings/muadhin/models/muadhin_type.dart';

/// Repository for retrieving and filtering Muadhin data with session-level caching.
class MuadhinRepository {
  final MuadhinService _service;

  // In-memory cache for the current session to ensure instant tab switching
  List<MuadhinModel>? _cachedMuadhins;

  MuadhinRepository({MuadhinService? service})
      : _service = service ?? MuadhinService();

  /// Retrieves all Muadhins.
  /// Uses cached list if available unless [forceRefresh] is set to true.
  Future<List<MuadhinModel>> getMuadhins({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedMuadhins != null && _cachedMuadhins!.isNotEmpty) {
      return _cachedMuadhins!;
    }

    final muadhins = await _service.getAllMuadhins();
    _cachedMuadhins = muadhins;
    return muadhins;
  }

  /// Retrieves only Muadhins who have audio available for the requested [MuadhinType].
  Future<List<MuadhinModel>> getAvailableMuadhins(
    MuadhinType type, {
    bool forceRefresh = false,
  }) async {
    final all = await getMuadhins(forceRefresh: forceRefresh);
    return all.where((m) => m.hasAudioFor(type)).toList();
  }
}
