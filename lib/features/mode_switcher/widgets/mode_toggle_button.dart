import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_tokens.dart';
import '../providers/app_mode_provider.dart';

/// Floating action button for switching between Peaceful and Emergency modes.
/// Red shield = currently peaceful (tap to switch to emergency).
/// Blue shield = currently emergency (tap to switch back to peaceful).
class ModeToggleFab extends StatelessWidget {
  const ModeToggleFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModeProvider>(
      builder: (context, modeProvider, _) {
        final isSwitchingToEmergency = modeProvider.isPeaceful;
        final tokens = AppSemanticColors.of(context);
        final fabColor = isSwitchingToEmergency ? tokens.danger : tokens.progress;
        final semanticLabel = isSwitchingToEmergency
            ? 'Switch to Emergency mode'
            : 'Switch to Peaceful mode';

        return Semantics(
          button: true,
          label: semanticLabel,
          child: FloatingActionButton(
            onPressed: () => _showModeConfirmation(context, modeProvider),
            backgroundColor: fabColor,
            foregroundColor: Colors.white,
            elevation: 4,
            tooltip: semanticLabel,
            child: Icon(
              isSwitchingToEmergency
                  ? Icons.shield_outlined
                  : Icons.school_outlined,
              size: 26,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showModeConfirmation(
      BuildContext context, AppModeProvider modeProvider) async {
    final isSwitchingToEmergency = modeProvider.isPeaceful;
    final tokens = AppSemanticColors.of(context);
    final accentColor =
        isSwitchingToEmergency ? tokens.danger : tokens.progress;

    final title = isSwitchingToEmergency
        ? 'Switch to Emergency Mode?'
        : 'Switch to Peaceful Mode?';
    final description = isSwitchingToEmergency
        ? "You'll be redirected to Emergency Mode with quick access to "
            'emergency guides, AED locations, and emergency contacts.'
        : "You'll be redirected to Peaceful Mode with learning content "
            'and skill development modules.';
    final buttonLabel = 'Switch Mode';
    final icon = isSwitchingToEmergency ? Icons.shield_outlined : Icons.school_outlined;

    final shouldSwitch = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon row
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accentColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                description,
                style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                      color: AppSemanticColors.of(dialogContext).subtleText,
                    ),
              ),
              const SizedBox(height: 24),

              // Switch Mode button (full width)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(true),
                  child: Text(
                    buttonLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel button (full width, ghost)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldSwitch == true) {
      await modeProvider.toggleMode();
    }
  }
}

/// Legacy AppBar badge button — kept for any screens that still reference it.
/// Prefer [ModeToggleFab] for new UI.
class ModeToggleButton extends StatelessWidget {
  const ModeToggleButton({super.key});

  @override
  Widget build(BuildContext context) => const ModeToggleFab();
}
