import 'package:flutter/material.dart';
import 'app_search_bar.dart';
import 'search_empty_state_widget.dart';

class SearchWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;
  final FocusNode? focusNode;
  final bool isLoading;
  final bool isInitial;
  final bool hasNoResults;
  final String? initialTitle;
  final String? initialSubtitle;
  final String? noResultsTitle;
  final String? noResultsSubtitle;
  final Widget? initialWidget;
  final Widget? noResultsWidget;
  final Widget? headerWidget;
  final Widget child;

  const SearchWidget({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.focusNode,
    this.isLoading = false,
    this.isInitial = false,
    this.hasNoResults = false,
    this.initialTitle,
    this.initialSubtitle,
    this.noResultsTitle,
    this.noResultsSubtitle,
    this.initialWidget,
    this.noResultsWidget,
    this.headerWidget,
    required this.child,
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSearchBar(
          controller: controller,
          hintText: hintText,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          onClear: onClear,
          autofocus: autofocus,
          focusNode: focusNode,
        ),
        ?headerWidget,
        Expanded(
          child: _buildBody(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          strokeWidth: 3,
        ),
      );
    }

    if (isInitial) {
      if (initialWidget != null) return initialWidget!;
      return SearchEmptyStateWidget(
        icon: Icons.search_rounded,
        title: initialTitle ?? 'Start Searching',
        subtitle: initialSubtitle ?? 'Type something to begin your search',
      );
    }

    if (hasNoResults) {
      if (noResultsWidget != null) return noResultsWidget!;
      return SearchEmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: noResultsTitle ?? 'No results found',
        subtitle: noResultsSubtitle ?? 'Try searching with a different keyword',
      );
    }

    return child;
  }
}
