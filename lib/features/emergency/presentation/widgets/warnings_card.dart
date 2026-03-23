import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class WarningsCard extends StatelessWidget {
  final List<String> items;

  const WarningsCard({super.key, required this.items});

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
        color: const Color(0xFFFFF9DB),
        borderRadius: BorderRadius.circular(scale.radius(16)),
        border: Border.all(color: const Color(0xFFFFC933)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Color(0xFFD97706),
                size: scale.icon(20),
              ),
              SizedBox(width: scale.space(8)),
              Text(
                'Important Warnings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
              ),
            ],
          ),
          SizedBox(height: scale.space(12)),
          ...items.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: scale.space(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: scale.space(2)),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFFD97706),
                      size: scale.icon(18),
                    ),
                  ),
                  SizedBox(width: scale.space(10)),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF111827),
                            height: 1.45,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
