import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums/user_type.dart';
import '../../providers/auth_state_provider.dart';
import '../employer/main/employer_main_wrapper.dart';
import '../login/jeju_login_screen.dart';
import '../profile/employer_info_input_screen.dart';
import '../profile/worker_info_input_screen.dart';
import '../worker/main/worker_main_screen.dart';

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

    // 앱 시작 시 자동 로그인 상태 확인
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 앱이 포그라운드로 돌아올 때 인증 상태 새로고침
    if (state == AppLifecycleState.resumed) {
      ref.read(authStateProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return switch (authState.status) {
    // 🔄 초기 상태 및 로딩 중
      AuthStatus.initial || AuthStatus.loading => const _LoadingScreen(),

    // 🚫 로그인 안됨 - 로그인 화면
      AuthStatus.unauthenticated => JejuLoginScreen(
        onLoginSuccess: (UserType userType) async {
          // OAuth 로그인 성공 후 서버에서 사용자 정보 조회
          await ref.read(authStateProvider.notifier).handleOAuthSuccess(userType);
        },
      ),

    // ✏️ 회원가입 필요 - 정보 입력 화면
      AuthStatus.needsSignup => _buildSignupScreen(authState.userType),

    // ✅ 완전히 로그인됨 - 메인 화면 (자동 로그인 포함)
      AuthStatus.authenticated => _buildMainScreen(authState.userType),
    };
  }

  /// 회원가입 화면 빌드
  Widget _buildSignupScreen(UserType? userType) {
    if (userType == null) {
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return const _LoadingScreen();
    }

    if (userType == UserType.worker) {
      return WorkerInfoInputScreen(
        onComplete: (completedUserType) async {
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    } else {
      return EmployerInfoInputScreen(
        onComplete: (completedUserType) async {
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    }
  }

  /// 메인 화면 빌드
  Widget _buildMainScreen(UserType? userType) {
    if (userType == null) {
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return const _LoadingScreen();
    }

    if (userType == UserType.worker) {
      return WorkerMainScreen(
        onLogout: () async {
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    } else {
      return EmployerMainWrapper(
        onLogout: () async {
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    }
  }
}

/// 로딩 화면
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
            // 앱 로고
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
              '로그인 상태 확인 중...',
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