import '../data/mock_movies.dart';
import '../models/movie.dart';

/// 영화 목록을 비동기로 돌려주는 Mock Service.
///
/// 화면은 이 클래스가 Future.delayed를 쓰는지, 실제 API를 부르는지 몰라도 된다.
/// 5주차에는 같은 반환 타입(`Future<List<Movie>>`)을 가진 실제 API Service로 교체한다.
class FakeMovieService {
  const FakeMovieService();

  Future<List<Movie>> fetchMovies() async {
    // 네트워크 요청처럼 시간이 걸리는 상황을 흉내 낸다. (미션: 최소 800ms 이상)
    await Future<void>.delayed(const Duration(seconds: 1));
    return movies;
  }
}
