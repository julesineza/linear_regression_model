import 'package:flutter/material.dart';

class PredictionDisplay extends StatelessWidget {
  final String message;
  final bool isError;

  const PredictionDisplay({
    Key? key,
    required this.message,
    required this.isError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = message.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEmpty
            ? Colors.grey.shade100
            : (isError ? Colors.red.shade50 : Colors.green.shade50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isEmpty
              ? Colors.grey.shade300
              : (isError ? Colors.red : Colors.green),
          width: 1.5,
        ),
      ),
      child: Text(
        isEmpty
            ? 'Enter the crop details above and press Predict to see the result.'
            : message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isEmpty ? FontWeight.normal : FontWeight.bold,
          color: isEmpty
              ? Colors.grey.shade700
              : (isError ? Colors.red.shade900 : Colors.green.shade900),
        ),
      ),
    );
  }
}