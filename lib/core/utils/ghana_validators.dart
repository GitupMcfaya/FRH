abstract final class GhanaValidators {
  static final _phonePattern = RegExp(r'^(?:\+233|0)[235][0-9]{8}$');
  static final _ghanaCardPattern = RegExp(
    r'^GHA-[0-9]{9}-[0-9]$',
    caseSensitive: false,
  );
  static final _studentIdPattern = RegExp(r'^[A-Z0-9][A-Z0-9/-]{3,19}$');
  static final _badgePattern = RegExp(r'^V-[0-9]{3,}$', caseSensitive: false);

  static bool isPhoneNumber(String value) =>
      _phonePattern.hasMatch(value.replaceAll(RegExp(r'[\s-]'), ''));

  static bool isGhanaCardNumber(String value) =>
      _ghanaCardPattern.hasMatch(value.trim());

  static bool isStudentId(String value) =>
      _studentIdPattern.hasMatch(value.trim().toUpperCase());

  static bool isBadgeNumber(String value) =>
      _badgePattern.hasMatch(value.trim());
}
