/// 영화 한 편의 데이터 형태.
/// 모든 필드가 final + const 생성자 → 불변 객체이며 `const movies = [...]`로 선언할 수 있다.
class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.year,
    required this.posterAsset,
    required this.rating,
    required this.runningTime,
    required this.synopsis,
  });

  final int id; // 영화 식별자. 상세 경로 /movies/:movieId 에 사용
  final String title;
  final String genre; // 장르 Chip 필터의 비교 대상
  final int year;
  final String posterAsset; // pubspec에 등록된 에셋 경로
  final double rating; // 평균 평점 (Mock). 카드 ★ 뱃지와 상세 RatingBarIndicator에 사용

  // [결정] 상세 화면용 필드 추가: 러닝타임, 시놉시스
  // - 영화마다 다른 값이 표시되어 "Route ID에 해당하는 Mock Movie를 보여준다"를 확실히 충족한다.
  // - 대안: 기존 필드만 사용(제목·연도·장르·포스터) → 시놉시스 영역 생략.
  final int runningTime; // 분 단위
  final String synopsis;
}
