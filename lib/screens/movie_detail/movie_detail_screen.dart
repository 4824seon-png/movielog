import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../data/mock_movies.dart';
import '../../models/movie.dart';
import 'widgets/rating_dialog.dart';

/// 영화 상세 화면. 경로 /movies/:movieId
/// ShellRoute 밖에 있어서 NavigationBar가 표시되지 않는다.
///
/// 즐겨찾기 여부와 내가 남긴 평점을 화면 안에서 기억해야 하므로 StatefulWidget으로 만든다.
/// (Required 조건: 평점·즐겨찾기는 화면 내부 상태로만 처리 → 상세를 나갔다 오면 초기화되는 것이 정상)
class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.movieId});

  /// Path Parameter에서 읽은 영화 ID. 숫자가 아니면 null.
  /// 객체(Extra)가 아니라 id를 받는 이유: 딥링크·앱 재시작처럼 객체가 없는 상황에서도
  /// URL만으로 같은 화면을 복원할 수 있다.
  final int? movieId;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;
  double? _myRating; // 아직 평점을 남기지 않았으면 null

  // ── Snackbar ──
  void _showSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    // Snackbar는 대기열에 쌓인다. 즐겨찾기를 빠르게 여러 번 누르면 메시지가 차례로 몇 초씩 이어지므로
    // 현재 Snackbar를 먼저 닫고 최신 결과만 보여준다.
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        // [결정] Snackbar 형태: floating
        // - 여백을 두고 떠 있는 카드 형태(Notion 13번 예시). 하단 버튼 영역 위에 표시된다.
        // - 대안: fixed → 화면 하단에 붙는 기본 형태.
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── 즐겨찾기 ──
  // 하나의 bool(_isFavorite)이 아이콘과 Snackbar 문구를 함께 결정한다.
  void _toggleFavorite() {
    setState(() => _isFavorite = !_isFavorite);
    _showSnackBar(_isFavorite ? '즐겨찾기에 추가했어요.' : '즐겨찾기에서 삭제했어요.');
  }

  // ── 평점 남기기 (Dialog) ──
  // showDialog는 Dialog가 닫힐 때까지 기다리는 Future를 반환하므로 async/await를 사용한다.
  Future<void> _openRatingDialog() async {
    // <double>: Dialog가 Navigator.pop(context, rating)으로 돌려줄 값의 타입.
    // 바깥 영역 탭·뒤로가기로 닫으면 값 없이 닫혀 null이 온다 → 반환 타입은 double?.
    final rating = await showDialog<double>(
      context: context,
      builder: (dialogContext) => const RatingDialog(),
    );

    // 취소했거나, 기다리는 동안 화면이 사라졌으면(mounted == false) 이후 context를 쓰지 않는다.
    if (rating == null || !mounted) return;

    // [결정] Dialog 결과 반영: 상세 State에 저장 + 버튼 문구 변경 + Snackbar
    // - 반환값이 화면(내 평점 별, 버튼 문구)에 반영되는 것을 확인할 수 있다.
    // - 대안: Snackbar로 안내만 하고 값은 저장하지 않음.
    setState(() => _myRating = rating);
    _showSnackBar('$rating점을 남겼어요.');
  }

  // ── 공유 (BottomSheet) ──
  Future<void> _openShareSheet() async {
    // [결정] BottomSheet 사용처: AppBar 공유 아이콘 → 공유 옵션 시트
    // - 스터디 인증·최종 체크리스트의 "Dialog, BottomSheet, Snackbar 모두 사용"을 충족한다.
    // - BottomSheet도 Dialog처럼 Navigator에 쌓이는 route라서 pop(context, 값)으로 결과를 돌려받는다.
    // - 대안: 사용하지 않음(인증 항목 누락) / Challenge의 장르 필터 시트(이번 범위 제외).
    final option = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true, // 위·좌·우 시스템 영역(상태바 등)을 피한다
      showDragHandle: true, // 상단 손잡이 표시
      builder: (sheetContext) => const _ShareSheet(),
    );

    if (option == null || !mounted) return;

    // 시트가 이미 닫힌 뒤, 시트의 context가 아닌 화면의 context로 Snackbar를 띄운다.
    // (시트가 열린 상태로 띄우면 시트에 가려 보이지 않는다 — Notion '자주 발생하는 오류')
    _showSnackBar('$option 완료 (Mock)');
  }

  @override
  Widget build(BuildContext context) {
    // 라우터는 URL 해석만, 화면은 id로 데이터를 조회해 표시한다.
    // State 안에서는 생성자 값을 widget.으로 읽는다.
    final movie = findMovieById(widget.movieId);

    // 잘못된 id(/movies/abc, /movies/999)에 대한 방어.
    // 이 분기 이후로는 Dart가 movie를 non-null(Movie)로 취급한다(타입 승격).
    if (movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('영화를 찾을 수 없어요.')),
      );
    }

    final myRating = _myRating;

    return Scaffold(
      // push로 들어왔으므로 이전 화면이 있다 → AppBar가 ← 뒤로 버튼을 자동으로 만든다.
      // (go로 들어와 돌아갈 곳이 없으면 버튼이 자동으로 사라진다)
      appBar: AppBar(
        title: const Text('영화 상세'),
        actions: [
          IconButton(
            onPressed: _openShareSheet,
            icon: const Icon(Icons.share_outlined),
            tooltip: '공유',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 스크롤 안에서는 높이가 무한하므로 AspectRatio로 이미지 높이를 정한다.
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.asset(movie.posterAsset, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _MovieInfo(movie: movie, myRating: myRating),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: _Synopsis(text: movie.synopsis),
            ),
          ],
        ),
      ),
      // bottomNavigationBar는 NavigationBar 전용 자리가 아니라 "하단 고정 영역"이다.
      // 여기에 두면 본문 스크롤과 관계없이 버튼이 항상 하단에 보인다.
      bottomNavigationBar: _DetailActions(
        isFavorite: _isFavorite,
        myRating: myRating,
        onFavoritePressed: _toggleFavorite,
        onRatingPressed: _openRatingDialog,
      ),
    );
  }
}

/// 제목·연도/장르/러닝타임·평균 평점·(있으면) 내 평점.
class _MovieInfo extends StatelessWidget {
  const _MovieInfo({required this.movie, required this.myRating});

  final Movie movie;
  final double? myRating;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final myRating = this.myRating; // 로컬 변수로 옮겨야 null 체크 후 타입 승격이 된다.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(
          '${movie.year} • ${movie.genre} • ${movie.runningTime}분',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        // 영화의 평균 평점: 사용자가 수정할 필요가 없는 값 → 읽기 전용 RatingBarIndicator.
        _ReadOnlyRating(label: '평균', rating: movie.rating),
        // 사용자가 이미 등록한 평점도 읽기 전용이므로 같은 방식으로 표시한다.
        if (myRating != null) ...[
          const SizedBox(height: 8),
          _ReadOnlyRating(label: '내 평점', rating: myRating),
        ],
      ],
    );
  }
}

/// 읽기 전용 별점 한 줄: 라벨 + RatingBarIndicator + 숫자.
///
/// RatingBarIndicator vs RatingBar.builder (Notion 10번)
/// - RatingBarIndicator: 전달받은 값을 표시만 한다. 4.3처럼 0.5 단위가 아닌 값도 표시 가능.
/// - RatingBar.builder: 사용자가 입력한다(MovieRatingInput에서 사용).
class _ReadOnlyRating extends StatelessWidget {
  const _ReadOnlyRating({required this.label, required this.rating});

  final String label;
  final double rating;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(
          width: 48,
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        RatingBarIndicator(
          rating: rating,
          itemCount: 5,
          itemSize: 20,
          // 별 색은 MovieRatingInput과 같이 테마의 primary(디자인의 보라색)를 사용한다.
          itemBuilder: (context, index) =>
              Icon(Icons.star, color: colors.primary),
        ),
        const SizedBox(width: 8),
        Text(rating.toStringAsFixed(1), style: textTheme.titleMedium),
      ],
    );
  }
}

/// 시놉시스 제목 + 본문.
class _Synopsis extends StatelessWidget {
  const _Synopsis({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('시놉시스', style: textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(text, style: textTheme.bodyLarge?.copyWith(height: 1.6)),
      ],
    );
  }
}

/// 하단 고정 버튼: 즐겨찾기 / 평점 남기기.
/// 상태(isFavorite, myRating)는 부모가 가지고, 이 위젯은 표시와 탭 알림만 담당한다.
class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.isFavorite,
    required this.myRating,
    required this.onFavoritePressed,
    required this.onRatingPressed,
  });

  final bool isFavorite;
  final double? myRating;
  final VoidCallback onFavoritePressed;
  final VoidCallback onRatingPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final myRating = this.myRating;

    // SafeArea: 하단 제스처 바(홈 인디케이터)에 버튼이 겹치지 않게 한다.
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            // Expanded 두 개 → 남은 가로 공간을 1:1로 나눈다.
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onFavoritePressed,
                // 즐겨찾기 상태에 따라 아이콘이 바뀐다 (채움 / 테두리).
                icon: Icon(isFavorite ? Icons.bookmark : Icons.bookmark_border),
                label: const Text('즐겨찾기'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: colors.primary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onRatingPressed,
                icon: const Icon(Icons.rate_review_outlined),
                // 평점을 남긴 뒤에는 Dialog 반환값이 버튼 문구에 반영된다.
                label: Text(myRating == null ? '평점 남기기' : '내 평점 $myRating'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 공유 옵션 BottomSheet 내용 (Mock).
/// 항목을 누르면 선택한 옵션 이름을 돌려주며 시트를 닫는다.
class _ShareSheet extends StatelessWidget {
  const _ShareSheet();

  static const _options = [
    (icon: Icons.link, label: '링크 복사'),
    (icon: Icons.chat_bubble_outline, label: '카카오톡으로 공유'),
    (icon: Icons.sms_outlined, label: '메시지로 공유'),
  ];

  @override
  Widget build(BuildContext context) {
    // 하단 제스처 바 영역은 useSafeArea가 처리하지 않으므로 SafeArea로 직접 피한다.
    return SafeArea(
      child: Column(
        // 시트가 내용 높이만큼만 올라오도록 한다 (Dialog의 mainAxisSize.min과 같은 이유).
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in _options)
            ListTile(
              leading: Icon(option.icon),
              title: Text(option.label),
              // 여기서 context는 시트 안쪽 → 시트가 닫히고 label이 showModalBottomSheet의 반환값이 된다.
              onTap: () => Navigator.pop(context, option.label),
            ),
        ],
      ),
    );
  }
}
