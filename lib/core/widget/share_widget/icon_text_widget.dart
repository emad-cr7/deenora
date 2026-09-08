import 'package:flutter/material.dart';

class IconTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? text2;

  const IconTextWidget({
    super.key,
    required this.icon,
    required this.text,
    this.text2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 7),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[900],
          ),
        ),
        SizedBox(width: 3,),

        if (text2 != null)
          Text(
            text2!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[900],
            ),
          ),
      ],
    );
  }
}