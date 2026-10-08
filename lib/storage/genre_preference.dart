import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_movies.dart';

/// 영화 목록에서 마지막으로 선택한 장르를 기기에 저장·복원한다.
///
/// shared_preferences는 보안 저장소가 아니므로 장르처럼 단순하고 중요하지 않은 값만 저장한다.
/// (JWT·비밀번호·개인정보는 flutter_secure_storage를 사용한다.)
class GenrePreference {
  // preferences를 받을 수 있게 열어 두면 테스트에서 가짜 저장소를 넣을 수 있다.
  // 평소에는 null → 실제 SharedPreferencesAsync를 사용한다.
  GenrePreference({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  // 읽기·쓰기에 같은 Key를 써야 복원된다.
  static const _selectedGenreKey = 'selected_genre';

  final SharedPreferencesAsync _preferences;

  /// 저장된 장르. 저장한 적이 없으면 '전체'.
  Future<String> read() async {
    return await _preferences.getString(_selectedGenreKey) ?? allGenre;
  }

  Future<void> save(String genre) async {
    await _preferences.setString(_selectedGenreKey, genre);
  }

  Future<void> clear() async {
    await _preferences.remove(_selectedGenreKey);
  }
}
