import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Branding Title: "The Salon Times"
  static TextStyle logoThe({Color color = AppColors.copper}) {
    return GoogleFonts.cormorantGaramond(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      letterSpacing: 2.5,
      color: color,
    );
  }

  static TextStyle logoSalon({Color color = AppColors.warmBlack}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
      color: color,
    );
  }

  static TextStyle logoTimes({Color color = AppColors.champagneGold}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      letterSpacing: 3.0,
      color: color,
    );
  }

  // General Headings
  static TextStyle h1({Color color = AppColors.warmBlack}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      height: 1.2,
      letterSpacing: -0.5,
      color: color,
    );
  }

  static TextStyle h2({Color color = AppColors.warmBlack}) {
    return GoogleFonts.playfairDisplay(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  static TextStyle h3({Color color = AppColors.warmBlack}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.3,
      color: color,
    );
  }

  // Subtitles & Body Text
  static TextStyle subtitle({Color color = AppColors.mutedTextGray}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle body({Color color = AppColors.charcoal}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle bodyBold({Color color = AppColors.charcoal}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.5,
      color: color,
    );
  }

  static TextStyle caption({Color color = AppColors.mutedTextGray}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: color,
    );
  }

  // Buttons & Controls
  static TextStyle button({Color color = AppColors.pureWhite}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
      color: color,
    );
  }

  static TextStyle textButton({Color color = AppColors.copper}) {
    return GoogleFonts.plusJakartaSans(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: color,
    );
  }
}
