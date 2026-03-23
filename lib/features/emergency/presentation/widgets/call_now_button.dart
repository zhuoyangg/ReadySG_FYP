import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class CallNowButton extends StatelessWidget {
  final VoidCallback onTap;

  const CallNowButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return SizedBox(
      width: double.infinity,
      height: scale.size(54),
      child: FilledButton.icon(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFFF0A0A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(scale.radius(12)),
          ),
        ),
        icon: Icon(Icons.phone_outlined, size: scale.icon(18)),
        label: Text(
          'CALL 995 NOW',
          style: TextStyle(
            fontSize: scale.font(16),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
