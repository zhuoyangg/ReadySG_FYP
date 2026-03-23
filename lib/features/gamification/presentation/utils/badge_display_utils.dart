import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/models/badge_model.dart';

/// Returns the theme color for a badge category.
Color badgeCategoryColor(String category, AppSemanticColors tokens) {
  switch (category) {
    case 'milestone':
      return tokens.progress;
    case 'streak':
      return tokens.streak;
    case 'quiz':
      return tokens.achievement;
    default:
      return tokens.points;
  }
}

/// Maps an icon name string from [BadgeModel.iconName] to a Flutter [IconData].
IconData badgeIconData(String name) {
  switch (name) {
    case 'school':
      return Icons.school_rounded;
    case 'local_fire_department':
      return Icons.local_fire_department;
    case 'emoji_events':
      return Icons.emoji_events;
    case 'military_tech':
      return Icons.military_tech;
    case 'quiz':
      return Icons.quiz;
    case 'star':
      return Icons.star_rounded;
    case 'bolt':
      return Icons.bolt;
    case 'verified':
      return Icons.verified;
    case 'workspace_premium':
      return Icons.workspace_premium;
    default:
      return Icons.military_tech;
  }
}
