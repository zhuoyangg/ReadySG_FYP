import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/signed_in_state_refresh_service.dart';
import '../../../../shared/widgets/bottom_navigation.dart';
import '../../../../shared/widgets/call_help_page.dart';
import '../../../aed/presentation/screens/aed_locator_screen.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../emergency/presentation/screens/emergency_guides_screen.dart';
import '../../../gamification/providers/gamification_provider.dart';
import '../../../gamification/providers/spaced_practice_provider.dart';
import '../../../learning/presentation/screens/courses_screen.dart';
import '../../../mode_switcher/providers/app_mode_provider.dart';
import '../../../mode_switcher/widgets/mode_toggle_button.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import 'dashboard_screen.dart';

/// Main home screen - the shell that hosts all primary app pages.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final SignedInStateRefreshService _refreshService =
      SignedInStateRefreshService();

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModeProvider>(
      builder: (context, modeProvider, _) {
        final pages = modeProvider.isPeaceful ? _peacefulPages : _emergencyPages;
        final safeIndex = _currentIndex >= pages.length ? 0 : _currentIndex;

        return Scaffold(
          extendBodyBehindAppBar: true,
          body: IndexedStack(
            index: safeIndex,
            children: pages,
          ),
          bottomNavigationBar: AppBottomNavigation(
            key: ValueKey(modeProvider.currentMode),
            currentIndex: safeIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
              if (index == 0 && modeProvider.isPeaceful) {
                final userId = context.read<AuthProvider>().currentUser?.id;
                if (userId != null) {
                  _refreshService.refresh(
                    userId: userId,
                    authProvider: context.read<AuthProvider>(),
                    gamificationProvider: context.read<GamificationProvider>(),
                    spacedPracticeProvider:
                        context.read<SpacedPracticeProvider>(),
                  );
                }
              }
            },
          ),
          floatingActionButton: const ModeToggleFab(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  List<Widget> get _peacefulPages => [
        DashboardScreen(
          onNavigateToPractice: () => setState(() => _currentIndex = 2),
        ),
        const CoursesScreen(),
        const PracticeScreen(),
        const ProfileScreen(),
      ];

  List<Widget> get _emergencyPages => const [
        EmergencyGuidesScreen(),
        AEDLocatorScreen(),
        CallHelpPage(),
        ProfileScreen(),
      ];
}
