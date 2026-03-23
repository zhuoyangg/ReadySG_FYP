import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/mode_switcher/providers/app_mode_provider.dart';

/// Mode-aware floating bottom navigation bar.
/// Active destination shows a filled circular indicator; inactive shows icon + label only.
class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModeProvider>(
      builder: (context, modeProvider, _) {
        final items = modeProvider.isPeaceful
            ? _peacefulItems()
            : _emergencyItems();

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: _NavItem(
                      icon: items[i].icon,
                      selectedIcon: items[i].selectedIcon,
                      label: items[i].label,
                      isSelected: i == currentIndex,
                      primaryColor: Theme.of(context).colorScheme.primary,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_NavItemData> _peacefulItems() => const [
        _NavItemData(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
        _NavItemData(icon: Icons.school_outlined, selectedIcon: Icons.school, label: 'Learn'),
        _NavItemData(icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center, label: 'Practice'),
        _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ];

  List<_NavItemData> _emergencyItems() => const [
        _NavItemData(icon: Icons.local_hospital_outlined, selectedIcon: Icons.local_hospital, label: 'Guides'),
        _NavItemData(icon: Icons.location_on_outlined, selectedIcon: Icons.location_on, label: 'AED Map'),
        _NavItemData(icon: Icons.phone_outlined, selectedIcon: Icons.phone, label: 'Call Help'),
        _NavItemData(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
      ];
}

class _NavItemData {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const _NavItemData({required this.icon, required this.selectedIcon, required this.label});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 380;
    final navIconSize = compact ? 20.0 : 22.0;
    final navBadgeSize = compact ? 42.0 : 46.0;
    final labelFontSize = compact ? 10.0 : 11.0;

    return Semantics(
      button: true,
      label: label,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: navBadgeSize,
                height: navBadgeSize,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  size: navIconSize,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: labelFontSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? primaryColor : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
