import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

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
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: AppSizes.sp22,
    ),
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: AppSizes.sp58,
      fontWeight: FontWeight.w800,
      color: AppColors.primary,
      letterSpacing: -1.0,
    ),
    displayMedium: TextStyle(
      fontSize: AppSizes.sp32,
      fontWeight: FontWeight.w700,
      color: AppColors.deepForest,
      letterSpacing: 1.0,
    ),
    displaySmall: TextStyle(
      fontSize: AppSizes.sp24,
      fontWeight: FontWeight.w700,
      color: AppColors.deepForest,
      height: 1.4,
    ),
    headlineLarge: TextStyle(
      fontSize: AppSizes.sp24,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
      height: 1.8,
    ),
    headlineMedium: TextStyle(
      fontSize: AppSizes.sp20,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
      height: 1.7,
    ),
    headlineSmall: TextStyle(
      fontSize: AppSizes.sp20,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    ),
    titleLarge: TextStyle(
      fontSize: AppSizes.sp18,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    ),
    titleMedium: TextStyle(
      fontSize: AppSizes.sp16,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    titleSmall: TextStyle(
      fontSize: AppSizes.sp14,
      fontWeight: FontWeight.w600,
      color: AppColors.textDark,
    ),
    bodyLarge: TextStyle(
      fontSize: AppSizes.sp16,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
    ),
    bodyMedium: TextStyle(
      fontSize: AppSizes.sp14,
      fontWeight: FontWeight.w400,
      color: AppColors.textDark,
    ),
    bodySmall: TextStyle(
      fontSize: AppSizes.sp13,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      height: 1.3,
    ),
    labelLarge: TextStyle(
      fontSize: AppSizes.sp14,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    labelMedium: TextStyle(
      fontSize: AppSizes.sp12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
    ),
    labelSmall: TextStyle(
      fontSize: AppSizes.sp11,
      fontWeight: FontWeight.w600,
      color: AppColors.textMuted,
    ),
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
    hintStyle: const TextStyle(
      color: AppColors.textMuted,
      fontSize: AppSizes.sp15,
    ),
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

    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>(
          (states) => IconThemeData(
        color: states.contains(WidgetState.selected)
            ? Colors.white
            : AppColors.textMuted,
        size: states.contains(WidgetState.selected) ? 26 : 24,
      ),
    ),

    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
        final isSelected = states.contains(WidgetState.selected);

        return TextStyle(
          color: isSelected
              ? AppColors.deepForest
              : AppColors.textMuted,
          fontSize: isSelected ? AppSizes.sp14 : AppSizes.sp12,
          fontWeight: isSelected
              ? FontWeight.w600
              : FontWeight.w500,
        );
      },
    ),
  ),  splashFactory: NoSplash.splashFactory,
);


