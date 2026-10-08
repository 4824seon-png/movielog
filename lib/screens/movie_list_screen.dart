import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movielog_app_bar.dart';

/// 영화 탭 화면. FakeMovieService로 영화 목록을 비동기로 불러오고,
/// 장르 Chip으로 필터링해 2열 Grid로 보여준다.
///
/// 선택한 장르와 요청 중인 Future를 화면 안에서 기억해야 하므로 StatefulWidget으로 만든다.
/// (URL Query Parameter로 표현하는 방식은 Challenge 범위라 사용하지 않는다.)
class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  // [4주차] 화면은 "Future<List<Movie>>를 주는 곳"만 안다.
  // 5주차에는 이 필드만 실제 API Service로 교체한다.
  final _movieService = const FakeMovieService();

  // [4주차] late: 선언 시점에는 값이 없지만 initState에서 반드시 채운다는 약속.
  late Future<List<Movie>> _moviesFuture;

  String _selectedGenre = allGenre;

  @override
  void initState() {
    super.initState();
    // [4주차] 화면이 처음 만들어질 때 딱 한 번 요청한다.
    // build에서 만들면 Chip 탭·테마 변경 등으로 다시 그릴 때마다 재요청되어 Loading이 반복된다.
    _moviesFuture = _movieService.fetchMovies();
  }

  // [4주차] getter(_filteredMovies) → 받은 목록을 걸러내는 함수로 변경.
  // 목록은 Future가 완료돼야 생기므로, 완료된 목록(source)을 받아 선택한 장르만 남긴다.
  // 원본은 바꾸지 않고, where로 조건에 맞는 항목만 모은 새 List를 만든다.
  List<Movie> _filterByGenre(List<Movie> source) {
    if (_selectedGenre == allGenre) return source;
    return source.where((movie) => movie.genre == _selectedGenre).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MovieLogAppBar(title: '영화'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GenreChipBar(
            selectedGenre: _selectedGenre,
            // Chip 탭 → setState → build 재호출 → FutureBuilder는 같은 _moviesFuture(이미 done)를 받음
            // → 새 요청·Loading 없이 _filterByGenre만 다시 계산되어 Grid 갱신
            onSelected: (genre) => setState(() => _selectedGenre = genre),
          ),
          // Column 안에서 스크롤 위젯(GridView)은 높이가 정해져야 한다.
          // Expanded가 Chip 바를 뺀 남은 높이를 전부 FutureBuilder(→ GridView)에 준다.
          Expanded(
            // [4주차] FutureBuilder는 Future를 실행하지 않고, 전달받은 Future의 상태만 관찰한다.
            child: FutureBuilder<List<Movie>>(
              future: _moviesFuture, // 여기서 fetchMovies()를 직접 호출하지 않는다
              builder: (context, snapshot) {
                // 1) 완료 전 → Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 2) 완료 → data가 null일 수 있으므로 빈 목록으로 대체한 뒤 장르 필터 적용
                final filteredMovies = _filterByGenre(
                  snapshot.data ?? const <Movie>[],
                );

                // (임시) 필터 결과가 비었을 때. 미션에서 MovieListEmpty 위젯으로 교체한다.
                if (filteredMovies.isEmpty) {
                  return const Center(child: Text('해당 장르의 영화가 없어요.'));
                }

                // 3) Success → 3주차 Grid를 분리한 MovieGrid 재사용
                return MovieGrid(movies: filteredMovies);
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
