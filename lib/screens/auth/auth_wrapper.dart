import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_state_provider.dart';
import '../../core/enums/user_type.dart';
import '../../services/auth_service.dart'; // 추가
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

    // 🔍 앱 시작 시 인증 상태 디버깅
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debugAuthStatusOnStart();
      ref.read(authStateProvider.notifier).refresh();
    });
  }

  /// 🔍 앱 시작 시 인증 상태 디버깅
  Future<void> _debugAuthStatusOnStart() async {
    print('=== 🔍 AuthWrapper 시작 시 인증 상태 디버깅 ===');
    await AuthService.checkFullAuthStatus();

    // 추가로 AuthStateProvider 상태도 확인
    final currentState = ref.read(authStateProvider);
    print('--- AuthStateProvider 현재 상태 ---');
    print('status: ${currentState.status}');
    print('userType: ${currentState.userType}');
    print('================================');
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
      print('🔄 앱이 포그라운드로 돌아옴 - 인증 상태 새로고침');
      ref.read(authStateProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    print('=== AuthWrapper 빌드 ===');
    print('현재 인증 상태: ${authState.status}');
    print('사용자 타입: ${authState.userType}');

    return switch (authState.status) {
    // 🔄 초기 상태 및 로딩 중
      AuthStatus.initial || AuthStatus.loading => _LoadingScreen(
        onDebugPressed: _debugAuthStatusOnStart, // 디버깅 버튼 추가
      ),

    // 🚫 로그인 안됨 - 로그인 화면
      AuthStatus.unauthenticated => JejuLoginScreen(
        onLoginSuccess: (UserType userType) {
          print('✅ OAuth 로그인 성공: $userType');
          // AuthStateNotifier에서 자동으로 상태 업데이트됨
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
    print('🔍 회원가입 화면 빌드 - userType: $userType');

    if (userType == null) {
      print('❌ UserType이 null - 로그인 화면으로 이동');
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return _LoadingScreen(onDebugPressed: _debugAuthStatusOnStart);
    }

    if (userType == UserType.worker) {
      return WorkerInfoInputScreen(
        onComplete: (completedUserType) async {
          print('=== 구직자 회원가입 완료 ===');
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    } else {
      return EmployerInfoInputScreen(
        onComplete: (completedUserType) async {
          print('=== 사업자 회원가입 완료 ===');
          await ref.read(authStateProvider.notifier).updateAfterSignup();
        },
      );
    }
  }

  /// 메인 화면 빌드
  Widget _buildMainScreen(UserType? userType) {
    print('🔍 메인 화면 빌드 - userType: $userType');

    if (userType == null) {
      print('❌ UserType이 null - 로그인 화면으로 이동');
      // UserType이 없으면 로그인 화면으로
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(authStateProvider.notifier).logout();
      });
      return _LoadingScreen(onDebugPressed: _debugAuthStatusOnStart);
    }

    print('✅ 메인 화면 진입 - 사용자 타입: $userType');

    if (userType == UserType.worker) {
      return WorkerMainScreen(
        onLogout: () async {
          print('=== 구직자 로그아웃 ===');
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    } else {
      return EmployerMainWrapper(
        onLogout: () async {
          print('=== 사업자 로그아웃 ===');
          await ref.read(authStateProvider.notifier).logout();
        },
      );
    }
  }
}

/// 🔍 디버깅 기능이 포함된 로딩 화면
class _LoadingScreen extends StatelessWidget {
  final VoidCallback? onDebugPressed;

  const _LoadingScreen({this.onDebugPressed});

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

            // 🔍 디버깅 버튼 추가 (개발 중에만)
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: onDebugPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔍 인증상태 확인'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService.forceSetActiveStatus();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔧 ACTIVE 설정'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // 임시 토큰 및 PENDING 상태 생성
                    await AuthService.saveAccessToken('test_token_12345');
                    await AuthService.saveUserStatus('PENDING');
                    await AuthService.saveUserType('STAFF');
                    print('✅ 임시 PENDING 사용자 생성 완료');
                    if (onDebugPressed != null) onDebugPressed!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🔧 PENDING 생성'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () async {
                    await AuthService.clearAllUserData();
                    print('✅ 모든 데이터 삭제 완료');
                    if (onDebugPressed != null) onDebugPressed!();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('🗑️ 데이터 삭제'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}