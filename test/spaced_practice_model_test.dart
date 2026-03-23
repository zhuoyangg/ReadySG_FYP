import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/features/gamification/data/models/spaced_practice_model.dart';

void main() {
  test('nextInterval advances through fixed schedule and caps at 30', () {
    expect(SpacedPracticeModel.nextInterval(1), 3);
    expect(SpacedPracticeModel.nextInterval(3), 7);
    expect(SpacedPracticeModel.nextInterval(7), 14);
    expect(SpacedPracticeModel.nextInterval(14), 30);
    expect(SpacedPracticeModel.nextInterval(30), 30);
  });

  test('nextInterval returns 30 for unknown current values', () {
    expect(SpacedPracticeModel.nextInterval(0), 30);
    expect(SpacedPracticeModel.nextInterval(999), 30);
  });
}
