// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ilhayoung_app/main.dart';

// 헬퍼 함수들
Future<void> completeWorkerLogin(WidgetTester tester) async {
  // 구직자 선택 (기본값이므로 생략 가능)
  // await tester.tap(find.text('🌊 구직자'));
  // await tester.pump();

  // 카카오 로그인
  await tester.tap(find.text('카카오로 시작하기'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3)); // 로그인 완료 대기

  // 정보입력 화면에서 시작하기 버튼 클릭 (테스트 데이터가 자동 입력됨)
  await tester.tap(find.text('🌊 시작하기'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3)); // 정보입력 완료 대기
}

Future<void> completeEmployerLogin(WidgetTester tester) async {
  // 자영업자 선택
  await tester.tap(find.text('🏔️ 자영업자'));
  await tester.pump();

  // 카카오 로그인
  await tester.tap(find.text('카카오로 시작하기'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3)); // 로그인 완료 대기

  // 사업자 정보입력 화면에서 등록 완료 버튼 클릭 (테스트 데이터가 자동 입력됨)
  await tester.tap(find.text('등록 완료'));
  await tester.pump();
  await tester.pump(const Duration(seconds: 3)); // 정보입력 완료 대기
}

void main() {
  testWidgets('제주 일하영 앱 로그인 화면 테스트', (WidgetTester tester) async {
    // 🌊 제주 테마 앱을 빌드하고 프레임 트리거
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 제주 로그인 화면 요소들이 있는지 확인
    expect(find.text('일하영'), findsOneWidget);
    expect(find.text('🌊 구직자'), findsOneWidget);
    expect(find.text('🏔️ 자영업자'), findsOneWidget);

    // 제주 특색 텍스트 확인
    expect(find.text('제주 바다처럼 넓은\n일자리를 찾아볼까요?'), findsOneWidget);
    expect(find.text('현무암처럼 든든한\n인재를 찾아볼까요?'), findsOneWidget);
  });

  testWidgets('제주 사용자 타입 선택기 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 초기 상태 확인 (기본값: 구직자)
    expect(find.text('카카오로 시작하기'), findsOneWidget);

    // 자영업자 선택
    await tester.tap(find.text('🏔️ 자영업자'));
    await tester.pump();

    // 메시지가 변경되었는지 확인
    expect(find.text('현무암처럼 든든한\n인재를 찾아볼까요?'), findsOneWidget);

    // 다시 구직자 선택
    await tester.tap(find.text('🌊 구직자'));
    await tester.pump();

    // 메시지가 다시 변경되었는지 확인
    expect(find.text('제주 바다처럼 넓은\n일자리를 찾아볼까요?'), findsOneWidget);
  });

  testWidgets('카카오 로그인 버튼 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 카카오로 시작하기 버튼 확인
    expect(find.text('카카오로 시작하기'), findsOneWidget);

    // 버튼 탭 테스트
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();

    // 로딩 상태 확인 (2초 후 로그인 성공)
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Google 로그인 버튼 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // Google로 시작하기 버튼 확인
    expect(find.text('Google로 시작하기'), findsOneWidget);

    // 버튼 탭 테스트
    await tester.tap(find.text('Google로 시작하기'));
    await tester.pump();

    // 로딩 상태 확인
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('제주 캐러셀 슬라이더 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 캐러셀 슬라이더가 렌더링되는지 확인
    expect(find.byType(PageView), findsOneWidget);

    // 제주 아이콘들이 표시되는지 확인
    await tester.pump(const Duration(seconds: 1));

    // 아이콘 이모지들 확인
    expect(find.text('🌊'), findsWidgets);
    expect(find.text('🏔️'), findsWidgets);
    expect(find.text('🍊'), findsWidgets);
  });

  testWidgets('구직자 정보 입력 화면 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 카카오 로그인으로 로그인 진행
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3)); // 로그인 완료 대기

    // 구직자 정보 입력 화면으로 이동했는지 확인
    expect(find.text('프로필 설정'), findsOneWidget);
    expect(find.text('구직자 정보를 입력해주세요'), findsOneWidget);

    // 정보 입력 필드들 확인
    expect(find.text('이름 *'), findsOneWidget);
    expect(find.text('생년월일 *'), findsOneWidget);
    expect(find.text('연락처 *'), findsOneWidget);
    expect(find.text('거주 주소 *'), findsOneWidget);

    // 시작하기 버튼 확인
    expect(find.text('🌊 시작하기'), findsOneWidget);
  });

  testWidgets('사업자 정보 입력 화면 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 자영업자 선택
    await tester.tap(find.text('🏔️ 자영업자'));
    await tester.pump();

    // 카카오 로그인으로 로그인 진행
    await tester.tap(find.text('카카오로 시작하기'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3)); // 로그인 완료 대기

    // 사업자 정보 입력 화면으로 이동했는지 확인
    expect(find.text('사업자 정보 입력'), findsOneWidget);
    expect(find.text('사업장 정보를 입력해주세요'), findsOneWidget);

    // 사업자 정보 입력 필드들 확인
    expect(find.text('대표자명'), findsOneWidget);
    expect(find.text('사업장명'), findsOneWidget);
    expect(find.text('업종'), findsOneWidget);
    expect(find.text('사업자등록번호'), findsOneWidget);

    // 등록 완료 버튼 확인
    expect(find.text('등록 완료'), findsOneWidget);
  });

  testWidgets('구직자 메인 화면 네비게이션 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 구직자로 로그인하고 정보입력 완료까지 진행
    await completeWorkerLogin(tester);

    // 메인 화면 네비게이션 바 확인
    expect(find.text('공고'), findsOneWidget);
    expect(find.text('지원 내역'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('근무'), findsOneWidget);
    expect(find.text('마이페이지'), findsOneWidget);

    // 각 탭 클릭 테스트
    await tester.tap(find.text('공고'));
    await tester.pump();
    expect(find.text('🌊 제주 일자리'), findsOneWidget);

    await tester.tap(find.text('지원 내역'));
    await tester.pump();
    expect(find.text('📝 지원 내역'), findsOneWidget);

    await tester.tap(find.text('근무'));
    await tester.pump();
    expect(find.text('🗓️ 근무관리'), findsOneWidget);
  });

  testWidgets('사업자 메인 화면 네비게이션 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 사업자로 로그인하고 정보입력 완료까지 진행
    await completeEmployerLogin(tester);

    // 사업자 메인 화면 네비게이션 바 확인
    expect(find.text('공고'), findsOneWidget);
    expect(find.text('근무자 관리'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
    expect(find.text('급여정산'), findsOneWidget);
    expect(find.text('마이페이지'), findsOneWidget);

    // 공고 관리 탭 클릭 테스트
    await tester.tap(find.text('공고'));
    await tester.pump();
    expect(find.text('📋 공고 관리'), findsOneWidget);

    // 급여정산 탭 클릭 테스트
    await tester.tap(find.text('급여정산'));
    await tester.pump();
    expect(find.text('💰 급여정산'), findsOneWidget);
  });

  testWidgets('공고 관리 화면 탭 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 사업자로 로그인 완료
    await completeEmployerLogin(tester);

    // 공고 탭으로 이동
    await tester.tap(find.text('공고'));
    await tester.pump();

    // 공고 관리 탭들 확인
    expect(find.text('내 공고'), findsOneWidget);
    expect(find.text('새 공고 작성'), findsOneWidget);

    // 새 공고 작성 탭 클릭
    await tester.tap(find.text('새 공고 작성'));
    await tester.pump();

    // 공고 작성 폼 요소들 확인
    expect(find.text('새 공고 작성'), findsWidgets);
    expect(find.text('공고 제목'), findsOneWidget);
    expect(find.text('상세 설명'), findsOneWidget);
    expect(find.text('공고 등록하기'), findsOneWidget);
  });

  testWidgets('급여정산 화면 기능 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 사업자로 로그인 완료
    await completeEmployerLogin(tester);

    // 급여정산 탭으로 이동
    await tester.tap(find.text('급여정산'));
    await tester.pump();

    // 급여정산 화면 요소들 확인
    expect(find.text('급여 현황'), findsOneWidget);
    expect(find.text('총 직원수'), findsOneWidget);
    expect(find.text('지급 완료'), findsOneWidget);
    expect(find.text('총 급여액'), findsOneWidget);
    expect(find.text('미지급액'), findsOneWidget);

    // 빠른 액션 버튼들 확인
    expect(find.text('일괄 지급'), findsOneWidget);
    expect(find.text('급여명세서'), findsOneWidget);

    // 직원별 급여 내역 확인
    expect(find.text('직원별 급여 내역'), findsOneWidget);
  });

  testWidgets('제주 테마 색상 및 UI 요소 렌더링 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 제주 테마의 주요 UI 요소들이 렌더링되는지 확인
    await tester.pump(const Duration(milliseconds: 500));

    // 애니메이션이 완료된 후 요소 확인
    await tester.pump(const Duration(seconds: 2));

    // 주요 텍스트들이 화면에 표시되는지 확인
    expect(find.text('일하영'), findsOneWidget);
    expect(find.text('제주 청년 × 자영업자 연결'), findsOneWidget);

    // 현무암 색상과 바다 색상이 적용된 버튼들 확인
    final kakaoButton = find.text('카카오로 시작하기');
    final googleButton = find.text('Google로 시작하기');

    expect(kakaoButton, findsOneWidget);
    expect(googleButton, findsOneWidget);
  });

  testWidgets('오름지수 화면 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JejuApp(),
      ),
    );

    // 구직자로 로그인 완료
    await completeWorkerLogin(tester);

    // 근무 탭으로 이동
    await tester.tap(find.text('근무'));
    await tester.pump();

    // 오름지수 버튼 클릭
    await tester.tap(find.byIcon(Icons.star));
    await tester.pump();

    // 로딩 후 오름지수 화면 확인
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('🏆 오름지수'), findsOneWidget);
    expect(find.text('나의 근무 신뢰도를 확인하세요'), findsOneWidget);
    expect(find.text('오름지수'), findsWidgets);
  });

}