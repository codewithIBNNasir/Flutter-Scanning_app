import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
 
  static const Color background = Color(0xFF080C14);
  static const Color surface = Color(0xFF0F1825);
  static const Color surfaceElevated = Color(0xFF162033);
  static const Color cardBg = Color(0xFF111927);

  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color neonPurple = Color(0xFF7C4DFF);
  static const Color neonGreen = Color(0xFF00E676);
  static const Color neonOrange = Color(0xFFFF6D00);
  static const Color neonPink = Color(0xFFE040FB);
  static const Color neonBlue = Color(0xFF2979FF);

  static const Color textPrimary = Color(0xFFE8EDF5);
  static const Color textSecondary = Color(0xFF8899AA);
  static const Color textMuted = Color(0xFF445566);
  static const Color border = Color(0xFF1E2D3D);
  static const Color borderGlow = Color(0xFF00E5FF22);


  static const Color cameraColor = Color(0xFF00E5FF);
  static const Color fingerprintColor = Color(0xFF7C4DFF);
  static const Color audioColor = Color(0xFF00E676);
  static const Color videoColor = Color(0xFFFF6D00);
  static const Color qrColor = Color(0xFFE040FB);

  static const LinearGradient cameraGradient = LinearGradient(
    colors: [Color(0xFF00B8D4), Color(0xFF006064)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient fingerprintGradient = LinearGradient(
    colors: [Color(0xFF7C4DFF), Color(0xFF311B92)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient audioGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00600F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient videoGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFBF360C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient qrGradient = LinearGradient(
    colors: [Color(0xFFE040FB), Color(0xFF4A148C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: neonCyan,
          secondary: neonPurple,
          surface: surface,
          background: background,
        ),
        textTheme: GoogleFonts.rajdhaniTextTheme().copyWith(
          displayLarge: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          displayMedium: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
          headlineLarge: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
          headlineMedium: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: GoogleFonts.rajdhani(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          bodyLarge: GoogleFonts.rajdhani(
            color: textSecondary,
            fontSize: 16,
          ),
          bodyMedium: GoogleFonts.rajdhani(
            color: textSecondary,
            fontSize: 14,
          ),
          labelSmall: GoogleFonts.rajdhani(
            color: textMuted,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.orbitron(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          iconTheme: const IconThemeData(color: neonCyan),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: neonCyan,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      );
}