import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class GuideDetailHero extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const GuideDetailHero({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        scale.space(18),
        scale.space(10),
        scale.space(18),
        scale.space(18),
      ),
      decoration: BoxDecoration(
        color: Color(0xFFE10600),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(scale.radius(28)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(scale.radius(14)),
                ),
                child: IconButton(
                  onPressed: onBack,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: scale.icon(20),
                  ),
                  color: Colors.white,
                  tooltip: 'Back to Guides',
                  padding: EdgeInsets.all(scale.space(10)),
                  constraints: BoxConstraints(
                    minWidth: scale.size(44),
                    minHeight: scale.size(44),
                  ),
                ),
              ),
              SizedBox(width: scale.space(12)),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: scale.space(2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Guide',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                      ),
                      SizedBox(height: scale.space(4)),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
