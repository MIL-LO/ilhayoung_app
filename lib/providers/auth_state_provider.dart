// lib/providers/auth_state_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/enums/user_type.dart';
import '../services/signup_service.dart';

// 인증 상태 열거형
enum AuthStatus {
  initial,      // 초기 상태
  loading,      // 로딩 중
  unauthenticated, // 로그인 안됨
  needsSignup,  // 회원가입 필요 (OAuth 완료, 정보 입력 필요)
  authenticated, // 완전히 로그인됨
}

// 인증 상태 클래스
class AuthState {
  final AuthStatus status;
  final UserType? userType;
  final String? accessToken;
  final String? userStatus;
  final String? email;
  final String? error;

  const AuthState({
    required this.status,
    this.userType,
    this.accessToken,
    this.userStatus,
    this.email,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserType? userType,
    String? accessToken,
    String? userStatus,
    String? email,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userType: userType ?? this.userType,
      accessToken: accessToken ?? this.accessToken,
      userStatus: userStatus ?? this.userStatus,
      email: email ?? this.email,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'AuthState(status: $status, userType: $userType, userStatus: $userStatus)';
  }
}

// AuthState Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _initializeAuth();
  }

  /// 🔥 UserType 기반으로 간단하게 수정된 인증 초기화
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userTypeString = prefs.getString('user_type');
      final userStatus = prefs.getString('user_status');
      final email = prefs.getString('user_email');

      print('=== 인증 상태 초기화 (UserType 기반) ===');
      print('Access Token: ${accessToken?.substring(0, 20)}...');
      print('User Type: $userTypeString');
      print('User Status: $userStatus');
      print('Email: $email');

      if (accessToken == null) {
        print('❌ 토큰 없음 - unauthenticated 상태');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 🔥 STAFF/OWNER 타입이면 상태와 무관하게 바로 자동 로그인
      if (userTypeString == 'STAFF' || userTypeString == 'OWNER') {
        print('🚀 UserType 기반 자동 로그인 성공 ($userTypeString)');

        // 사용자 타입 매핑
        UserType? userType;
        if (userTypeString == 'STAFF') {
          userType = UserType.worker;
        } else if (userTypeString == 'OWNER') {
          userType = UserType.employer;
        }

        // 🔥 PENDING 상태여도 STAFF/OWNER면 ACTIVE로 강제 업데이트
        if (userStatus == 'PENDING') {
          await prefs.setString('user_status', 'ACTIVE');
          print('✅ PENDING → ACTIVE 상태 자동 업데이트');
        }

        state = AuthState(
          status: AuthStatus.authenticated, // 🔥 바로 authenticated 상태
          accessToken: accessToken,
          userType: userType,
          userStatus: 'ACTIVE',
          email: email,
        );

        print('✅ 자동 로그인 완료 - authenticated 상태');
        return;
      }

      // 🔥 STAFF/OWNER가 아닌 경우만 로그인 필요
      print('❌ 유효하지 않은 사용자 타입 - 로그인 필요');
      state = const AuthState(status: AuthStatus.unauthenticated);

    } catch (e) {
      print('❌ 인증 상태 초기화 실패: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// OAuth 로그인 성공 후 상태 업데이트
  Future<void> updateAfterOAuth({
    required String accessToken,
    required UserType userType,
    String? email,
  }) async {
    try {
      print('=== OAuth 후 상태 업데이트 ===');
      print('UserType: $userType');
      print('Email: $email');

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('user_type', userType == UserType.worker ? 'STAFF' : 'OWNER');
      await prefs.setString('user_status', 'PENDING');
      if (email != null) {
        await prefs.setString('user_email', email);
      }

      // 상태 업데이트 (회원가입 필요)
      state = AuthState(
        status: AuthStatus.needsSignup,
        userType: userType,
        accessToken: accessToken,
        userStatus: 'PENDING',
        email: email,
      );

      print('OAuth 후 상태: ${state.status}');

    } catch (e) {
      print('OAuth 후 상태 업데이트 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 🔥 회원가입 완료 후 상태 업데이트 (자동 로그인 활성화)
  Future<void> updateAfterSignup() async {
    try {
      print('=== 회원가입 완료 후 상태 업데이트 ===');

      // SharedPreferences 업데이트 - ACTIVE로 설정하여 자동 로그인 활성화
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_status', 'ACTIVE');

      // 상태 업데이트 (완전히 로그인됨)
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userStatus: 'ACTIVE', // 🔥 ACTIVE로 설정
      );

      print('✅ 회원가입 후 상태: ${state.status}');
      print('✅ 사용자 상태: ACTIVE (자동 로그인 활성화)');

    } catch (e) {
      print('회원가입 후 상태 업데이트 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      print('=== 로그아웃 처리 ===');

      // SharedPreferences 클리어
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_type');
      await prefs.remove('user_status');
      await prefs.remove('user_email');
      await prefs.remove('user_id');

      // 상태 초기화
      state = const AuthState(status: AuthStatus.unauthenticated);

      print('로그아웃 완료');

    } catch (e) {
      print('로그아웃 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 상태 새로고침
  Future<void> refresh() async {
    await _initializeAuth();
  }

  /// 🔥 UserType 기반 자동 로그인 가능 여부 확인
  bool canAutoLogin() {
    return state.accessToken != null &&
        (state.userType == UserType.worker || state.userType == UserType.employer);
  }

  /// 🔥 강제로 인증된 상태로 설정 (회원가입 완료 시)
  void setAuthenticated(UserType userType) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userType: userType,
      userStatus: 'ACTIVE',
    );
  }
}

// Provider 정의
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier();
});

// 편의 Provider들
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated;
});

final needsSignupProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.needsSignup;
});

final currentUserTypeProvider = Provider<UserType?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.userType;
});

// 🔥 UserType 기반 자동 로그인 가능 여부 Provider 수정
final canAutoLoginProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.accessToken != null &&
      (authState.userType == UserType.worker || authState.userType == UserType.employer);
});