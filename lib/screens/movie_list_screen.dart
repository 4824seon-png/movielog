import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/mock_movies.dart';
import '../models/movie.dart';
import '../services/fake_movie_service.dart';
import '../storage/genre_preference.dart';
import '../widgets/movie_grid.dart';
import '../widgets/movie_list_empty.dart';
import '../widgets/movie_list_error.dart';
import '../widgets/movie_list_loading.dart';
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

  // [4주차] 마지막 선택 장르를 기기에 저장·복원한다.
  final _genrePreference = GenrePreference();

  // [4주차] late: 선언 시점에는 값이 없지만 initState에서 반드시 채운다는 약속.
  late Future<List<Movie>> _moviesFuture;

  // 저장된 장르를 읽기 전까지는 '전체'로 시작한다.
  String _selectedGenre = allGenre;

  // [4주차] 복원이 끝나기 전에 사용자가 Chip을 눌렀는지.
  // true면 뒤늦게 끝난 복원값이 사용자의 선택을 덮어쓰지 않도록 버린다.
  bool _userPickedGenre = false;

  // [4주차] FakeMovieService에 넘길 로드 모드. 개발 모드의 AppBar 메뉴로만 바꿀 수 있다.
  MovieLoadMode _loadMode = MovieLoadMode.success;

  @override
  void initState() {
    super.initState();
    // [4주차] 화면이 처음 만들어질 때 딱 한 번 요청한다.
    // build에서 만들면 Chip 탭·테마 변경 등으로 다시 그릴 때마다 재요청되어 Loading이 반복된다.
    _moviesFuture = _loadMovies();
    // [4주차] 장르 복원은 영화 로드와 독립적이므로 기다리지 않고 동시에 시작한다.
    _restoreGenre();
  }

  // [4주차] 저장된 장르를 읽어 Chip 선택에 반영한다.
  // 직접 await한 뒤 setState를 부르므로 mounted 확인이 필요하다.
  Future<void> _restoreGenre() async {
    try {
      final genre = await _genrePreference.read();

      // 읽는 사이 다른 탭으로 이동해 화면이 dispose됐다면 setState를 부르지 않는다.
      if (!mounted) return;
      // 복원 전에 사용자가 이미 Chip을 눌렀다면 사용자의 선택을 우선한다.
      if (_userPickedGenre) return;
      // 저장된 값이 현재 장르 목록에 없으면(장르 이름 변경 등) '전체'를 유지한다.
      if (!genres.contains(genre)) return;

      setState(() => _selectedGenre = genre);
    } catch (error) {
      // 복원 실패는 치명적이지 않다. '전체'로 보여주고 로그만 남긴다.
      debugPrint('장르 복원 실패: $error');
    }
  }

  // [4주차] Chip 선택: 화면을 먼저 갱신하고, 저장은 그 뒤에 기다린다.
  // await 뒤에 State·context를 쓰지 않으므로 mounted 확인이 필요 없다.
  Future<void> _selectGenre(String genre) async {
    setState(() {
      _selectedGenre = genre;
      _userPickedGenre = true;
    });

    try {
      await _genrePreference.save(genre);
    } catch (error) {
      // 저장 실패 시 다음 실행 때 '전체'로 보일 뿐이므로 화면은 그대로 둔다.
      debugPrint('장르 저장 실패: $error');
    }
  }

  // [4주차] Service 호출을 감싸 실패 원인을 로그로 남긴다.
  // 화면에는 고정 문구만 보여주고, 개발자는 콘솔에서 원인을 확인한다.
  Future<List<Movie>> _loadMovies() async {
    try {
      // await가 있어야 Service의 오류가 이 try 안에서 발생해 catch로 잡힌다.
      return await _movieService.fetchMovies(mode: _loadMode);
    } on MovieLoadException catch (error, stackTrace) {
      debugPrint('영화 로드 실패: $error');
      debugPrintStack(stackTrace: stackTrace);
      // 다시 던져야 Future가 "오류로 완료"되어 FutureBuilder가 hasError를 받는다.
      rethrow;
    } finally {
      debugPrint('영화 로드 시도 종료'); // 성공·실패와 관계없이 실행
    }
  }

  // [4주차] 다시 시도: 이미 오류로 완료된 Future 대신 새 Future를 할당한다.
  // setState 안에서 바꿔야 FutureBuilder가 새 Future를 받아 Loading부터 다시 시작한다.
  void _retry() {
    setState(() {
      _moviesFuture = _loadMovies(); // 현재 _loadMode 그대로 다시 요청
    });
  }

  // [4주차] 개발용: 로드 모드를 바꾸고 그 모드로 바로 다시 요청한다.
  void _changeLoadMode(MovieLoadMode mode) {
    setState(() {
      _loadMode = mode;
      _moviesFuture = _loadMovies();
    });
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
      appBar: MovieLogAppBar(
        title: '영화',
        // kDebugMode: 개발 중(debug 빌드)에만 true. release 빌드에서는 메뉴가 사라진다.
        actions: [
          if (kDebugMode)
            _LoadModeMenu(selected: _loadMode, onSelected: _changeLoadMode),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GenreChipBar(
            selectedGenre: _selectedGenre,
            // Chip 탭 → setState → build 재호출 → FutureBuilder는 같은 _moviesFuture(이미 done)를 받음
            // → 새 요청·Loading 없이 _filterByGenre만 다시 계산되어 Grid 갱신 → 이후 장르 저장
            onSelected: _selectGenre,
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
                  return const MovieListLoading();
                }

                // 2) 오류로 완료 → Error. 반드시 Empty 확인보다 먼저 검사한다.
                // (오류 시 data는 null이라, 아래 ?? 처리 후엔 빈 목록 = Empty로 잘못 보인다)
                if (snapshot.hasError) {
                  return MovieListError(onRetry: _retry);
                }

                // 3) 값으로 완료 → 장르 필터 적용
                final filteredMovies = _filterByGenre(
                  snapshot.data ?? const <Movie>[],
                );

                // 서버가 빈 목록을 줬거나, 장르 필터 결과가 비었을 때 → Empty
                if (filteredMovies.isEmpty) {
                  return const MovieListEmpty();
                }

                // 4) Success → 3주차 Grid를 분리한 MovieGrid 재사용
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

/// 개발용 로드 모드 선택 메뉴 (kDebugMode에서만 표시).
/// Empty·Error 화면과 재시도 흐름을 앱 실행 중에 재현하기 위해 사용한다.
class _LoadModeMenu extends StatelessWidget {
  const _LoadModeMenu({required this.selected, required this.onSelected});

  final MovieLoadMode selected;
  final ValueChanged<MovieLoadMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MovieLoadMode>(
      icon: const Icon(Icons.bug_report_outlined),
      tooltip: '로드 모드 (개발용)',
      onSelected: onSelected,
      itemBuilder: (context) => [
        // MovieLoadMode.values: enum의 모든 값(success, empty, failure)을 순서대로 담은 List
        for (final mode in MovieLoadMode.values)
          CheckedPopupMenuItem(
            value: mode,
            checked: mode == selected, // 현재 모드에 체크 표시
            child: Text(mode.name), // enum 값의 이름 문자열 ('success' 등)
          ),
      ],
    );
  }
}
