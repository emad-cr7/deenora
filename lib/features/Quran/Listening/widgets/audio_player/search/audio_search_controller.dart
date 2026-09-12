import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../../core/data/local_data/hive_manager.dart';
import '../../../../../../core/data/remote_data/quran/quran_Reading_service.dart';
import '../../../../reading/models/surah_model.dart';
import '../../../models_listening/reciter_model.dart';
import 'utils/search_text_normalizer.dart';

class AudioSearchController extends ChangeNotifier {
  final QuranReadingService _readingService;
  final HiveManager _hiveManager;

  List<SurahModel> _allSurahs = [];
  List<ReciterModel> _allReciters = [];

  List<SurahModel> _filteredSurahs = [];
  List<ReciterModel> _filteredReciters = [];

  String _searchQuery = '';
  bool _isLoading = false;
  Timer? _debounceTimer;

  AudioSearchController({
    List<SurahModel>? initialSurahs,
    List<ReciterModel>? initialReciters,
    QuranReadingService? readingService,
    HiveManager? hiveManager,
  })  : _readingService = readingService ?? QuranReadingService(),
        _hiveManager = hiveManager ?? HiveManager() {
    if (initialSurahs != null && initialSurahs.isNotEmpty) {
      _allSurahs = List.from(initialSurahs);
    }
    _allReciters = initialReciters ?? List.from(reciters);
  }

  String get searchQuery => _searchQuery;
  List<SurahModel> get filteredSurahs => _filteredSurahs;
  List<ReciterModel> get filteredReciters => _filteredReciters;
  bool get isLoading => _isLoading;

  bool get isInitial => _searchQuery.trim().isEmpty;
  bool get hasNoResults =>
      !isInitial &&
      !_isLoading &&
      _filteredSurahs.isEmpty &&
      _filteredReciters.isEmpty;
  bool get hasSurahs => _filteredSurahs.isNotEmpty;
  bool get hasReciters => _filteredReciters.isNotEmpty;

  /// Initializes surah data from cache or API if not already provided
  Future<void> init() async {
    if (_allSurahs.isNotEmpty) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final cached = _hiveManager.loadSurahs();
      if (cached.isNotEmpty) {
        _allSurahs = cached;
      } else {
        final response = await _readingService.getFullQuran();
        _allSurahs = response.surahs;
        await _hiveManager.saveSurahs(response.surahs);
      }
    } catch (_) {
      // In case of error, _allSurahs remains empty and search will still work for reciters
    } finally {
      _isLoading = false;
      if (_searchQuery.trim().isNotEmpty) {
        _filter();
      } else {
        notifyListeners();
      }
    }
  }

  /// Handles search query change with a 250ms debounce
  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _searchQuery = query;
      _filter();
    });
  }

  /// Immediately clear search
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchQuery = '';
    _filteredSurahs = [];
    _filteredReciters = [];
    notifyListeners();
  }

  void _filter() {
    final query = _searchQuery.trim();
    if (query.isEmpty) {
      _filteredSurahs = [];
      _filteredReciters = [];
      notifyListeners();
      return;
    }

    _filteredSurahs = _allSurahs
        .where((surah) => SearchTextNormalizer.matchesSurah(surah, query))
        .toList();

    _filteredReciters = _allReciters
        .where((reciter) => SearchTextNormalizer.matchesReciter(reciter, query))
        .toList();

    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
