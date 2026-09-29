import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 회원가입 화면 (2주차 과제).
///
/// Controller·FocusNode·약관 동의 여부처럼 화면이 살아 있는 동안 유지해야 하는 값을
/// State에서 관리하므로 StatefulWidget으로 만든다.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form 전체를 한 번에 검증하기 위한 key. formKey.currentState로 FormState에 접근한다.
  final _formKey = GlobalKey<FormState>();

  // build 밖(State 필드)에서 생성한다.
  // build 안에서 만들면 rebuild마다 새로 생성되어 입력값·커서·Focus가 초기화된다.
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _agreedToTerms = false;

  // Controller와 FocusNode는 더 이상 쓰지 않을 때 직접 정리해야 메모리 누수가 없다.
  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // ── Validator ──
  // null 반환 = 통과, 문자열 반환 = 해당 문구를 오류로 표시.
  //
  // [결정] 오류 표시 시점: 입력하는 즉시 검사하되, 빈 값은 오류로 표시하지 않는다.
  // - Form의 autovalidateMode: onUserInteraction → 사용자가 입력한 필드부터 바로 검사.
  // - 빈 값은 null(통과)로 처리해서 "아직 입력 안 함"과 "잘못 입력함"을 구분한다.
  //   → 틀린 입력만 빨간색으로 보여 어느 칸을 고쳐야 할지 바로 알 수 있다.
  // - 빈 값으로 가입하는 것은 _canSubmit(버튼 비활성화)이 막는다.
  // - 대안: 가입하기를 눌렀을 때만 검사(Notion 기본) → 버튼이 비활성이라 오류를 볼 기회가 거의 없어 제외.
  String? _validateNickname(String? value) {
    final nickname = value?.trim() ?? '';
    if (nickname.isEmpty) return null;
    if (nickname.length < 2) return '닉네임은 2자 이상이어야 합니다.';
    return null;
  }

  // [결정] 이메일 검증 규칙: Notion 방식 그대로 '@' 포함 여부로 판단한다.
  // - 대안: 정규식으로 형식 전체 검사('test@'도 오류) → 이번에는 Notion 기준을 따른다.
  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return null;
    if (!email.contains('@')) return '올바른 이메일 형식이 아닙니다.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return null;
    if (password.length < 8) return '비밀번호는 8자 이상이어야 합니다.';
    return null;
  }

  // 버튼 활성화 조건 (Notion 9번). 빠른 UI 판단용이고, 최종 검증은 제출 시 validate()가 한다.
  // build 안에서 매번 계산되므로 입력(onChanged → setState)이나 Checkbox가 바뀔 때마다 최신 값이 반영된다.
  bool get _canSubmit =>
      _nicknameController.text.trim().length >= 2 &&
      _emailController.text.contains('@') &&
      _passwordController.text.length >= 8 &&
      _agreedToTerms;

  void _submit() {
    // 버튼 활성화 조건과 별개로, 제출 시 Form 전체를 다시 검증한다.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    FocusScope.of(context).unfocus(); // 키보드 닫기

    // [결정] Register → Home: pushReplacement
    // - 요구사항: 홈 화면에서 뒤로가기(→ Register)가 동작하면 안 된다.
    // - pushReplacement는 현재 화면(Register)을 스택에서 제거하고 Home으로 교체한다.
    //   결과 스택: [MainScreen(Home)] → 뒤로가기 시 앱 종료.
    // - 대안 go('/home')도 결과는 같다. go는 "위치 전환", pushReplacement는
    //   "완료 후 이전 화면을 없애고 교체"라는 의미를 드러낸다(Notion: 로그인 완료 → go 또는 pushReplacement).
    // - push는 [Register, Home]이 되어 뒤로가기로 회원가입에 돌아가므로 제외.
    context.pushReplacement('/home');
  }

  // 입력이 바뀔 때마다 build를 다시 호출해 버튼 상태·suffix 아이콘을 갱신한다.
  // Controller는 입력창 값만 동기화할 뿐, 다른 위젯을 다시 그려주지는 않기 때문이다.
  void _onFieldChanged(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Start에서 go로 들어와 돌아갈 화면이 없으므로(canPop == false)
      // AppBar가 ← 뒤로 버튼을 자동으로 만들지 않는다. (요구사항: 회원가입에서 뒤로가기 불가)
      appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
      body: SafeArea(
        // [결정] 레이아웃: 전체 스크롤 (2주차 10번 구조)
        // - 화면이 충분히 길면 약관·버튼·로그인이 하단에 붙고,
        //   키보드가 올라와 공간이 줄면 화면 전체가 스크롤되어 Overflow가 없다.
        // - LayoutBuilder: 부모(SafeArea 안쪽)가 준 실제 높이(constraints.maxHeight)를 얻는다.
        // - ConstrainedBox(minHeight): 스크롤 내용의 최소 높이를 화면 높이로 맞춘다.
        // - IntrinsicHeight: 스크롤 안에서는 높이가 무한이라 Spacer를 쓸 수 없는데,
        //   내용 높이를 먼저 계산해 Column에 유한한 높이를 줘서 Spacer가 남은 공간을 채울 수 있게 한다.
        // - 대안: 입력창만 스크롤 + 하단 고정 → 키보드가 올라오면 하단 영역이 공간을 계속 차지해 제외.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // 스크롤하면 키보드를 닫는다.
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _RegisterHeader(),
                          const SizedBox(height: 40),
                          _LabeledTextField(
                            label: '닉네임',
                            hintText: '닉네임을 입력해주세요',
                            controller: _nicknameController,
                            validator: _validateNickname,
                            textInputAction: TextInputAction.next,
                            onChanged: _onFieldChanged,
                            // 키보드 '다음' → 이메일 입력창으로 Focus 이동
                            onFieldSubmitted: (_) =>
                                _emailFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          _LabeledTextField(
                            label: '이메일',
                            hintText: '이메일 주소를 입력해주세요',
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            validator: _validateEmail,
                            keyboardType:
                                TextInputType.emailAddress, // @가 있는 키보드
                            textInputAction: TextInputAction.next,
                            onChanged: _onFieldChanged,
                            onFieldSubmitted: (_) =>
                                _passwordFocusNode.requestFocus(),
                          ),
                          const SizedBox(height: 16),
                          _LabeledTextField(
                            label: '비밀번호',
                            hintText: '비밀번호를 입력해주세요',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            validator: _validatePassword,
                            obscureText: true, // 입력값을 ●로 가림
                            textInputAction:
                                TextInputAction.done, // 마지막 칸: '완료'
                            onChanged: _onFieldChanged,
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          // 입력창과 하단 영역 사이의 남은 공간을 모두 차지해 하단 영역을 아래로 민다.
                          const Spacer(),
                          const SizedBox(height: 24),
                          _TermsCheckbox(
                            value: _agreedToTerms,
                            onChanged: (value) {
                              // setState 안에는 바뀌는 값만 넣는다 (Notion 8번).
                              setState(() => _agreedToTerms = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              // onPressed가 null이면 버튼이 비활성화된다 (Notion 9번).
                              // 비활성 색상은 AppTheme의 disabledBackgroundColor가 담당한다.
                              onPressed: _canSubmit ? _submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary,
                                foregroundColor: Theme.of(context)
                                    .colorScheme
                                    .onPrimary,
                              ),
                              child: const Text('가입하기'),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const _LoginPrompt(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 상단 환영 문구.
class _RegisterHeader extends StatelessWidget {
  const _RegisterHeader();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      '환영합니다!\n간단한 정보만 입력하고 시작해보세요.',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge
          ?.copyWith(color: colors.onSurfaceVariant),
    );
  }
}

/// 라벨 + TextFormField + 상태 아이콘(✓ / !)을 묶은 입력 필드.
///
/// 세 입력창이 같은 구조를 반복하므로 하나의 위젯으로 분리했다.
/// 값(Controller)과 검증 규칙(validator)은 부모가 전달하고, 이 위젯은 표시만 담당한다.
class _LabeledTextField extends StatelessWidget {
  const _LabeledTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.validator,
    required this.onChanged,
    required this.onFieldSubmitted,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final FormFieldValidator<String> validator; // String? Function(String?)
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onFieldSubmitted;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // TextFormField 밖(아이콘·배경색)에서도 오류 여부가 필요하므로 같은 validator로 한 번 더 판단한다.
    // 부모가 onChanged에서 setState하므로 입력할 때마다 다시 계산된다.
    final text = controller.text;
    final hasError = validator(text) != null;
    final isValid = text.isNotEmpty && !hasError; // 빈 값은 ✓도 !도 표시하지 않는다.

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          // 테두리(enabled/focused/error)는 AppTheme의 inputDecorationTheme을 사용한다.
          decoration: InputDecoration(
            hintText: hintText,
            // 오류일 때만 배경을 분홍(errorContainer)으로 바꾼다. null이면 테마 기본값.
            fillColor: hasError ? colors.errorContainer : null,
            suffixIcon: hasError
                ? Icon(Icons.error_outline, color: colors.error)
                : isValid
                ? Icon(Icons.check_circle, color: colors.primary)
                : null,
          ),
        ),
      ],
    );
  }
}

/// 필수 약관 동의 Checkbox.
/// 체크 상태는 부모가 가지고 있고, 이 위젯은 표시와 변경 알림만 담당한다.
class _TermsCheckbox extends StatelessWidget {
  const _TermsCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: value,
          // Checkbox의 onChanged는 bool?을 준다(tristate 대비) → null이면 false로 처리.
          onChanged: (checked) => onChanged(checked ?? false),
        ),
        Text('필수 약관에 동의합니다', style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}

/// '이미 계정이 있나요? 로그인' 안내.
///
/// [결정] 로그인 링크: 표시만 하고 동작은 연결하지 않는다.
/// - 로그인 화면이 아직 없다.
/// - 대안: 탭 시 '준비 중' Snackbar / 링크 생략.
class _LoginPrompt extends StatelessWidget {
  const _LoginPrompt();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '이미 계정이 있나요?',
          style: textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Text(
          '로그인',
          style: textTheme.bodyMedium?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
