import 'package:flutter/material.dart';

/// Reusable section header with title and optional trailing widget.
class ReadySectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const ReadySectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        ?trailing,
      ],
    );
  }
}
