import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../widgets/movie_card.dart';
import '../widgets/movielog_app_bar.dart';

/// 영화 탭 화면. 장르 Chip으로 Mock 영화 목록을 필터링해 2열 Grid로 보여준다.
///
/// 선택한 장르를 화면 안에서 기억해야 하므로 StatefulWidget으로 만든다.
/// (URL Query Parameter로 표현하는 방식은 Challenge 범위라 사용하지 않는다.)
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  String _selectedGenre = allGenre;

  // 선택한 장르에 맞는 영화만 걸러낸다. build마다 다시 계산되므로 항상 최신 선택을 반영한다.
  // 원본 movies는 바꾸지 않고, where로 조건에 맞는 항목만 모은 새 List를 만든다.
  List<Movie> get _filteredMovies {
    if (_selectedGenre == allGenre) return movies;
    return movies.where((movie) => movie.genre == _selectedGenre).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredMovies = _filteredMovies;

    return Scaffold(
      appBar: const MovieLogAppBar(title: '영화'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GenreChipBar(
            selectedGenre: _selectedGenre,
            // Chip 탭 → setState → build 재호출 → _filteredMovies 재계산 → Grid 갱신
            onSelected: (genre) => setState(() => _selectedGenre = genre),
          ),
          // Column 안에서 스크롤 위젯(GridView)은 높이가 정해져야 한다.
          // Expanded가 Chip 바를 뺀 남은 높이를 전부 GridView에 준다.
          Expanded(
            child: filteredMovies.isEmpty
                ? const Center(child: Text('해당 장르의 영화가 없어요.'))
                // GridView.builder: 화면에 보이는 칸만 만들어서 항목이 많아도 효율적이다.
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMovies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 한 줄에 2개
                          crossAxisSpacing: 12, // 좌우 간격
                          mainAxisSpacing: 16, // 위아래 간격
                          // 칸의 가로/세로 비율. 1보다 작을수록 세로로 길어진다.
                          // 카드 하단 텍스트가 잘리면 이 값을 낮춘다.
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      return MovieCard(movie: movie); // 칸 크기가 곧 카드 크기
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 가로로 스크롤되는 장르 Chip 바.
/// 선택 상태는 부모(_MovieListScreenState)가 가지고, 이 위젯은 표시와 선택 알림만 담당한다.
class _GenreChipBar extends StatelessWidget {
  const _GenreChipBar({required this.selectedGenre, required this.onSelected});

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
