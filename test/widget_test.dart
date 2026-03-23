import 'package:flutter_test/flutter_test.dart';

import 'package:ready_sg/app.dart';

void main() {
  testWidgets('ReadySG app boots to auth/loading flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReadySGApp());
    await tester.pumpAndSettle();

    // With no initialized Supabase session in widget tests, app should settle
    // into unauthenticated flow and render login content.
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Access Emergency Mode'), findsOneWidget);
  });
}
