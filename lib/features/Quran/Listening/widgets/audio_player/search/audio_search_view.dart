import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widget/share_widget/search/search_empty_state_widget.dart';
import '../../../../../../core/widget/share_widget/search/search_section_header.dart';
import '../../../../../../core/widget/share_widget/search/search_widget.dart';
import '../../../../reading/models/surah_model.dart';
import '../../../models_listening/reciter_model.dart';
import '../controller/audio_player_coordinator.dart';
import 'audio_search_controller.dart';
import 'widgets/reciter_search_result.dart';
import 'widgets/surah_search_result.dart';

class AudioSearchView extends StatefulWidget {
  final AudioPlayerCoordinator? coordinator;
  final ReciterModel? currentReciter;
  final SurahModel? currentSurah;
  final List<SurahModel>? surahList;
  final List<ReciterModel>? reciterList;
  final void Function(SurahModel surah)? onSurahSelected;
  final void Function(ReciterModel reciter)? onReciterSelected;

  const AudioSearchView({
    super.key,
    this.coordinator,
    this.currentReciter,
    this.currentSurah,
    this.surahList,
    this.reciterList,
    this.onSurahSelected,
    this.onReciterSelected,
  });

  static const Color primaryColor = AppColors.primary;

  @override
  State<AudioSearchView> createState() => _AudioSearchViewState();
}

class _AudioSearchViewState extends State<AudioSearchView> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onSurahTapped(SurahModel surah) {
    if (widget.coordinator != null) {
      widget.coordinator!.playSurah(surah);
      Navigator.pop(context);
    } else if (widget.onSurahSelected != null) {
      widget.onSurahSelected!(surah);
    } else {
      Navigator.pop(context, surah);
    }
  }

  void _onReciterTapped(ReciterModel reciter) {
    if (widget.coordinator != null) {
      widget.coordinator!.changeReciter(reciter);
      Navigator.pop(context);
    } else if (widget.onReciterSelected != null) {
      widget.onReciterSelected!(reciter);
    } else {
      Navigator.pop(context, reciter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSurahList =
        widget.surahList ?? widget.coordinator?.surahList;
    final effectiveCurrentReciter =
        widget.currentReciter ?? widget.coordinator?.reciter;
    final effectiveCurrentSurah =
        widget.currentSurah ?? widget.coordinator?.currentSurah;

    return ChangeNotifierProvider<AudioSearchController>(
      create: (_) => AudioSearchController(
        initialSurahs: effectiveSurahList,
        initialReciters: widget.reciterList,
      )..init(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Search Quran'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: AudioSearchView.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<AudioSearchController>(
          builder: (context, controller, _) {
            return SearchWidget(
              controller: _textController,
              hintText: 'Search Surah or Reciter...',
              autofocus: true,
              onChanged: controller.onSearchQueryChanged,
              onClear: controller.clearSearch,
              isLoading: controller.isLoading,
              isInitial: controller.isInitial,
              hasNoResults: controller.hasNoResults,
              initialWidget: const SearchEmptyStateWidget(
                icon: Icons.search_rounded,
                title: 'Search for a Surah or Reciter',
                subtitle:
                    'Search by English name, Arabic name, or Surah number',
              ),
              noResultsWidget: SearchEmptyStateWidget(
                icon: Icons.search_off_rounded,
                title: 'No results found',
                subtitle:
                    'No Surah or Reciter matches "${controller.searchQuery}"',
              ),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Surahs Section
                  if (controller.hasSurahs) ...[
                    SearchSectionHeader(
                      title: 'Surahs',
                      count: controller.filteredSurahs.length,
                    ),
                    ...controller.filteredSurahs.map((surah) {
                      final isPlaying =
                          effectiveCurrentSurah?.number == surah.number;
                      return SurahSearchResult(
                        surah: surah,
                        isCurrentlyPlaying: isPlaying,
                        onTap: () => _onSurahTapped(surah),
                      );
                    }),
                    const SizedBox(height: 12),
                  ],

                  // Reciters Section
                  if (controller.hasReciters) ...[
                    SearchSectionHeader(
                      title: 'Reciters',
                      count: controller.filteredReciters.length,
                    ),
                    ...controller.filteredReciters.map((reciter) {
                      final isSelected =
                          effectiveCurrentReciter?.id == reciter.id;
                      return ReciterSearchResult(
                        reciter: reciter,
                        isCurrentlySelected: isSelected,
                        onTap: () => _onReciterTapped(reciter),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
