import 'package:flutter/material.dart';

import '../../../data/mock_movies.dart';

/// 가로로 스크롤되는 장르 Chip 바.
/// 선택 상태는 부모(MovieListScreen)가 가지고, 이 위젯은 표시와 선택 알림만 담당한다.
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
      height: 56,
      // [결정] Chip 바 레이아웃: 가로 ListView.separated
      // - Notion 7번: 한 줄로 이어지는 UI → 가로 ListView, 항목 사이 간격 → separated.
      // - 디자인처럼 Chip이 화면 밖으로 이어지며 가로 스크롤된다.
      // - 대안: Wrap → 넘치면 다음 줄로 내려가 디자인(한 줄 스크롤)과 달라 제외.
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: genres.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre == selectedGenre;

          // [결정] Chip 종류: ChoiceChip
          // - 여러 개 중 하나만 선택하는 용도의 Chip (selected / onSelected 제공).
          // - 대안: FilterChip → 여러 개를 동시에 켜고 끄는 용도라 단일 선택에는 의미가 맞지 않아 제외.
          return ChoiceChip(
            label: Text(genre),
            selected: isSelected,
            // 이미 선택된 Chip을 다시 눌러도 선택이 풀리지 않도록 항상 해당 장르를 전달한다.
            onSelected: (_) => onSelected(genre),
            showCheckmark: false, // 디자인: 체크 표시 없이 색으로만 구분
            selectedColor: colors.primary,
            backgroundColor: colors.surfaceContainerHighest,
            labelStyle: TextStyle(
              color: isSelected ? colors.onPrimary : colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          );
        },
      ),
    );
  }
}
