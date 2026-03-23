import 'package:flutter/material.dart';

class PracticeSectionHeading extends StatelessWidget {
  final String title;
  final IconData? icon;

  const PracticeSectionHeading({super.key, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: const Color(0xFFFF9F1A)),
          const SizedBox(width: 8),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
        ),
      ],
    );
  }
}
