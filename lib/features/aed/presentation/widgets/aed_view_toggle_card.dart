import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';

class AedViewToggleCard extends StatelessWidget {
  final bool compact;
  final bool isLocating;
  final bool showMap;
  final ValueChanged<bool> onSelectionChanged;

  const AedViewToggleCard({
    super.key,
    required this.compact,
    required this.isLocating,
    required this.showMap,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scale = AppScale.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        scale.space(16),
        0,
        scale.space(16),
        scale.space(compact ? 6 : 8),
      ),
      child: Container(
        padding: EdgeInsets.all(scale.space(compact ? 6 : 8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(scale.radius(16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: scale.space(12),
              offset: Offset(0, scale.space(6)),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 360;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(narrow ? 'Map' : 'Map View'),
                        icon: Icon(
                          Icons.location_on_outlined,
                          size: scale.icon(narrow ? 16 : 18),
                        ),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(narrow ? 'List' : 'List View'),
                        icon: Icon(
                          Icons.format_list_bulleted_rounded,
                          size: scale.icon(narrow ? 16 : 18),
                        ),
                      ),
                    ],
                    selected: {showMap},
                    style: ButtonStyle(
                      textStyle: WidgetStateProperty.all(
                        TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: scale.font(narrow ? 12 : 14),
                        ),
                      ),
                      side: WidgetStateProperty.all(BorderSide.none),
                      backgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? const Color(0xFFF8FAFC)
                            : Colors.transparent,
                      ),
                    ),
                    onSelectionChanged: (selection) {
                      onSelectionChanged(selection.first);
                    },
                  ),
                ),
                if (isLocating) ...[
                  SizedBox(width: scale.space(10)),
                  SizedBox(
                    width: scale.icon(16),
                    height: scale.icon(16),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
