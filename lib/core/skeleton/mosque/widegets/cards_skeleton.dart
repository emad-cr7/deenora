import 'package:flutter/material.dart';
import 'package:flutter_islamic_icons/flutter_islamic_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../widget/share_widget/option_tile_share.dart';


class CardsSkeleton extends StatelessWidget {
  const CardsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        duration: const Duration(milliseconds: 1200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OptionTileShare(
              title: 'Tasbeeh',
              subtitle: 'Count your dhikr and get closer to Allah',
              icon: FlutterIslamicIcons.solidTasbih,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
