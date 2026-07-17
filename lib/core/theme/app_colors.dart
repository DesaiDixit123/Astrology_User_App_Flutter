import 'package:flutter/material.dart';

class AppColors {
  // Logo-inspired sacred earth palette
  static const Color primary = Color(0xFF8C4B1F); // Sandalwood brown
  static const Color primaryDark = Color(0xFF5E2E12); // Deep temple wood
  static const Color primaryLight = Color(0xFFB97A3D); // Burnished bronze

  // Signature tones pulled from the logo
  static const Color gold = Color(0xFFD7A545);
  static const Color deepCosmic = Color(0xFF4A2411);
  static const Color lightCosmic = Color(0xFF9F6430);

  // Supporting brand colors
  static const Color secondary = Color(0xFFD6A85D); // Warm muted gold
  static const Color secondaryDark = Color(0xFFB78432); // Antique gold
  static const Color secondaryLight = Color(0xFFF2D29A); // Sand glow

  // Accent Colors
  static const Color accent = Color(0xFFB73716); // Vermilion
  static const Color accentLight = Color(0xFFD96C3A);

  // Background Colors
  static const Color background = Color(0xFFF6E7C6); // Parchment
  static const Color surface = Color(0xFFFFF8EA); // Soft ivory
  static const Color surfaceDark = Color(0xFF2F180D);

  // Text Colors
  static const Color textPrimary = Color(0xFF4A2411);
  static const Color textSecondary = Color(0xFF7B5C44);
  static const Color textHint = Color(0xFFB89B7A);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF477A43);
  static const Color error = Color(0xFFC14A32);
  static const Color warning = Color(0xFFD19A2A);
  static const Color info = Color(0xFF7A644A);

  // Premium Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFB97A3D), Color(0xFF8C4B1F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cosmicGradient = LinearGradient(
    colors: [Color(0xFF5E2E12), Color(0xFF8C4B1F), Color(0xFFD7A545)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFF2D29A), Color(0xFFD7A545)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGradient = LinearGradient(
    colors: [Color(0xFF6D3718), Color(0xFF4A2411)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient parchmentGradient = LinearGradient(
    colors: [Color(0xFFF8E9C9), Color(0xFFEFCF93), Color(0xFFD9A85B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient sacredGradient = LinearGradient(
    colors: [Color(0xFF4A2411), Color(0xFF8C4B1F), Color(0xFFB73716)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Glassmorphism
  static Color glassBackground = Colors.white.withValues(alpha: 0.1);
  static Color glassBorder = const Color(0xFFF2D29A).withValues(alpha: 0.28);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  static List<BoxShadow> luxuryShadow = [
    BoxShadow(
      color: const Color(0xFF7A4A1C).withValues(alpha: 0.14),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];

  // Border Colors
  static const Color border = Color(0xFFD6BB90);
  static const Color borderLight = Color(0xFFE8D4B1);

  // Shop Specific Colors
  static const Color shopBackground = Color(0xFFFFF5E4);
  static const Color shopMaroon = Color(0xFF4A2411);
  static const Color shopGold = Color(0xFFD7A545);
  static const Color shopPillGreen = Color(0xFFE8F5E9);
  static const Color shopPillYellow = Color(0xFFFFFDE7);
  static const Color shopPillBlue = Color(0xFFE3F2FD);
  static const Color shopTextGreen = Color(0xFF2E7D32);
  static const Color shopTextYellow = Color(0xFFF9A825);
  static const Color shopTextBlue = Color(0xFF1976D2);
}
