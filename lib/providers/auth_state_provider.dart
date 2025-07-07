// lib/providers/auth_state_provider.dart - 개선된 자동 로그인 로직

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/enums/user_type.dart';

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
}

// AuthState Notifier - 자동 로그인 로직 개선
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _initializeAuth();
  }

  /// 🎯 핵심: 자동 로그인 초기화 로직
  Future<void> _initializeAuth() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userTypeString = prefs.getString('user_type');
      final userStatus = prefs.getString('user_status');
      final email = prefs.getString('user_email');

      print('=== 자동 로그인 상태 확인 ===');
      print('Access Token: ${accessToken != null ? "존재" : "없음"}');
      print('User Type: $userTypeString');
      print('User Status: $userStatus');
      print('Email: $email');

      // 1️⃣ 토큰이 없으면 로그인 필요
      if (accessToken == null || accessToken.isEmpty) {
        print('❌ 토큰 없음 - 로그인 화면으로');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 2️⃣ 사용자 타입 검증 및 매핑
      UserType? userType = _mapStringToUserType(userTypeString);
      if (userType == null) {
        print('❌ 유효하지 않은 사용자 타입 - 로그인 필요');
        await _clearAuthData();
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 3️⃣ 사용자 상태에 따른 분기 처리
      if (userStatus == 'PENDING') {
        print('⚠️ PENDING 상태 - 회원가입 필요');
        state = AuthState(
          status: AuthStatus.needsSignup,
          userType: userType,
          accessToken: accessToken,
          userStatus: userStatus,
          email: email,
        );
        return;
      }

      if (userStatus == 'ACTIVE' || userStatus == 'VERIFIED') {
        print('✅ 자동 로그인 성공 - 메인 화면으로');
        state = AuthState(
          status: AuthStatus.authenticated,
          userType: userType,
          accessToken: accessToken,
          userStatus: userStatus,
          email: email,
        );
        return;
      }

      // 4️⃣ 알 수 없는 상태인 경우 로그인 필요
      print('❓ 알 수 없는 사용자 상태: $userStatus - 로그인 필요');
      await _clearAuthData();
      state = const AuthState(status: AuthStatus.unauthenticated);

    } catch (e) {
      print('❌ 자동 로그인 초기화 실패: $e');
      await _clearAuthData();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 사용자 타입 문자열을 UserType enum으로 매핑
  UserType? _mapStringToUserType(String? userTypeString) {
    switch (userTypeString) {
      case 'STAFF':
        return UserType.worker;
      case 'MANAGER':
      case 'OWNER':
        return UserType.employer;
      default:
        return null;
    }
  }

  /// 인증 데이터 삭제
  Future<void> _clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('refresh_token');
      await prefs.remove('user_type');
      await prefs.remove('user_status');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      print('✅ 인증 데이터 삭제 완료');
    } catch (e) {
      print('❌ 인증 데이터 삭제 실패: $e');
    }
  }

  /// OAuth 로그인 성공 후 상태 업데이트
  Future<void> updateAfterOAuth({
    required String accessToken,
    required UserType userType,
    String? email,
  }) async {
    try {
      print('=== OAuth 성공 후 상태 업데이트 ===');
      print('UserType: $userType');
      print('Email: $email');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('user_type', _mapUserTypeToString(userType));
      await prefs.setString('user_status', 'PENDING');
      if (email != null) {
        await prefs.setString('user_email', email);
      }

      // 회원가입 필요 상태로 설정
      state = AuthState(
        status: AuthStatus.needsSignup,
        userType: userType,
        accessToken: accessToken,
        userStatus: 'PENDING',
        email: email,
      );

      print('✅ OAuth 후 상태: ${state.status}');
    } catch (e) {
      print('❌ OAuth 후 상태 업데이트 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 회원가입 완료 후 상태 업데이트 - 자동 로그인 활성화
  Future<void> updateAfterSignup() async {
    try {
      print('=== 회원가입 완료 후 자동 로그인 활성화 ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_status', 'ACTIVE');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userStatus: 'ACTIVE',
      );

      print('✅ 회원가입 완료 - 자동 로그인 활성화');
    } catch (e) {
      print('❌ 회원가입 후 상태 업데이트 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      print('=== 로그아웃 처리 ===');
      await _clearAuthData();
      state = const AuthState(status: AuthStatus.unauthenticated);
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 상태 새로고침
  Future<void> refresh() async {
    await _initializeAuth();
  }

  /// 강제로 인증된 상태로 설정 (회원가입 완료 시)
  void setAuthenticated(UserType userType) {
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userType: userType,
      userStatus: 'ACTIVE',
    );
  }

  /// UserType을 문자열로 매핑
  String _mapUserTypeToString(UserType userType) {
    switch (userType) {
      case UserType.worker:
        return 'STAFF';
      case UserType.employer:
        return 'MANAGER';
      case UserType.manager:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  /// 자동 로그인 가능 여부 확인
  bool canAutoLogin() {
    return state.status == AuthStatus.authenticated &&
        state.accessToken != null &&
        (state.userType == UserType.worker || state.userType == UserType.employer);
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

final canAutoLoginProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.status == AuthStatus.authenticated;
});