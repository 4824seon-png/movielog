import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock_movies.dart';
import '../../models/movie.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/movielog_app_bar.dart';

/// 홈 탭 화면. MainScreen의 body(child)로 표시된다.
///
/// [결정] 검색 아이콘: 생략한다.
/// - 디자인에는 있지만 검색 기능은 과제 범위 밖이라, 동작하지 않는 버튼을 두지 않는다.
/// - 대안: 아이콘만 표시(탭해도 동작 없음).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 히어로 카드에 보여줄 영화.
  ///
  /// [결정] 추천 영화: 평점이 가장 높은 영화
  /// - Mock 데이터에서 계산하므로 데이터가 바뀌어도 자동으로 따라간다.
  /// - reduce: 리스트를 앞에서부터 두 개씩 비교해 하나만 남긴다 → 최고 평점 영화.
  /// - 대안: movies.first(디자인과 같은 '별빛 아래 우리').
  Movie get _featuredMovie =>
      movies.reduce((best, movie) => movie.rating > best.rating ? movie : best);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // 안쪽 Scaffold: AppBar 담당 (NavigationBar는 바깥 MainScreen이 담당).
    return Scaffold(
      appBar: const MovieLogAppBar(title: 'MovieLog'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('오늘은 어떤\n영화를 볼까요?', style: textTheme.headlineSmall),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _HomeHeroCard(movie: _featuredMovie),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionHeader(
                title: '인기 영화',
                // [결정] 전체보기: go('/movies')
                // - 영화 탭으로 "전환"하는 동작이다. NavigationBar의 탭 전환과 같은 방식이라
                //   탭 강조도 URL에서 계산되어 자동으로 '영화'로 바뀌고, 스택이 쌓이지 않는다.
                // - 대안: push('/movies') → 홈 위에 목록을 쌓아 뒤로가기로 돌아올 수 있지만,
                //   탭 구조와 섞여 NavigationBar 동작이 헷갈리기 쉬워 제외.
                onMorePressed: () => context.go('/movies'),
              ),
            ),
            const SizedBox(height: 12),
            const _PopularMovieList(),
          ],
        ),
      ),
    );
  }
}

/// 추천 영화 히어로 카드: 포스터 위에 그라데이션과 정보·버튼을 겹친다 (2주차 Stack/Positioned).
class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 스크롤 안에서는 높이가 무한하므로 AspectRatio로 카드 높이를 정한다.
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand, // Positioned가 아닌 자식(이미지, 그라데이션)은 카드 전체를 채운다
          children: [
            Image.asset(movie.posterAsset, fit: BoxFit.cover),
            // 아래쪽으로 갈수록 어두워지는 그라데이션 → 흰 글자가 포스터 색과 관계없이 잘 보인다.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            // left + right + bottom 지정 → 가로는 양쪽 끝까지 늘어나고 아래쪽에 고정된다.
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '평점 최고',
                      style: textTheme.labelSmall?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.title,
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${movie.genre} · ${movie.year} · ${movie.runningTime}분',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    // [결정] 히어로 카드 탭 영역: '상세보기' 버튼만
                    // - 디자인에 버튼이 명시되어 있어 역할이 분명하다.
                    // - 대안: 카드 전체를 GestureDetector로 감싸기 → 같은 동작이 두 군데 생긴다.
                    child: ElevatedButton.icon(
                      // push: 상세에서 뒤로 돌아와야 하므로 쌓는다. id만 Path Parameter로 전달.
                      onPressed: () => context.push('/movies/${movie.id}'),
                      icon: const Icon(Icons.info),
                      label: const Text('상세보기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 섹션 제목 + '전체보기 >' 버튼.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onMorePressed});

  final String title;
  final VoidCallback onMorePressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      // 제목은 왼쪽 끝, 버튼은 오른쪽 끝
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        TextButton(
          onPressed: onMorePressed,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('전체보기'), Icon(Icons.chevron_right, size: 20)],
          ),
        ),
      ],
    );
  }
}

/// '인기 영화' 가로 스크롤 목록.
///
/// [결정] 인기 영화 구성: Mock 영화 전체
/// - 대안: 히어로 영화 제외 / 평점순 정렬.
class _PopularMovieList extends StatelessWidget {
  const _PopularMovieList();

  @override
  Widget build(BuildContext context) {
    // 가로 ListView는 세로 크기를 스스로 정하지 못하므로 SizedBox로 높이를 지정한다.
    // (세로 스크롤 안에 넣었을 때 높이를 주지 않으면 무한 높이 오류가 난다)
    return SizedBox(
      height: 280,
      // 한 줄로 이어지는 UI → 가로 ListView, 항목 사이 간격 → separated (Notion 7번)
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // MovieCard는 부모가 크기를 정해야 한다 → 가로 목록에서는 너비를 지정한다.
          // (높이는 ListView의 280을 그대로 사용)
          return SizedBox(width: 150, child: MovieCard(movie: movies[index]));
        },
      ),
    );
  }
}
