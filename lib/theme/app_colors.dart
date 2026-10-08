import 'package:flutter/material.dart';

/// Figma 디자인 시스템의 원본 색상값 모음.
/// 화면에서는 이 값을 직접 쓰지 않고 Theme의 ColorScheme을 통해 사용한다.
class AppColors {
  AppColors._(); // 인스턴스를 만들 필요가 없으므로 생성자를 막는다.

  static const Color primary = Color(0xFF6750A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFAF9F5);
  // 기본 텍스트 (W3-02 카드 제목)
  static const Color onSurface = Color(0xFF1D1B20);
  // 보조 텍스트·아이콘 (W3-02 부제·검색 아이콘·미선택 Chip 글자)
  static const Color onSurfaceVariant = Color(0xFF494551);
  static const Color surfaceContainer = Color(0xFFF3F1EC); // 통계 카드 배경
  // 미선택 Chip·포스터 자리 배경 (W3-02)
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);
  // 평점 뱃지 배경 (W3-02, 80% 불투명으로 사용) / 뱃지 글자
  static const Color inverseSurface = Color(0xFF322F35);
  static const Color onInverseSurface = Color(0xFFF5EFF7);
  static const Color outlineVariant = Color(0xFFE3E0D8); // 통계 카드 테두리
  static const Color secondaryContainer = Color(0xFFE9DDFF); // 장르 Chip 배경
  static const Color inputBorder = Color(0xFFCAC4D0); // 입력창 기본 테두리
}
