import 'package:flutter/material.dart';

class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Программа'),
        backgroundColor: const Color(0xFFFACA2C),
      ),
      body: const Center(
        child: Text('Программа выставки'),
      ),
    );
  }
}