import 'package:flutter/material.dart';

import '../models/movie.dart';
import 'movie_card.dart';

/// 영화 목록을 2열 Grid로 보여준다.
/// 어떤 목록을 보여줄지는 부모가 정하고, 이 위젯은 그리기만 담당한다(Success 상태 화면).
class MovieGrid extends StatelessWidget {
  const MovieGrid({super.key, required this.movies});

  final List<Movie> movies;

  @override
  Widget build(BuildContext context) {
    // GridView.builder: 화면에 보이는 칸만 만들어서 항목이 많아도 효율적이다.
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 한 줄에 2개
        crossAxisSpacing: 12, // 좌우 간격
        mainAxisSpacing: 16, // 위아래 간격
        // 칸의 가로/세로 비율. 1보다 작을수록 세로로 길어진다.
        // 카드 하단 텍스트가 잘리면 이 값을 낮춘다.
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) =>
          MovieCard(movie: movies[index]), // 칸 크기가 곧 카드 크기
    );
  }
}
