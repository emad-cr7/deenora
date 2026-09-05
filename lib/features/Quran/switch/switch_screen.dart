import 'package:flutter/material.dart';
import '../Listening/widgets/main_audio/quran_listening.dart';
import '../reading/quran_reading.dart';

class SwitchScreen extends StatefulWidget {
  const SwitchScreen({super.key});

  @override
  State<SwitchScreen> createState() => _SwitchScreenState();
}

class _SwitchScreenState extends State<SwitchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color primaryColor = Color(0xFF1B5E4F);
  static const Color unselectedColor = Color(0xFF6B6B6B);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quran',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: _buildTabSelector(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [QuranReading(), QuranListening()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return SizedBox(
      height: 46,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.all(4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double itemWidth = constraints.maxWidth / 2;

            return AnimatedBuilder(
              animation: _tabController.animation!,
              builder: (context, _) {
                final double t = _tabController.animation!.value.clamp(
                  0.0,
                  1.0,
                );

                return Stack(
                  children: [
                    Positioned(
                      left: t * itemWidth,
                      top: 0,
                      bottom: 0,
                      width: itemWidth,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        _buildTabItem(
                          index: 0,
                          icon: Icons.menu_book_rounded,
                          label: 'reading',
                          t: t,
                        ),
                        _buildTabItem(
                          index: 1,
                          icon: Icons.headphones_rounded,
                          label: 'listening',
                          t: t,
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required double t,
  }) {
    final double selectedAmount = 1 - (t - index).abs().clamp(0.0, 1.0);
    final Color color = Color.lerp(
      unselectedColor,
      Colors.white,
      selectedAmount,
    )!;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _tabController.animateTo(index),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
