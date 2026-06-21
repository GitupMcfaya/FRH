import 'package:flutter_test/flutter_test.dart';
import 'package:hostel_visitor_manager/core/utils/ghana_validators.dart';

void main() {
  group('GhanaValidators', () {
    test('accepts local and international Ghana mobile numbers', () {
      expect(GhanaValidators.isPhoneNumber('024 123 4567'), isTrue);
      expect(GhanaValidators.isPhoneNumber('+233 24 123 4567'), isTrue);
      expect(GhanaValidators.isPhoneNumber('0141234567'), isFalse);
    });

    test('validates Ghana Card, student, and badge formats', () {
      expect(GhanaValidators.isGhanaCardNumber('GHA-123456789-1'), isTrue);
      expect(GhanaValidators.isGhanaCardNumber('123456789'), isFalse);
      expect(GhanaValidators.isStudentId('UG1234567'), isTrue);
      expect(GhanaValidators.isBadgeNumber('V-001'), isTrue);
    });
  });
}
