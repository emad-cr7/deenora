import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? text2;
  final Color? iconColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final TextStyle? text2Style;
  final double spacing;
  final MainAxisSize mainAxisSize;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.text2,
    this.iconColor,
    this.iconSize,
    this.textStyle,
    this.text2Style,
    this.spacing = 7,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: mainAxisSize,
      children: [
        Icon(
          icon,
          size: iconSize ?? 14,
          color: iconColor ?? Colors.grey[500],
        ),
        SizedBox(width: spacing),
        Text(
          text,
          style: textStyle ??
              TextStyle(
                fontSize: 13,
                color: Colors.grey[900],
              ),
        ),
        if (text2 != null) ...[
          const SizedBox(width: 3),
          Text(
            text2!,
            style: text2Style ??
                TextStyle(
                  fontSize: 13,
                  color: Colors.grey[900],
                ),
          ),
        ],
      ],
    );
  }
}