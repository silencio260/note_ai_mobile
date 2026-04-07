import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Brand ────────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A1A1A); // Deep black/grey
  static const Color primaryLight = Color(0xFF424242);
  static const Color primaryDark = Color(0xFF000000);
  static const Color accent = Color(0xFF1A1A1A);

  // ─── Status ───────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ─── Background ───────────────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFFBFBFB);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);

  // ─── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFFBDBDBD);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textHintDark = Color(0xFF808080);

  // ─── Recording states ─────────────────────────────────────────────────────
  static const Color recordingActive = Color(0xFFEF5350);
  static const Color recordingPaused = Color(0xFFFFB74D);
  static const Color transcribing = Color(0xFF42A5F5);
  static const Color transcribed = Color(0xFF66BB6A);
}
