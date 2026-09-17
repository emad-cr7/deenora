import 'package:flutter/material.dart';

import 'app_colors.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Colors.white,
    secondary: AppColors.textDark,
    surface: Colors.white,
    onSurface: AppColors.textDark,
  ),
  scaffoldBackgroundColor: const Color(0xFFF6F7F9),
  cardTheme: const CardThemeData(color: Colors.white, elevation: 0),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    centerTitle: true,
    elevation: 0,
    foregroundColor: Colors.white,
    titleTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: AppColors.primary),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
    filled: true,
    fillColor: Colors.white,
    focusColor: AppColors.borderSubtle,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 1),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.borderSubtle, width: 1),
    ),
  ),
  iconTheme: const IconThemeData(color: AppColors.textDark),
  dividerTheme: const DividerThemeData(color: AppColors.borderSubtle),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: AppColors.primary,
    selectionColor: Color(0x331B5E4F),
    selectionHandleColor: AppColors.primary,
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFFF6F8F7),
    indicatorColor: AppColors.deepForest,
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: Colors.white, size: 26);
      }
      return const IconThemeData(color: AppColors.textMuted, size: 24);
    }),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      if (states.contains(WidgetState.selected)) {
        return const TextStyle(
          color: AppColors.deepForest,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );
      }
      return const TextStyle(
        color: AppColors.textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );
    }),
  ),
  splashFactory: NoSplash.splashFactory,
);
