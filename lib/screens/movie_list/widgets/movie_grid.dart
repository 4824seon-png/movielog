import 'package:flutter/material.dart';

import '../../../models/movie.dart';
import '../../../widgets/movie_card.dart';

/// 영화 목록을 2열 Grid로 보여준다.
/// 어떤 목록을 보여줄지는 부모가 정하고, 이 위젯은 그리기만 담당한다(Success 상태 화면).
///
/// 간격은 Figma W3-02 "Section - Movie Grid (Two Column)" 값을 따른다.
class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  final List<Movie> movies;

  static const double _horizontalPadding = 16; // Figma 좌우 여백
  static const double _columnGap = 16; // Figma 열 간격
  static const double _rowGap = 24; // Figma 행 간격

  @override
  Widget build(BuildContext context) {
    // [결정] 칸 높이: childAspectRatio 대신 mainAxisExtent(고정 높이)
    // - Figma 포스터는 2:3 비율(171 × 256.5)이고 텍스트 영역은 60px로 고정이다.
    // - 비율만 주면 화면 폭에 따라 텍스트 영역이 늘거나 줄어 Figma와 달라진다.
    // → LayoutBuilder로 실제 칸 너비를 구해 "포스터 높이(너비 × 1.5) + 60"을 칸 높이로 쓴다.
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth =
            (constraints.maxWidth - _horizontalPadding * 2 - _columnGap) / 2;

        // GridView.builder: 화면에 보이는 칸만 만들어서 항목이 많아도 효율적이다.
        return GridView.builder(
          // 위 16: Figma에서 Chip 섹션과 Grid 사이 간격
          padding: const EdgeInsets.all(_horizontalPadding),
          itemCount: movies.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 한 줄에 2개
            crossAxisSpacing: _columnGap, // 좌우 간격
            mainAxisSpacing: _rowGap, // 위아래 간격
            mainAxisExtent: itemWidth * 1.5 + MovieCard.infoHeight,
          ),
          itemBuilder: (context, index) =>
              MovieCard(movie: movies[index]), // 칸 크기가 곧 카드 크기
        );
      },
    );
  }
}
