import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/movie.dart';

/// 포스터·평점·제목·연도/장르를 보여주는 공통 영화 카드.
/// 탭하면 해당 영화의 상세 화면으로 이동한다.
///
/// 카드 크기는 부모가 정한다(홈: SizedBox, 목록: Grid 칸).
/// 내부의 Expanded가 "남은 높이"를 포스터에 주므로, 높이가 정해지지 않은 곳에 두면 오류가 난다.
///
/// 크기·색은 Figma W3-02 "Article - Movie Item" 값을 따른다.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie});

  /// 포스터 아래 텍스트 영역의 고정 높이.
  /// 간격 4 + 위 여백 8 + 제목 24 + 부제 24 = 60 (Figma).
  /// Grid가 칸 높이를 계산할 때 사용한다.
  static const double infoHeight = 60;

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

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
            // Figma "Background+Shadow": 반경 12, 배경 #E6E0E9, 그림자 Y 1·흐림 2·검정 5%
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest, // 이미지가 뜨기 전 자리 색
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
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
          ),
          // Figma: 포스터와 텍스트 사이 간격 4 + 텍스트 영역 위 여백 8
          const SizedBox(height: 12),
          Text(
            movie.title,
            // 긴 제목이 카드 폭을 넘으면 '…'으로 줄인다 (overflow 방지).
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            // Figma: Manrope Medium 16 / 행간 24, #1D1B20
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 24 / 16,
              color: colors.onSurface,
            ),
          ),
          // Figma: 부제 영역 불투명도 80%
          Opacity(
            opacity: 0.8,
            child: Text(
              '${movie.year} · ${movie.genre}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Figma: Manrope Regular 16 / 행간 24, #494551
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 포스터 오른쪽 위의 ★ 평점 뱃지.
/// 이 파일 안에서만 쓰므로 _(private)로 선언한다.
///
/// Figma "Overlay+OverlayBlur": 배경 #322F35 80% + 배경 흐림 4, 반경 6, 패딩 상하 4·좌우 8.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // BackdropFilter는 뒤쪽(포스터)을 흐리게 한다. ClipRRect로 흐림 범위를 뱃지 모양으로 제한한다.
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          color: colors.inverseSurface.withValues(alpha: 0.8),
          child: Text(
            '★ ${rating.toStringAsFixed(1)}', // 4 → '4.0'처럼 항상 소수 한 자리
            // Figma: Manrope Bold 12 / 행간 16, #F5EFF7
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 16 / 12,
              color: colors.onInverseSurface,
            ),
          ),
        ),
      ),
    );
  }
}
