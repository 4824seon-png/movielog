import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';

/// 포스터·평점·제목·연도/장르를 보여주는 공통 영화 카드.
/// 탭하면 해당 영화의 상세 화면으로 이동한다.
///
/// 카드 크기는 부모가 정한다(홈: SizedBox, 목록: Grid 칸).
/// 내부의 Expanded가 "남은 높이"를 포스터에 주므로, 높이가 정해지지 않은 곳에 두면 오류가 난다.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      // opaque: 카드 안의 빈 여백(텍스트 옆 등)을 눌러도 탭으로 인식한다.
      behavior: HitTestBehavior.opaque,
      // push: 상세에서 뒤로 돌아와야 하므로 현재 화면 위에 쌓는다.
      // 객체 대신 id만 URL(Path Parameter)에 넣는다 → 상세에서 id로 Mock을 다시 조회.
      onTap: () => context.push('/movies/${movie.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 텍스트 두 줄을 제외한 나머지 높이를 포스터가 모두 사용한다.
          Expanded(
            // Stack: 포스터 위에 평점 뱃지를 겹친다.
            child: Stack(
              children: [
                // Positioned.fill: Stack 전체를 채움 (top/bottom/left/right = 0)
                Positioned.fill(
                  // ClipRRect: 이미지 모서리를 둥글게 자른다.
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    // cover: 비율을 유지하며 영역을 꽉 채우고 넘치는 부분은 잘라낸다.
                    child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
                  ),
                ),
                // top + right만 지정 → 오른쪽 위에 고정, 크기는 뱃지 내용만큼.
                Positioned(
                  top: 8,
                  right: 8,
                  child: _RatingBadge(rating: movie.rating),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            // 긴 제목이 카드 폭을 넘으면 '…'으로 줄인다 (overflow 방지).
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium,
          ),
          Text(
            '${movie.year} · ${movie.genre}',
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant, // 보조 텍스트 색
            ),
          ),
        ],
      ),
    );
  }
}

/// 포스터 오른쪽 위의 ★ 평점 뱃지.
/// 이 파일 안에서만 쓰므로 _(private)로 선언한다.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // 포스터 색과 관계없이 글자가 보이도록 반투명 검정 배경.
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Row가 가로 전체를 차지하지 않고 내용만큼만
        children: [
          const Icon(Icons.star, size: 14, color: Colors.white),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1), // 4 → '4.0'처럼 항상 소수 한 자리
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
