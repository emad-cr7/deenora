import 'package:flutter/material.dart';

class SearchSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const SearchSectionHeader({
    super.key,
    required this.title,
    this.count,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  static const Color primaryColor = Color(0xFF1B5E4F);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1B1B),
                  letterSpacing: 0.3,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
