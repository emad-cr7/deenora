import 'package:flutter/material.dart';

class MosqueScreen extends StatelessWidget {
  const MosqueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('Mosque', style: TextStyle(fontSize: 50))),
    );
  }
}
