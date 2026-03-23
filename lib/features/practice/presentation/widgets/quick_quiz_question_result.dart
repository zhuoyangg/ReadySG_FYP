import 'package:flutter/material.dart';

class QuickQuizQuestionResult extends StatelessWidget {
  final int index;
  final String question;
  final String selectedAnswer;
  final String correctAnswer;
  final String explanation;
  final bool isCorrect;

  const QuickQuizQuestionResult({
    super.key,
    required this.index,
    required this.question,
    required this.selectedAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _QuickQuizBreakdownPalette.forState(isCorrect);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Text(
                    isCorrect ? '🎉' : '✗',
                    style: TextStyle(
                      fontSize: isCorrect ? 18 : 16,
                      color: isCorrect ? null : const Color(0xFF111827),
                      fontWeight: isCorrect ? null : FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Q${index + 1}: $question',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: palette.title,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!isCorrect) ...[
              _QuickQuizAnswerRow(
                label: 'Your answer',
                value: selectedAnswer,
                isCorrect: false,
              ),
              const SizedBox(height: 4),
            ],
            _QuickQuizAnswerRow(
              label: 'Correct',
              value: correctAnswer,
              isCorrect: true,
            ),
            const SizedBox(height: 8),
            Text(
              explanation,
              style: TextStyle(
                fontSize: 12,
                color: palette.body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickQuizAnswerRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isCorrect;

  const _QuickQuizAnswerRow({
    required this.label,
    required this.value,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _QuickQuizBreakdownPalette.forState(isCorrect);
    final compact = MediaQuery.sizeOf(context).width < 360;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCorrect ? palette.title : palette.label,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(fontSize: 12, color: palette.body),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isCorrect ? palette.title : palette.label,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: palette.body),
          ),
        ),
      ],
    );
  }
}

class _QuickQuizBreakdownPalette {
  final Color background;
  final Color border;
  final Color title;
  final Color label;
  final Color body;

  const _QuickQuizBreakdownPalette({
    required this.background,
    required this.border,
    required this.title,
    required this.label,
    required this.body,
  });

  factory _QuickQuizBreakdownPalette.forState(bool isCorrect) {
    if (isCorrect) {
      return const _QuickQuizBreakdownPalette(
        background: Color(0xFFEFF7F1),
        border: Color(0xFFB8D8BF),
        title: Color(0xFF4CAF66),
        label: Color(0xFF4CAF66),
        body: Color(0xFF6EBA7C),
      );
    }

    return const _QuickQuizBreakdownPalette(
      background: Color(0xFFFDF1F1),
      border: Color(0xFFF2C0BE),
      title: Color(0xFFEF5350),
      label: Color(0xFFEF5350),
      body: Color(0xFFEF6C63),
    );
  }
}
