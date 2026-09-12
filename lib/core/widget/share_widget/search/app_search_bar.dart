import 'package:flutter/material.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool readOnly;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry margin;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.onTap,
    this.autofocus = false,
    this.readOnly = false,
    this.focusNode,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late final TextEditingController _effectiveController;
  late final FocusNode _effectiveFocusNode;
  bool _hasText = false;

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _hasText = _effectiveController.text.isNotEmpty;
    _effectiveController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final hasText = _effectiveController.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _handleClear() {
    _effectiveController.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  void dispose() {
    _effectiveController.removeListener(_handleTextChange);
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _effectiveController,
        focusNode: _effectiveFocusNode,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        textInputAction: TextInputAction.search,
        cursorColor: primaryColor,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1B1B1B),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: primaryColor,
            size: 22,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  splashRadius: 18,
                  onPressed: _handleClear,
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryColor,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
