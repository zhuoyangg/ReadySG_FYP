import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/call_help_page.dart';
import '../../../aed/presentation/screens/aed_locator_screen.dart';
import 'emergency_guides_screen.dart';

/// Emergency mode shell for unauthenticated (guest) users.
///
/// Provides read-only access to Guides, AED Locator, and emergency call
/// numbers without requiring login.
class GuestEmergencyScreen extends StatefulWidget {
  const GuestEmergencyScreen({super.key});

  @override
  State<GuestEmergencyScreen> createState() => _GuestEmergencyScreenState();
}

class _GuestEmergencyScreenState extends State<GuestEmergencyScreen> {
  int _currentIndex = 0;

  static const _tabs = [
    (icon: Icons.local_hospital_outlined, label: 'Guides'),
    (icon: Icons.location_on_outlined, label: 'AED Map'),
    (icon: Icons.phone_outlined, label: 'Call Help'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      EmergencyGuidesScreen(
        onBack: () => context.go('/login'),
        onSignIn: () => context.go('/login'),
      ),
      AEDLocatorScreen(
        onBack: () => context.go('/login'),
        onSignIn: () => context.go('/login'),
      ),
      CallHelpPage(
        onBack: () => context.go('/login'),
        onSignIn: () => context.go('/login'),
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: _GuestBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class _GuestBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GuestBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = _GuestEmergencyScreenState._tabs;
    final primaryColor = Theme.of(context).colorScheme.primary;

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
                child: _GuestNavItem(
                  icon: items[i].icon,
                  label: items[i].label,
                  isSelected: i == currentIndex,
                  primaryColor: primaryColor,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _GuestNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _GuestNavItem({
    required this.icon,
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
                  icon,
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

