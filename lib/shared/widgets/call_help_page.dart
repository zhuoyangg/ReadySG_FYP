import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_feedback.dart';
import 'call_help/call_help_contact_card.dart';
import 'call_help/call_help_hero.dart';
import 'call_help/call_help_info_cards.dart';
import 'call_help/call_help_primary_card.dart';

/// Shared call-for-help page used in both Peaceful (HomeScreen) and
/// Guest Emergency shells.
class CallHelpPage extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onSignIn;

  const CallHelpPage({super.key, this.onBack, this.onSignIn});

  static Future<void> _dial(BuildContext context, String number) async {
    final uri = Uri.parse('tel:${number.replaceAll('-', '')}');
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        AppFeedback.show(
          context,
          'Unable to open the phone dialer on this device.',
          type: AppFeedbackType.warning,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppFeedback.show(
          context,
          'Unable to open the phone dialer on this device.',
          type: AppFeedbackType.warning,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = <CallHelpContactData>[
      CallHelpContactData(
        title: 'Non-Emergency Ambulance',
        subtitle: 'For non-life threatening cases',
        number: AppConstants.nonEmergencyAmbulanceNumber,
        accent: const Color(0xFFE85D04),
        icon: Icons.favorite_border_rounded,
      ),
      CallHelpContactData(
        title: 'Police',
        subtitle: 'For urgent police assistance and crime emergencies',
        number: AppConstants.policeNumber,
        accent: const Color(0xFF2563EB),
        icon: Icons.local_police_outlined,
      ),
      CallHelpContactData(
        title: 'National Mindline',
        subtitle: '24/7 mental health crisis support',
        number: AppConstants.nationalMindlineNumber,
        accent: const Color(0xFF2563EB),
        icon: Icons.psychology_alt_outlined,
      ),
      CallHelpContactData(
        title: 'Samaritans of Singapore',
        subtitle: '24/7 suicide prevention hotline',
        number: AppConstants.samaritansHotlineNumber,
        accent: const Color(0xFF9333EA),
        icon: Icons.support_agent_rounded,
      ),
    ];

    return Container(
      color: const Color(0xFFFFF5F5),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CallHelpHero(onBack: onBack, onSignIn: onSignIn),
            Transform.translate(
              offset: const Offset(0, -12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CallHelpPrimaryCard(
                  number: AppConstants.emergencyNumber,
                  label: 'SCDF Emergency Hotline',
                  onTap: () => _dial(context, AppConstants.emergencyNumber),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: CallHelpWhenToCallCard(
                title: 'When to call 995',
                body:
                    'Life-threatening emergencies including cardiac arrest, severe bleeding, choking, unconsciousness, severe burns, or any situation requiring immediate medical attention.',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Text(
                'Other Emergency Numbers',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: contacts
                    .map(
                      (contact) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: CallHelpContactCard(
                          data: contact,
                          onTap: () => _dial(context, contact.number),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: CallHelpChecklistCard(
                title: 'When Calling Emergency Services',
                items: const [
                  'State your location clearly and precisely',
                  'Describe the emergency situation calmly',
                  'Follow dispatcher\'s instructions carefully',
                  'Stay on the line until told to hang up',
                  'Keep phone nearby for callback',
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CallHelpInfoBannerCard(
                title: 'Singapore Civil Defence Force',
                subtitle:
                    'SCDF responds to all fire, rescue, and medical emergencies in Singapore',
                icon: Icons.shield_outlined,
                accent: const Color(0xFFE53935),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
