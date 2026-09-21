import 'package:flutter/material.dart';

/// Figma 디자인 시스템의 원본 색상값 모음.
/// 화면에서는 이 값을 직접 쓰지 않고 Theme의 ColorScheme을 통해 사용한다.
class AppColors {
  AppColors._(); // 인스턴스를 만들 필요가 없으므로 생성자를 막는다.

  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAF9F5);
  static const Color onSurface = Color(0xFF1C1B1F);
  static const Color surfaceContainer = Color(0xFFF3F1EC); // 통계 카드 배경
  static const Color outlineVariant = Color(0xFFE3E0D8); // 통계 카드 테두리
  static const Color secondaryContainer = Color(0xFFE9DDFF); // 장르 Chip 배경
}
