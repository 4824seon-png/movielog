import 'package:flutter/material.dart';

import '../../../data/mock_movies.dart';

/// 가로로 스크롤되는 장르 Chip 바.
/// 선택 상태는 부모(MovieListScreen)가 가지고, 이 위젯은 표시와 선택 알림만 담당한다.
///
/// 크기·색은 Figma W3-02 "Section - Genre Filter Chips" 값을 따른다.
class GenreChipBar extends StatelessWidget {
  const GenreChipBar({
    super.key,
    required this.selectedGenre,
    required this.onSelected,
  });

  final String selectedGenre;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // 가로 ListView는 세로 크기를 스스로 정하지 못하므로 SizedBox로 높이를 지정한다.
    return SizedBox(
      height: 40, // Figma 섹션 높이 (Chip 32px이 세로 가운데)
      // [결정] Chip 바 레이아웃: 가로 ListView.separated
      // - Notion 7번: 한 줄로 이어지는 UI → 가로 ListView, 항목 사이 간격 → separated.
      // - 디자인처럼 Chip이 화면 밖으로 이어지며 가로 스크롤된다.
      // - 대안: Wrap → 넘치면 다음 줄로 내려가 디자인(한 줄 스크롤)과 달라 제외.
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16), // Figma 좌우 16
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          // [결정] Chip 종류: ChoiceChip
          // - 여러 개 중 하나만 선택하는 용도의 Chip (selected / onSelected 제공).
          // - 대안: FilterChip → 여러 개를 동시에 켜고 끄는 용도라 단일 선택에는 의미가 맞지 않아 제외.
          return Center(
            child: ChoiceChip(
              label: Text(genre),
              selected: isSelected,
              // 이미 선택된 Chip을 다시 눌러도 선택이 풀리지 않도록 항상 해당 장르를 전달한다.
              onSelected: (_) => onSelected(genre),
              showCheckmark: false, // 디자인: 체크 표시 없이 색으로만 구분
              // Figma: 좌우 16 · 상하 8 패딩 → 높이 32
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelPadding: EdgeInsets.zero,
              // 기본값은 터치 영역을 48px로 키워 Chip 바깥에 여백이 생긴다 → Figma 크기 그대로
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.standard,
              shape: const StadiumBorder(), // Figma 반경 9999 (알약 모양)
              side: BorderSide.none,
              selectedColor: colors.primary, // #6750A4
              backgroundColor: colors.surfaceContainerHighest, // #E6E0E9
              // Figma: 선택된 Chip에만 그림자 (Y 1, 흐림 2, 검정 5%)
              // elevation 1 ≈ Y 1·흐림 2. 미선택은 그림자 색을 투명으로 두어 선택 Chip만 그림자가 보인다.
              elevation: 1,
              pressElevation: 1,
              shadowColor: Colors.transparent,
              selectedShadowColor: Colors.black.withValues(alpha: 0.05),
              surfaceTintColor: Colors.transparent, // M3 elevation 색조 변화 방지
              labelStyle: TextStyle(
                // Figma: Manrope Medium 12 / 행간 16
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 16 / 12,
                // 선택 #FFFFFF / 미선택 #494551
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}
