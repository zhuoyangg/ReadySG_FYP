import 'package:flutter/material.dart';

class EmergencySituationCard extends StatelessWidget {
  const EmergencySituationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Emergency situation help card',
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFB4B0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFFFC107),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Emergency Situation?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF1F2937),
                      height: 1.45,
                    ),
                children: const [
                  TextSpan(text: 'Call '),
                  TextSpan(
                    text: '995',
                    style: TextStyle(
                      color: Color(0xFFE10600),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text:
                        " immediately if someone's life is in danger. Use these guides while waiting for help.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
