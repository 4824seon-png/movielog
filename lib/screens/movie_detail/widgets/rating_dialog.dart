import 'package:flutter/material.dart';

import 'movie_rating_input.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '영화는 어떠셨나요?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 24),
            MovieRatingInput(
              rating: rating,
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // [결정] 0점일 때 확인 버튼 비활성화
              // - onPressed가 null이면 버튼이 비활성화된다. 별을 누르면 setState → rebuild로 다시 계산되어 활성화.
              // - "평점 선택값과 저장 버튼 상태가 함께 갱신된다"(최종 체크리스트)를 충족한다.
              // - minRating 0.5로 0점 선택을 막아 둔 의도와도 맞다.
              // - 대안: 항상 활성 → 선택하지 않고 확인하면 0.0이 반환된다.
              onPressed: rating == 0
                  ? null
                  : () {
                      // 두 번째 인자가 showDialog<double>의 반환값이 된다.
                      Navigator.pop(context, rating);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text('확인'),
            ),
          ],
        ),
      ),
    );
  }
}
