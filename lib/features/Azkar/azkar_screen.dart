import 'package:flutter/material.dart';

import '../../core/data/remote_data/azkara/azkara_service.dart';
import '../../core/enum/azkar_model/zekr_category.dart';
import '../../core/enum/enum_azkar_category.dart';
import '../../core/skeleton/azkar_Item_skeleton.dart';
import '../../core/widget/error/error_screen.dart';
import 'azkar_details/azkar_details_screen.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final AzkaraService _service = AzkaraService();
  late Future<ZekrCategory> _azkarFuture;

  @override
  void initState() {
    super.initState();
    _azkarFuture = _service.getAzkar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Azkar')),
      body: FutureBuilder<ZekrCategory>(
        future: _azkarFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AzkarItemSkeleton();
          }
          if (snapshot.hasError) {
            return AppErrorScreen(type: AppErrorType.serverError);
          }
          final model = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: AzkarCategory.values.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final category = AzkarCategory.values[index];
              final count = category.getList(model).length;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(25),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AzkarDetailsScreen(
                        title: category.arabicName,
                        zekrList: category.getList(model),
                      ),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF0E5B4A).withValues(alpha: 0.07),
                          const Color(0xFFC9A24B).withValues(alpha: 0.04),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF0E5B4A).withValues(alpha: 0.15),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0E5B4A).withOpacity(0.10),
                          ),
                          child: Icon(
                            category.icon,
                            size: 26,
                            color: const Color(0xFF0E5B4A),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.englishName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF163B33),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFFC9A24B,
                                      ).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$count Dhikr',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8A6D1D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                          color: Color(0xFF0E5B4A),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
