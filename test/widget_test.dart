// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ilhayoung_app/main.dart';

void main() {
  testWidgets('일하영 앱 로그인 화면 테스트', (WidgetTester tester) async {
    // 앱을 빌드하고 프레임 트리거
    await tester.pumpWidget(const IlhayoungApp());

    // 로그인 화면 요소들이 있는지 확인
    expect(find.text('일하영'), findsOneWidget);
    expect(find.text('구직자'), findsOneWidget);
    expect(find.text('자영업자'), findsOneWidget);
    expect(find.text('이메일'), findsOneWidget);
    expect(find.text('비밀번호'), findsOneWidget);

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

  testWidgets('이메일 유효성 검사 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const IlhayoungApp());

    // 이메일 필드 찾기
    final emailField = find.byType(TextFormField).first;

    // 잘못된 이메일 입력
    await tester.enterText(emailField, 'invalid-email');

    // 로그인 버튼 찾아서 탭
    final loginButton = find.text('구직자로 시작하기');
    await tester.tap(loginButton);
    await tester.pump();

    // 에러 메시지가 나타나는지 확인
    expect(find.text('올바른 이메일 형식을 입력해주세요'), findsOneWidget);
  });

  testWidgets('비밀번호 유효성 검사 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(const IlhayoungApp());

    // 이메일과 비밀번호 필드 찾기
    final emailField = find.byType(TextFormField).first;
    final passwordField = find.byType(TextFormField).last;

    // 올바른 이메일과 짧은 비밀번호 입력
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, '123');

    // 로그인 버튼 탭
    final loginButton = find.text('구직자로 시작하기');
    await tester.tap(loginButton);
    await tester.pump();

    // 비밀번호 에러 메시지 확인
    expect(find.text('비밀번호는 6자 이상이어야 합니다'), findsOneWidget);
  });
}