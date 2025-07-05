// lib/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 추가
import '../../providers/auth_state_provider.dart';
import '../../core/enums/user_type.dart';
import '../login/jeju_login_screen.dart';
import '../profile/worker_info_input_screen.dart';
import '../profile/employer_info_input_screen.dart';
import '../worker/main/worker_main_screen.dart';
import '../employer/main/employer_main_wrapper.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 🔥 앱 시작 시 인증 상태 새로고침 (자동 로그인 체크)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAuthStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 재활성화될 때 인증 상태 새로고침
    if (state == AppLifecycleState.resumed) {
      _refreshAuthStatus();
    }
  }

  // 🔥 인증 상태 새로고침 (자동 로그인 포함)
  void _refreshAuthStatus() async {
    print('=== AuthWrapper 인증 상태 새로고침 ===');

    // 🔍 디버깅: 저장된 데이터 확인
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userStatus = prefs.getString('user_status');
      final userType = prefs.getString('user_type');

      print('현재 저장된 데이터:');
      print('- Access Token: ${accessToken != null ? '${accessToken.substring(0, 20)}...' : 'null'}');
      print('- User Status: $userStatus');
      print('- User Type: $userType');

      // 🔧 사용자 상태가 PENDING이면 VERIFIED로 업데이트
      if (accessToken != null && userStatus == 'PENDING') {
        print('🔧 PENDING 상태 감지 - 회원가입 완료된 사용자로 간주하여 VERIFIED로 업데이트');
        await prefs.setString('user_status', 'VERIFIED');
        print('✅ 사용자 상태를 VERIFIED로 업데이트 완료');
      }

    } catch (e) {
      print('❌ 데이터 확인 및 업데이트 실패: $e');
    }

    // AuthStateProvider 새로고침
    ref.read(authStateProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    print('=== AuthWrapper 빌드 ===');
    print('현재 인증 상태: ${authState.status}');
    print('사용자 타입: ${authState.userType}');
    print('사용자 상태: ${authState.userStatus}');

    return switch (authState.status) {
    // 초기 상태 및 로딩 중
      AuthStatus.initial || AuthStatus.loading => const _LoadingScreen(),

// 로그인 안됨 - 로그인 화면 표시
      AuthStatus.unauthenticated => JejuLoginScreen(
        onLoginSuccess: (UserType userType) async {
          // 🔥 OAuth 성공 후 즉시 상태 업데이트
          print('=== AuthWrapper에서 로그인 성공 콜백 ===');
          print('UserType: $userType');

          // 🔥 STAFF/OWNER 타입이면 즉시 authenticated 상태로 강제 설정
          if (userType == UserType.worker || userType == UserType.employer) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('user_status', 'ACTIVE');

            // AuthStateProvider 강제 업데이트
            ref.read(authStateProvider.notifier).setAuthenticated(userType);

            print('✅ 강제로 authenticated 상태로 설정 완료');
          }
        },
      ),
    // 회원가입 필요 - 정보 입력 화면 표시
      AuthStatus.needsSignup => _buildSignupScreen(context, ref, authState.userType),

    // 🔥 완전히 로그인됨 - 메인 화면 표시 (자동 로그인 포함)
      AuthStatus.authenticated => _buildMainScreen(context, ref, authState.userType),
    };
  }

  /// 회원가입 화면 빌드
  Widget _buildSignupScreen(BuildContext context, WidgetRef ref, UserType? userType) {
    if (userType == null) {
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return JejuLoginScreen(
        onLoginSuccess: (UserType userType) {
          print('재로그인 성공: $userType');
        },
      );
    }

    if (userType == UserType.worker) {
      return WorkerInfoInputScreen(
        onComplete: (completedUserType) async {
          print('=== 구직자 회원가입 완료 ===');
          // 🔥 회원가입 완료 후 자동 로그인 활성화
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    } else {
      return EmployerInfoInputScreen(
        onComplete: (completedUserType) async {
          print('=== 사업자 회원가입 완료 ===');
          // 🔥 회원가입 완료 후 자동 로그인 활성화
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    }
  }

  /// 🔥 메인 화면 빌드 (자동 로그인으로 진입 가능)
  Widget _buildMainScreen(BuildContext context, WidgetRef ref, UserType? userType) {
    if (userType == null) {
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return JejuLoginScreen(
        onLoginSuccess: (UserType userType) {
          print('재로그인 성공: $userType');
        },
      );
    }

    // 🔥 자동 로그인으로 메인 화면 진입 로그
    final authState = ref.watch(authStateProvider);
    final canAutoLogin = ref.watch(canAutoLoginProvider);

    if (canAutoLogin) {
      print('✅ 자동 로그인으로 메인 화면 진입');
      print('사용자 타입: $userType');
      print('사용자 상태: ${authState.userStatus}');
    }

    if (userType == UserType.worker) {
      return WorkerMainScreen(
        onLogout: () async {
          print('=== 구직자 메인에서 로그아웃 ===');
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    } else {
      return EmployerMainWrapper(
        onLogout: () async {
          print('=== 사업자 메인에서 로그아웃 ===');
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    }
  }
}

/// 로딩 화면 (자동 로그인 체크 중 표시)
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 또는 앱 아이콘
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  '🌊',
                  style: TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '일하영',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '제주 일자리 플랫폼',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: Color(0xFF00A3A3),
            ),
            const SizedBox(height: 16),
            Text(
              '로그인 상태 확인 중...', // 🔥 메시지 변경
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}