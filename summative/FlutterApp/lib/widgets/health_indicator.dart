import 'package:flutter/material.dart';

class HealthIndicator extends StatelessWidget {
  final bool? isApiOnline;
  final VoidCallback onTap;

  const HealthIndicator({
    Key? key,
    required this.isApiOnline,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color dotColor;
    final String statusText;

    if (isApiOnline == null) {
      dotColor = Colors.orangeAccent;
      statusText = 'Checking...';
    } else if (isApiOnline == true) {
      dotColor = Colors.lightGreenAccent;
      statusText = 'API Online';
    } else {
      dotColor = Colors.redAccent;
      statusText = 'API Offline';
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: dotColor.withOpacity(0.6),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}