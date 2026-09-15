class Movie {
  final String title;
  final int year;
  final String? nickname;

  Movie({required this.title, required this.year, this.nickname});

  String displayNickname() {
    final trimmed = nickname?.trim();
    return trimmed?.isNotEmpty == true ? trimmed! : '별명 없음';
  }
}

void main() {
  final movies = <Movie>[
    Movie(title: '인터스텔라', year: 2014, nickname: '인터스텔라'),
    Movie(title: '기생충', year: 2019, nickname: null),
    Movie(title: '라라랜드', year: 2016),
  ];

  for (final movie in movies) {
    print('${movie.title} (${movie.displayNickname()})');
  }
}
