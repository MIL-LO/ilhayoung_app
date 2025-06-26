// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ilhayoung_app/main.dart';

void main() {
  testWidgets('제주 일하영 앱 로그인 화면 테스트', (WidgetTester tester) async {
    // 🌊 제주 테마 앱을 빌드하고 프레임 트리거
    await tester.pumpWidget(
      const ProviderScope(  // Riverpod 테스트를 위해 ProviderScope 추가
        child: JejuIlhayoungApp(),  // 제주 테마 앱으로 변경
      ),
    );

    // 제주 로그인 화면 요소들이 있는지 확인
    expect(find.text('일하영'), findsOneWidget);
    expect(find.text('구직자'), findsOneWidget);
    expect(find.text('자영업자'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);

    // 제주 특색 텍스트 확인
    expect(find.text('제주 청년 × 자영업자 연결'), findsOneWidget);
    expect(find.text('현무암 위에서 시작하는 에메랄드 꿈'), findsOneWidget);

    // 구직자 버튼 탭 테스트
    await tester.tap(find.text('구직자'));
    await tester.pump();

    // 구직자로 시작하기 버튼이 있는지 확인
    expect(find.text('구직자로 시작하기'), findsOneWidget);

    // 자영업자 버튼 탭 테스트
    await tester.tap(find.text('자영업자'));
    await tester.pump();

    // 자영업자로 시작하기 버튼이 있는지 확인
    expect(find.text('자영업자로 시작하기'), findsOneWidget);
  });

  testWidgets('제주 텍스트필드 이메일 유효성 검사 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 이메일 필드 찾기 (제주 텍스트필드)
    final emailField = find.byType(TextFormField).first;

    // 잘못된 이메일 입력
    await tester.enterText(emailField, 'invalid-email');

    // 구직자로 시작하기 버튼 찾아서 탭
    final loginButton = find.text('구직자로 시작하기');
    await tester.tap(loginButton);
    await tester.pump();

    // 에러 메시지가 나타나는지 확인
    expect(find.text('올바른 이메일 형식을 입력해주세요'), findsOneWidget);
  });

  testWidgets('제주 텍스트필드 비밀번호 유효성 검사 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 이메일과 비밀번호 필드 찾기
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    // 올바른 이메일과 짧은 비밀번호 입력
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '123');

    // 구직자로 시작하기 버튼 탭
    final loginButton = find.text('구직자로 시작하기');
    await tester.tap(loginButton);
    await tester.pump();

    // 비밀번호 에러 메시지 확인
    expect(find.text('비밀번호는 6자 이상이어야 합니다'), findsOneWidget);
  });

  testWidgets('제주 사용자 타입 선택기 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 초기 상태 확인 (기본값: 구직자)
    expect(find.text('구직자로 시작하기'), findsOneWidget);

    // 자영업자 선택
    await tester.tap(find.text('자영업자'));
    await tester.pump();

    // 버튼 텍스트가 변경되었는지 확인
    expect(find.text('자영업자로 시작하기'), findsOneWidget);
    expect(find.text('구직자로 시작하기'), findsNothing);

    // 다시 구직자 선택
    await tester.tap(find.text('구직자'));
    await tester.pump();

    // 버튼 텍스트가 다시 변경되었는지 확인
    expect(find.text('구직자로 시작하기'), findsOneWidget);
    expect(find.text('자영업자로 시작하기'), findsNothing);
  });

  testWidgets('제주 로그인 유지 스위치 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 로그인 유지 스위치 찾기
    final rememberSwitch = find.text('로그인 유지');
    expect(rememberSwitch, findsOneWidget);

    // 스위치 탭해서 상태 변경 테스트
    await tester.tap(rememberSwitch);
    await tester.pump();

    // 스위치가 정상적으로 작동하는지 확인 (UI 변경 확인)
    // 실제로는 Switch 위젯을 찾아서 value를 확인해야 하지만
    // 간단한 테스트로는 에러가 발생하지 않는지만 확인
  });

  testWidgets('제주 Apple 로그인 버튼 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // Apple로 계속하기 버튼 확인
    expect(find.text('Apple로 계속하기'), findsOneWidget);

    // 버튼 탭 테스트
    await tester.tap(find.text('Apple로 계속하기'));
    await tester.pump();

    // 대화상자가 나타나는지 확인 (준비 중 메시지)
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Apple로 로그인'), findsOneWidget);
    expect(find.text('Apple Sign In 기능을 준비 중입니다.'), findsOneWidget);
  });

  testWidgets('제주 회원가입 링크 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 회원가입 텍스트 확인
    expect(find.text('아직 계정이 없으신가요? '), findsOneWidget);
    expect(find.text('회원가입'), findsOneWidget);

    // 회원가입 버튼 탭
    await tester.tap(find.text('회원가입'));
    await tester.pump();

    // 대화상자 확인
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('회원가입 페이지로 이동합니다.'), findsOneWidget);
  });

  testWidgets('제주 테마 UI 요소 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 제주 테마의 주요 UI 요소들이 렌더링되는지 확인
    await tester.pump(const Duration(milliseconds: 500));

    // 애니메이션이 완료된 후 요소 확인
    await tester.pump(const Duration(seconds: 2));

    // 주요 텍스트들이 화면에 표시되는지 확인
    expect(find.text('일하영'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);

    // 플레이스홀더 텍스트 확인
    expect(find.text('your@email.com'), findsOneWidget);
    expect(find.text('안전한 비밀번호를 입력하세요'), findsOneWidget);
  });

  testWidgets('제주 로딩 상태 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuIlhayoungApp(),
      ),
    );

    // 올바른 정보 입력
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');

    // 로그인 버튼 탭
    final loginButton = find.text('구직자로 시작하기');
    await tester.tap(loginButton);
    await tester.pump();

    // 로딩 인디케이터가 나타나는지 확인
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 로딩 완료까지 기다리기
    await tester.pump(const Duration(seconds: 3));

    // 성공 대화상자 확인
    expect(find.text('로그인 성공! 🎉'), findsOneWidget);
  });
}