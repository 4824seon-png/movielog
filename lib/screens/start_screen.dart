import 'package:flutter/material.dart'; // Scaffold, Column, ElevatedButton ...
import 'package:flutter_svg/flutter_svg.dart'; // SvgPicture
import 'package:go_router/go_router.dart'; // context.go

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(height: 32),
                  const Text('FLUTTER 1주차'),
                  const SizedBox(height: 64),
                  SvgPicture.asset(
                    'assets/logos/movielog_logo.svg',
                    width: 72,
                    height: 72,
                    semanticsLabel: 'MovieLog 로고',
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '영화의 순간을\n기록하세요',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '보고 싶은 영화부터 나만의 평점까지\n한곳에서 관리해요',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  // [결정] Start → Register: go
                  // - 요구사항: 회원가입 화면에서 뒤로가기(→ Start)가 동작하면 안 된다.
                  // - /start와 /register는 둘 다 최상위 route라서 go하면 스택이 [Register]로 재구성된다.
                  // - 대안 pushReplacement도 결과 스택은 같지만, "현재 위치를 바꾼다"는 의도는 go가 더 명확하다.
                  // - push는 스택이 [Start, Register]가 되어 뒤로가기가 가능하므로 제외.
                  onPressed: () => context.go('/register'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: const Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
