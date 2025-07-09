// lib/providers/auth_state_provider.dart - validate API 활용 버전

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
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

// AuthState Notifier - validate API 활용 버전
class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(const AuthState(status: AuthStatus.initial)) {
    _initializeAuth();
  }

  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 🎯 핵심: validate API로 자동 로그인 초기화
  Future<void> _initializeAuth() async {
    try {
      print('=== 🚀 AuthStateProvider _initializeAuth 시작 ===');

      // 로딩 상태로 설정
      state = state.copyWith(status: AuthStatus.loading);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      final userTypeString = prefs.getString('user_type');
      final userStatus = prefs.getString('user_status');
      final email = prefs.getString('user_email');
      final userId = prefs.getString('user_id');

      print('--- 초기화 중 데이터 확인 ---');
      print('accessToken: ${accessToken != null ? "존재(${accessToken.substring(0, 10)}...)" : "없음"}');
      print('userTypeString: $userTypeString');
      print('userStatus: $userStatus');
      print('email: $email');
      print('userId: $userId');

      // 1️⃣ 토큰이 없으면 로그인 필요
      if (accessToken == null || accessToken.trim().isEmpty) {
        print('❌ 토큰 없음 → AuthStatus.unauthenticated');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 2️⃣ 사용자 타입 검증 및 매핑
      UserType? userType = _mapStringToUserType(userTypeString);
      if (userType == null) {
        print('❌ 유효하지 않은 사용자 타입: $userTypeString → AuthStatus.unauthenticated');
        await _clearAuthData();
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 3️⃣ 🎯 핵심: validate API로 토큰 검증 및 회원가입 여부 확인
      print('🔍 validate API로 토큰 검증 및 회원가입 여부 확인 중...');
      final validateResult = await _validateTokenWithAPI(accessToken);

      if (validateResult['success']) {
        // validate API 성공 - 실제 회원가입된 사용자
        final userData = validateResult['data'];
        print('✅ validate API 확인 완료: 회원가입된 사용자');
        print('사용자 데이터: $userData');

        // 로컬 데이터 업데이트
        await _updateLocalFromValidateAPI(userData);

        state = AuthState(
          status: AuthStatus.authenticated,
          userType: userType,
          accessToken: accessToken,
          userStatus: 'ACTIVE',
          email: userData['email']?.toString() ?? email,
        );
        return;
      } else {
        // validate API 실패 - 회원가입 필요하거나 토큰 무효
        print('❌ validate API 확인 실패: ${validateResult['error']}');

        if (validateResult['needsSignup'] == true) {
          print('📝 회원가입이 필요한 사용자로 확인됨');

          // PENDING 상태로 설정
          await prefs.setString('user_status', 'PENDING');

          state = AuthState(
            status: AuthStatus.needsSignup,
            userType: userType,
            accessToken: accessToken,
            userStatus: 'PENDING',
            email: email,
          );
          return;
        } else {
          // 토큰이 완전히 무효한 경우
          print('🔑 토큰이 무효함 - 재로그인 필요');
          await _clearAuthData();
          state = const AuthState(status: AuthStatus.unauthenticated);
          return;
        }
      }

    } catch (e) {
      print('❌ _initializeAuth 실패: $e');
      print('스택 트레이스: ${StackTrace.current}');
      await _clearAuthData();
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    } finally {
      print('=== AuthStateProvider _initializeAuth 완료 ===');
      print('최종 상태: ${state.status}');
      print('최종 사용자 타입: ${state.userType}');
      print('================================');
    }
  }

  /// 🎯 validate API로 토큰 검증 및 사용자 정보 확인
  Future<Map<String, dynamic>> _validateTokenWithAPI(String accessToken) async {
    try {
      print('🔍 validate API 호출 중...');

      final url = Uri.parse('$baseUrl/auth/validate');
      print('📡 요청 URL: $url');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 15));

      print('📥 validate API 응답 상태: ${response.statusCode}');
      print('📥 validate API 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['code'] == 'SUCCESS' && data['data'] != null) {
          final userData = data['data'];

          // 🎯 핵심: validate API 응답의 status로 회원가입 여부 판단
          final apiStatus = userData['status'] as String?;
          final apiUserType = userData['userType'] as String?;

          if (apiStatus == 'ACTIVE' && apiUserType != null && apiUserType != 'PENDING') {
            print('✅ validate API 확인: 회원가입 완료된 사용자 (status: $apiStatus, userType: $apiUserType)');

            return {
              'success': true,
              'data': userData,
            };
          } else {
            print('⚠️ validate API 확인: 회원가입 미완료 사용자 (status: $apiStatus, userType: $apiUserType)');

            return {
              'success': false,
              'needsSignup': true,
              'error': '회원가입 미완료 - status: $apiStatus, userType: $apiUserType',
            };
          }
        } else {
          print('❌ validate API 응답 형식 오류 - code: ${data['code']}, data: ${data['data']}');
          return {
            'success': false,
            'needsSignup': true,
            'error': 'API 응답 형식 오류',
          };
        }
      } else if (response.statusCode == 401) {
        print('❌ validate API 인증 실패 - 토큰이 유효하지 않음');
        return {
          'success': false,
          'needsSignup': false,
          'error': '토큰 만료',
        };
      } else {
        print('❌ validate API HTTP 오류: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'needsSignup': true,
          'error': 'HTTP ${response.statusCode}',
        };
      }

    } catch (e) {
      print('❌ validate API 호출 오류: $e');
      // 네트워크 오류 시 기존 로컬 상태 기준으로 판단
      final prefs = await SharedPreferences.getInstance();
      final localStatus = prefs.getString('user_status');

      if (localStatus == 'ACTIVE') {
        print('🔄 네트워크 오류이지만 로컬에 ACTIVE 상태 존재 - 자동로그인 허용');
        return {
          'success': true,
          'data': {
            'userId': 'cached_user',
            'email': prefs.getString('user_email'),
            'userType': prefs.getString('user_type'),
            'status': 'ACTIVE',
          },
        };
      } else {
        return {
          'success': false,
          'needsSignup': true,
          'error': '네트워크 오류: $e',
        };
      }
    }
  }

  /// validate API 데이터로 로컬 업데이트
  Future<void> _updateLocalFromValidateAPI(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (userData['status'] != null) {
        await prefs.setString('user_status', userData['status'].toString());
      } else {
        // validate API에서 ACTIVE로 확인된 경우
        await prefs.setString('user_status', 'ACTIVE');
      }

      if (userData['userType'] != null) {
        await prefs.setString('user_type', userData['userType'].toString());
      }

      if (userData['email'] != null) {
        await prefs.setString('user_email', userData['email'].toString());
      }

      // userId 여러 필드명 확인
      String? userId;
      if (userData['userId'] != null) {
        userId = userData['userId'].toString();
      } else if (userData['id'] != null) {
        userId = userData['id'].toString();
      } else if (userData['_id'] != null) {
        userId = userData['_id'].toString();
      }

      if (userId != null) {
        await prefs.setString('user_id', userId);
      }

      print('✅ validate API 데이터로 로컬 업데이트 완료');
    } catch (e) {
      print('❌ 로컬 업데이트 실패: $e');
    }
  }

  /// 사용자 타입 문자열을 UserType enum으로 매핑
  UserType? _mapStringToUserType(String? userTypeString) {
    if (userTypeString == null || userTypeString.trim().isEmpty) {
      return null;
    }

    switch (userTypeString.trim().toUpperCase()) {
      case 'STAFF':
        return UserType.worker;
      case 'MANAGER':
      case 'OWNER':
      case 'EMPLOYER':
        return UserType.employer;
      default:
        print('⚠️ 알 수 없는 사용자 타입: $userTypeString');
        return null;
    }
  }

  /// UserType을 문자열로 매핑
  String _mapUserTypeToString(UserType userType) {
    switch (userType) {
      case UserType.worker:
        return 'STAFF';
      case UserType.employer:
        return 'MANAGER';
      case UserType.manager:
        return 'MANAGER';
    }
  }

  /// 인증 데이터 삭제
  Future<void> _clearAuthData() async {
    try {
      print('🗑️ 인증 데이터 삭제 시작');
      final prefs = await SharedPreferences.getInstance();

      final keysToRemove = [
        'access_token',
        'refresh_token',
        'user_type',
        'user_status',
        'user_email',
        'user_id'
      ];

      for (String key in keysToRemove) {
        await prefs.remove(key);
      }

      print('✅ 인증 데이터 삭제 완료');
    } catch (e) {
      print('❌ 인증 데이터 삭제 실패: $e');
    }
  }

  /// 🎯 OAuth 로그인 성공 후 validate API로 사용자 정보 조회
  Future<void> handleOAuthSuccess(UserType userType) async {
    try {
      print('=== 🎯 OAuth 성공 후 validate API 조회 시작 ===');
      print('UserType: $userType');

      // 로딩 상태로 설정
      state = state.copyWith(status: AuthStatus.loading);

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null || accessToken.isEmpty) {
        print('❌ OAuth 후 토큰이 없음');
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // 🎯 핵심: validate API로 실제 회원가입 여부 확인
      final validateResult = await _validateTokenWithAPI(accessToken);

      if (validateResult['success']) {
        // validate API 성공 - 실제 회원가입된 사용자
        final userData = validateResult['data'];
        print('✅ validate API 확인 완료: 회원가입된 사용자');
        print('사용자 데이터: $userData');

        // 로컬 데이터 업데이트
        await _updateLocalFromValidateAPI(userData);

        state = AuthState(
          status: AuthStatus.authenticated,
          userType: userType,
          accessToken: accessToken,
          userStatus: 'ACTIVE',
          email: userData['email']?.toString(),
        );
      } else {
        // validate API 실패 - 회원가입 필요한 사용자
        print('❌ validate API 확인 실패: ${validateResult['error']}');

        if (validateResult['needsSignup'] == true) {
          print('📝 회원가입이 필요한 사용자로 확인됨');

          // PENDING 상태로 설정
          await prefs.setString('user_status', 'PENDING');

          state = AuthState(
            status: AuthStatus.needsSignup,
            userType: userType,
            accessToken: accessToken,
            userStatus: 'PENDING',
            email: state.email,
          );
        } else {
          // 토큰이 완전히 무효한 경우
          print('🔑 토큰이 무효함 - 재로그인 필요');
          await _clearAuthData();
          state = const AuthState(status: AuthStatus.unauthenticated);
        }
      }

      print('=== OAuth 처리 완료: ${state.status} ===');
    } catch (e) {
      print('❌ OAuth 성공 후 처리 오류: $e');
      // 오류 발생 시 회원가입 필요 상태로 설정
      await _setInitialOAuthState(userType);
    }
  }

  /// 초기 OAuth 상태 설정 (새 사용자)
  Future<void> _setInitialOAuthState(UserType userType) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 현재 저장된 토큰 사용 (OAuth에서 받은 실제 토큰)
      final currentToken = prefs.getString('access_token');

      await prefs.setString('user_type', _mapUserTypeToString(userType));
      await prefs.setString('user_status', 'PENDING');

      state = AuthState(
        status: AuthStatus.needsSignup,
        userType: userType,
        accessToken: currentToken,
        userStatus: 'PENDING',
        email: state.email,
      );
    } catch (e) {
      print('❌ 초기 OAuth 상태 설정 실패: $e');
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// 회원가입 완료 후 상태 업데이트 - 자동 로그인 활성화
  Future<void> updateAfterSignup() async {
    try {
      print('=== 회원가입 완료 후 자동 로그인 활성화 ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_status', 'ACTIVE');

      // 현재 상태를 authenticated로 업데이트
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userStatus: 'ACTIVE',
      );

      print('✅ 회원가입 완료 - 상태: ${state.status}');
      print('✅ 자동 로그인 활성화됨');
    } catch (e) {
      print('❌ 회원가입 후 상태 업데이트 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      print('=== 로그아웃 처리 시작 ===');
      await _clearAuthData();
      state = const AuthState(status: AuthStatus.unauthenticated);
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 오류: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// 상태 새로고침 (자동로그인 재시도)
  Future<void> refresh() async {
    print('🔄 AuthStateProvider refresh 호출');
    await _initializeAuth();
  }

  /// 자동 로그인 가능 여부 확인
  bool canAutoLogin() {
    final result = state.status == AuthStatus.authenticated &&
        state.accessToken != null &&
        state.accessToken!.isNotEmpty &&
        (state.userStatus == 'ACTIVE' || state.userStatus == 'VERIFIED') &&
        (state.userType == UserType.worker || state.userType == UserType.employer);

    print('🔍 canAutoLogin 체크: $result');
    print('  status: ${state.status}');
    print('  hasToken: ${state.accessToken != null}');
    print('  userStatus: ${state.userStatus}');
    print('  userType: ${state.userType}');

    return result;
  }

  /// 디버깅용 상태 출력
  void debugCurrentState() {
    print('=== 현재 AuthState 디버깅 ===');
    print('status: ${state.status}');
    print('userType: ${state.userType}');
    print('accessToken: ${state.accessToken != null ? "존재" : "없음"}');
    print('userStatus: ${state.userStatus}');
    print('email: ${state.email}');
    print('error: ${state.error}');
    print('canAutoLogin: ${canAutoLogin()}');
    print('==========================');
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
  final authNotifier = ref.watch(authStateProvider.notifier);
  return authNotifier.canAutoLogin();
});