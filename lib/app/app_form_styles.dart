import 'package:flutter/material.dart';

const Color moneyDeepPurple = Color(0xFF2E115B);
const Color moneyGold = Color(0xFFE6BA53);
const Color moneyDark = Color(0xFF05040B);
const Color moneyCardDark = Color(0xFF111827);
const Color moneySoftPurple = Color(0xFFB47AE7);
const Color moneyPurple = Color(0xFF7329E7);
const Color moneyDarkNav = Color(0xFF111827);
const Color moneyNavItemDark = Color(0xFF1F2937);

bool appIsDarkMode(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark;
}

TextStyle appFieldTextStyle(BuildContext context) {
  final dark = appIsDarkMode(context);

  return TextStyle(
    color: dark ? Colors.white : const Color(0xFF101828),
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );
}

TextStyle appFieldLabelStyle(BuildContext context) {
  final dark = appIsDarkMode(context);

  return TextStyle(
    color: dark ? Colors.white70 : const Color(0xFF667085),
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
}

TextStyle appFieldHintStyle(BuildContext context) {
  final dark = appIsDarkMode(context);

  return TextStyle(
    color: dark ? Colors.white38 : const Color(0xFF98A2B3),
    fontSize: 15,
    fontWeight: FontWeight.w500,
  );
}

InputDecoration appInputDecoration(
  BuildContext context, {
  required String label,
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  final dark = appIsDarkMode(context);

  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: dark ? const Color(0xFF1F2937) : Colors.white,
    labelStyle: appFieldLabelStyle(context),
    hintStyle: appFieldHintStyle(context),
    floatingLabelStyle: TextStyle(
      color: dark ? moneyGold : moneyPurple,
      fontSize: 14,
      fontWeight: FontWeight.w800,
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 18,
      vertical: 18,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: dark ? Colors.white24 : const Color(0xFFE5E7EB),
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: dark ? Colors.white24 : const Color(0xFFE5E7EB),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: moneyPurple,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFDC2626),
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFDC2626),
        width: 1.5,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: dark ? Colors.white12 : const Color(0xFFE5E7EB),
      ),
    ),
  );
}

Color appSheetBackgroundColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? const Color(0xFF05040B) : const Color(0xFFF6F8FB);
}

Color appCardBackgroundColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? const Color(0xFF111827) : Colors.white;
}

Color appPrimaryTextColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? Colors.white : const Color(0xFF111827);
}

Color appSecondaryTextColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? Colors.white70 : const Color(0xFF6B7280);
}

Color appBorderColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? Colors.white12 : const Color(0xFFE5E7EB);
}

Color appDarkPreviewColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? const Color(0xFF020617) : const Color(0xFF111827);
}

Color appAccentColor(BuildContext context) {
  return moneyPurple;
}

Color appPremiumAccentColor(BuildContext context) {
  return moneyGold;
}

Color appAccentSoftColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return moneyPurple.withValues(alpha: dark ? 0.24 : 0.12);
}

Color appPremiumSoftColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return moneyGold.withValues(alpha: dark ? 0.22 : 0.14);
}

Color appAccentTextColor(BuildContext context) {
  final dark = appIsDarkMode(context);
  return dark ? moneySoftPurple : moneyPurple;
}