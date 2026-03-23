import 'package:flutter/material.dart';

class CourseFilterBar extends StatelessWidget {
  final String sortMode;
  final ValueChanged<String> onSortChanged;

  const CourseFilterBar({
    super.key,
    required this.sortMode,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          _FilterButton(
            icon: Icons.tune,
            label: 'Difficulty',
            isActive: sortMode == 'difficulty',
            onTap: () => onSortChanged('difficulty'),
          ),
          const SizedBox(width: 10),
          _FilterButton(
            icon: Icons.trending_up,
            label: 'Progress',
            isActive: sortMode == 'progress',
            onTap: () => onSortChanged('progress'),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : Colors.transparent,
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
