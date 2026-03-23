import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class AedHero extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;

  const AedHero({super.key, this.onBack, this.onSignIn});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(bottom: scale.space(scale.compactPhone ? 8 : 10)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(
          scale.space(22),
          scale.space(scale.compactPhone ? 20 : 24),
          scale.space(22),
          scale.space(scale.compactPhone ? 18 : 24),
        ),
        color: const Color(0xFFE10600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onBack != null || onSignIn != null) ...[
              Row(
                children: [
                  if (onBack != null)
                    _AedHeaderAction(
                      icon: Icons.arrow_back_rounded,
                      label: 'Back',
                      onTap: onBack!,
                    )
                  else
                    SizedBox(width: scale.space(44)),
                  const Spacer(),
                  if (onSignIn != null)
                    _AedHeaderAction(
                      icon: Icons.login_rounded,
                      label: 'Sign In',
                      onTap: onSignIn!,
                    ),
                ],
              ),
              SizedBox(height: scale.space(16)),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: scale.icon(scale.compactPhone ? 30 : 34),
                  height: scale.icon(scale.compactPhone ? 30 : 34),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFFFD4D4),
                    size: scale.icon(scale.compactPhone ? 18 : 20),
                  ),
                ),
                SizedBox(width: scale.space(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AED Locations',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: scale.font(scale.compactPhone ? 18 : 20),
                            ),
                      ),
                      SizedBox(height: scale.space(6)),
                      Text(
                        'Find nearest Automated External Defibrillator',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              height: 1.35,
                              fontSize: scale.font(scale.compactPhone ? 13 : 14),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AedHeaderAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AedHeaderAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: scale.space(12),
            vertical: scale.space(8),
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: scale.icon(18), color: Colors.white),
              SizedBox(width: scale.space(6)),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: scale.font(14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
