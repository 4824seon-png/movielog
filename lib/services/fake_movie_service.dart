import '../data/mock_movies.dart';
import '../models/movie.dart';

/// FakeMovieService가 어떤 결과로 끝날지 정하는 모드.
/// 실제 서버 없이 Success·Empty·Error 화면을 재현하기 위해 사용한다.
enum MovieLoadMode { success, empty, failure }

/// 영화 목록을 불러오지 못했을 때 던지는 예외.
/// message는 로그용이며 화면에는 그대로 노출하지 않는다.
class MovieLoadException implements Exception {
  const MovieLoadException(this.message);

  final String message;

  // 재정의하지 않으면 로그에 "Instance of 'MovieLoadException'"으로만 찍힌다.
  @override
  String toString() => 'MovieLoadException: $message';
}

/// 영화 목록을 비동기로 돌려주는 Mock Service.
///
/// 화면은 이 클래스가 Future.delayed를 쓰는지, 실제 API를 부르는지 몰라도 된다.
/// 5주차에는 같은 반환 타입(`Future<List<Movie>>`)을 가진 실제 API Service로 교체한다.
class FakeMovieService {
  const FakeMovieService();

  // TODO(5주차 유저별 평점 조회 API): Future.delayed와 Mock 반환을 실제 API 호출로 교체한다.
  Future<List<Movie>> fetchMovies({
    MovieLoadMode mode = MovieLoadMode.success,
  }) async {
    // 네트워크 요청처럼 시간이 걸리는 상황을 흉내 낸다. (미션: 최소 800ms 이상)
    // 실패도 지연 뒤에 일어나야 Loading → Error 순서로 보인다.
    await Future<void>.delayed(const Duration(seconds: 1));

    // async 함수 안의 throw는 앱을 멈추지 않고 Future를 "오류로 완료"시킨다.
    // → FutureBuilder의 snapshot.hasError로 전달된다.
    return switch (mode) {
      MovieLoadMode.success => movies,
      MovieLoadMode.empty => const <Movie>[],
      MovieLoadMode.failure => throw const MovieLoadException(
        '영화를 불러오지 못했습니다.',
      ),
    };
  }
}
