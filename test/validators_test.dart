import 'package:flutter_test/flutter_test.dart';
import 'package:ready_sg/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty values', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email(null), 'Email is required');
    });

    test('validates email format', () {
      expect(Validators.email('invalid-email'), 'Enter a valid email address');
      expect(Validators.email('user@example.com'), isNull);
    });
  });

  group('Validators.password', () {
    test('enforces minimum length', () {
      expect(Validators.password('12345'), 'Password must be at least 6 characters');
      expect(Validators.password('123456'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('detects mismatch', () {
      expect(Validators.confirmPassword('abc123', 'abc124'), 'Passwords do not match');
      expect(Validators.confirmPassword('abc123', 'abc123'), isNull);
    });
  });
}
