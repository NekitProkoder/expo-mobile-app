import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String? text;

  const AppLoading({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFFACA2C),
          ),
          if (text != null) ...[
            const SizedBox(height: 14),
            Text(
              text!,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}