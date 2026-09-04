import 'package:deenora/features/Quran/Listening/widgets/reciter_card.dart';
import 'package:deenora/features/Quran/Listening/models_listening/reciter_model.dart';
import 'package:flutter/material.dart';


class QuranListening extends StatelessWidget {
  const QuranListening({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: reciters.length,
          itemBuilder: (context, index) {
            return ReciterCard(reciter: reciters[index]);
          },
        ),
      ),
    );
  }
}