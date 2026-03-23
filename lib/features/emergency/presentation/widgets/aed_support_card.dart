import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class AedSupportCard extends StatelessWidget {
  final VoidCallback onFindAed;

  const AedSupportCard({super.key, required this.onFindAed});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        scale.space(16),
        scale.space(16),
        scale.space(16),
        scale.space(18),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2FE),
        borderRadius: BorderRadius.circular(scale.radius(16)),
        border: Border.all(color: const Color(0xFF7DD3FC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: Color(0xFF0F172A),
                size: scale.icon(18),
              ),
              SizedBox(width: scale.space(4)),
              Text(
                'Need an AED?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: scale.space(12)),
          Text(
            'Find the nearest Automated External Defibrillator on the AED Map.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF1F2937),
                  height: 1.45,
                ),
          ),
          SizedBox(height: scale.space(14)),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onFindAed,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1D4ED8),
                side: const BorderSide(color: Color(0xFF3B82F6)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(scale.radius(10)),
                ),
              ),
              child: Text(
                'Find Nearest AED',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: scale.font(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
