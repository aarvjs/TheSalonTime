import 'package:flutter/material.dart';

class AppColorsData {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color secondary;
  final Color accent;
  final Color background;
  final Color cardBackground;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color border;
  final Color buttonText;
  final Color iconAccent;

  const AppColorsData({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.accent,
    required this.background,
    required this.cardBackground,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.border,
    required this.buttonText,
    required this.iconAccent,
  });
}

class AppColors {
  AppColors._();

  // Raw Palette
  static const Color warmIvory = Color(0xFFFDFBF7);
  static const Color softCream = Color(0xFFF9F6F0);
  static const Color charcoal = Color(0xFF2C2C2C);
  static const Color warmBlack = Color(0xFF1A1A1A);
  static const Color copper = Color(0xFFC86D51);
  static const Color burntOrange = Color(0xFFD96B43);
  static const Color champagneGold = Color(0xFFD4AF37);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color warmGray = Color(0xFFF3EFEA);
  static const Color softWarmGray = Color(0xFFE6E1DA);
  static const Color mutedTextGray = Color(0xFF7A7571);

  // Female Theme Specific
  static const Color softRose = Color(0xFFD98880);
  static const Color dustyPink = Color(0xFFC58276);
  static const Color blushPink = Color(0xFFF6ECE9);
  static const Color femaleAccent = Color(0xFFC0736B);

  // Male Theme Specific
  static const Color deepNavy = Color(0xFF1B2A47);
  static const Color navyBlue = Color(0xFF0F172A);
  static const Color maleGold = Color(0xFFC5A059);
  static const Color maleCardBg = Color(0xFFF7F5F0);

  // Partner Specific
  static const Color partnerPrimary = Color(0xFFC86D51);
  static const Color partnerSecondary = Color(0xFFD4AF37);

  // Manager Specific
  static const Color managerCopper = Color(0xFFA84D32);
  static const Color managerGold = Color(0xFFC5A059);

  // 1. Default Brand Theme
  static const AppColorsData defaultTheme = AppColorsData(
    primary: copper,
    primaryDark: Color(0xFFA65239),
    primaryLight: Color(0xFFE08D73),
    secondary: champagneGold,
    accent: burntOrange,
    background: warmIvory,
    cardBackground: pureWhite,
    surface: softCream,
    textPrimary: warmBlack,
    textSecondary: charcoal,
    textMuted: mutedTextGray,
    border: softWarmGray,
    buttonText: pureWhite,
    iconAccent: champagneGold,
  );

  // 2. Customer Female Theme
  static const AppColorsData customerFemaleTheme = AppColorsData(
    primary: femaleAccent,
    primaryDark: dustyPink,
    primaryLight: softRose,
    secondary: champagneGold,
    accent: softRose,
    background: warmIvory,
    cardBackground: pureWhite,
    surface: blushPink,
    textPrimary: warmBlack,
    textSecondary: charcoal,
    textMuted: mutedTextGray,
    border: Color(0xFFEAD8D5),
    buttonText: pureWhite,
    iconAccent: femaleAccent,
  );

  // 3. Customer Male Theme
  static const AppColorsData customerMaleTheme = AppColorsData(
    primary: deepNavy,
    primaryDark: navyBlue,
    primaryLight: Color(0xFF2C4066),
    secondary: maleGold,
    accent: maleGold,
    background: warmIvory,
    cardBackground: pureWhite,
    surface: maleCardBg,
    textPrimary: warmBlack,
    textSecondary: charcoal,
    textMuted: mutedTextGray,
    border: Color(0xFFDAD6CE),
    buttonText: pureWhite,
    iconAccent: maleGold,
  );

  // 4. Partner Theme
  static const AppColorsData partnerTheme = AppColorsData(
    primary: partnerPrimary,
    primaryDark: Color(0xFFA65239),
    primaryLight: Color(0xFFE08D73),
    secondary: champagneGold,
    accent: burntOrange,
    background: warmIvory,
    cardBackground: pureWhite,
    surface: softCream,
    textPrimary: warmBlack,
    textSecondary: charcoal,
    textMuted: mutedTextGray,
    border: softWarmGray,
    buttonText: pureWhite,
    iconAccent: champagneGold,
  );

  // 5. Branch Manager Theme
  static const AppColorsData managerTheme = AppColorsData(
    primary: managerCopper,
    primaryDark: Color(0xFF8A3B23),
    primaryLight: Color(0xFFC76D52),
    secondary: managerGold,
    accent: managerGold,
    background: warmIvory,
    cardBackground: pureWhite,
    surface: warmGray,
    textPrimary: warmBlack,
    textSecondary: charcoal,
    textMuted: mutedTextGray,
    border: softWarmGray,
    buttonText: pureWhite,
    iconAccent: managerGold,
  );
}
