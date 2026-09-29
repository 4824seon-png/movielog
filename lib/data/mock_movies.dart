import '../models/movie.dart';

/// 홈·목록·상세가 함께 사용하는 Mock 영화 데이터.
///
/// 데이터 출처를 이 파일 하나로 두면 화면마다 제목·연도가 달라지는 문제가 없다.
/// 모델(models/)과 값(data/)을 분리해 두면, 나중에 API로 바꿀 때 이 파일만 교체하면 된다.
const movies = [
  Movie(
    id: 1,
    title: '별빛 아래 우리',
    genre: '드라마',
    year: 2023,
    posterAsset: 'assets/images/posters/hero_under_the_starlight.jpg',
    rating: 4.8,
    runningTime: 124,
    synopsis:
        '바쁜 일상 속에서 서로를 잊고 지내던 두 사람이 작은 천문대에서 다시 만난다. '
        '매일 밤 함께 별을 관측하며, 잊고 있던 꿈과 마음을 조금씩 되찾아 가는 이야기.',
  ),
  Movie(
    id: 2,
    title: '우주의 끝에서',
    genre: 'SF',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_echoes_of_the_void.jpg',
    rating: 4.2,
    runningTime: 138,
    synopsis:
        '미지의 행성에 홀로 불시착한 탐사대원이 사막 한가운데서 정체를 알 수 없는 구조물을 발견한다. '
        '신호를 따라갈수록 그는 인류가 보낸 적 없는 메시지의 의미에 가까워진다.',
  ),
  Movie(
    id: 3,
    title: '기억의 숲',
    genre: '애니메이션',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_whispering_woods.jpg',
    rating: 4.9,
    runningTime: 102,
    synopsis:
        '길을 잃은 아이가 속삭이는 숲에서 작은 정령을 만난다. '
        '숲의 기억을 되찾아 주기 위한 모험 속에서 아이는 우정과 용기를 배운다.',
  ),
  Movie(
    id: 4,
    title: '밤의 그림자',
    genre: '스릴러',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_night_shadows.jpg',
    rating: 3.8,
    runningTime: 116,
    synopsis:
        '네온사인이 꺼지지 않는 골목에서 연쇄 실종 사건이 일어난다. '
        '사건을 쫓던 형사는 모든 단서가 자신의 과거를 가리키고 있다는 사실을 알게 된다.',
  ),
  Movie(
    id: 5,
    title: '미션 임프로버블',
    genre: '코미디',
    year: 2023,
    posterAsset: 'assets/images/posters/poster_abyss_walker.jpg',
    rating: 4.0,
    runningTime: 109,
    synopsis:
        '어설프지만 운만큼은 최고인 요원 맥스가 다시 돌아왔다. '
        '계획은 매번 어긋나지만, 이상하게도 임무는 늘 성공한다.',
  ),
  Movie(
    id: 6,
    title: '네 번째 오후',
    genre: '로맨스',
    year: 2024,
    posterAsset: 'assets/images/posters/poster_fourth_afternoon.jpg',
    rating: 4.5,
    runningTime: 112,
    synopsis:
        '매주 같은 카페, 같은 시간에 마주치던 두 사람. '
        '네 번째 오후, 처음으로 건넨 한마디가 두 사람의 계절을 바꾸기 시작한다.',
  ),
];

/// 영화 목록의 장르 Chip 목록. 첫 항목('전체')은 필터를 적용하지 않는다는 뜻이다.
///
/// [결정] 장르 목록 출처: 고정 목록으로 선언한다.
/// - Chip 순서를 디자인대로 직접 정할 수 있고 코드가 단순하다.
/// - 영화가 없는 장르를 넣으면 빈 결과가 나올 수 있으므로 목록 화면에서 빈 상태 문구를 처리한다.
/// - 대안: movies에서 자동 추출(['전체', ...movies.map((m) => m.genre).toSet()])
///   → 데이터와 항상 일치하지만 순서가 Mock 데이터 순서를 따른다.
const allGenre = '전체';
const genres = [allGenre, '드라마', 'SF', '애니메이션', '스릴러', '코미디', '로맨스'];

/// id로 영화를 찾는다. 없으면 null.
/// 파라미터가 int?인 이유: 라우터에서 int.tryParse에 실패한 값(null)을 그대로 넘길 수 있게 하기 위해.
Movie? findMovieById(int? id) {
  for (final movie in movies) {
    if (movie.id == id) return movie;
  }
  return null;
}
