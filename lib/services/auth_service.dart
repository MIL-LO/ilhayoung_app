// lib/services/auth_service.dart - 향상된 버전

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userTypeKey = 'user_type';
  static const String _userStatusKey = 'user_status';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey = 'user_id';

  /// 🔑 액세스 토큰 가져오기
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);

      if (accessToken != null && accessToken.isNotEmpty) {
        print('✅ 액세스 토큰 가져오기 성공');
        return accessToken;
      } else {
        print('❌ 액세스 토큰이 없음');
        return null;
      }
    } catch (e) {
      print('❌ 액세스 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// 🔄 리프레시 토큰 가져오기
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);

      if (refreshToken != null && refreshToken.isNotEmpty) {
        print('✅ 리프레시 토큰 가져오기 성공');
        return refreshToken;
      } else {
        print('❌ 리프레시 토큰이 없음');
        return null;
      }
    } catch (e) {
      print('❌ 리프레시 토큰 가져오기 실패: $e');
      return null;
    }
  }

  /// 👤 현재 사용자 타입 가져오기
  static Future<String?> getUserType() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userType = prefs.getString(_userTypeKey);

      if (userType != null && userType.isNotEmpty) {
        print('✅ 사용자 타입 가져오기 성공: $userType');
        return userType;
      } else {
        print('❌ 사용자 타입이 없음');
        return null;
      }
    } catch (e) {
      print('❌ 사용자 타입 가져오기 실패: $e');
      return null;
    }
  }

  /// 📧 현재 사용자 이메일 가져오기
  static Future<String?> getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_userEmailKey);

      if (email != null && email.isNotEmpty) {
        print('✅ 사용자 이메일 가져오기 성공: $email');
        return email;
      } else {
        print('❌ 사용자 이메일이 없음');
        return null;
      }
    } catch (e) {
      print('❌ 사용자 이메일 가져오기 실패: $e');
      return null;
    }
  }

  /// 🔍 현재 사용자 상태 가져오기
  static Future<String?> getUserStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final status = prefs.getString(_userStatusKey);

      if (status != null && status.isNotEmpty) {
        print('✅ 사용자 상태 가져오기 성공: $status');
        return status;
      } else {
        print('❌ 사용자 상태가 없음');
        return null;
      }
    } catch (e) {
      print('❌ 사용자 상태 가져오기 실패: $e');
      return null;
    }
  }

  /// 🆔 현재 사용자 ID 가져오기
  static Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);

      if (userId != null && userId.isNotEmpty) {
        print('✅ 사용자 ID 가져오기 성공: $userId');
        return userId;
      } else {
        print('❌ 사용자 ID가 없음');
        return null;
      }
    } catch (e) {
      print('❌ 사용자 ID 가져오기 실패: $e');
      return null;
    }
  }

  /// 💾 액세스 토큰 저장
  static Future<bool> saveAccessToken(String token) async {
    try {
      if (token.isEmpty) {
        print('❌ 빈 토큰은 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
      print('✅ 액세스 토큰 저장 성공');
      return true;
    } catch (e) {
      print('❌ 액세스 토큰 저장 실패: $e');
      return false;
    }
  }

  /// 💾 리프레시 토큰 저장
  static Future<bool> saveRefreshToken(String token) async {
    try {
      if (token.isEmpty) {
        print('❌ 빈 토큰은 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, token);
      print('✅ 리프레시 토큰 저장 성공');
      return true;
    } catch (e) {
      print('❌ 리프레시 토큰 저장 실패: $e');
      return false;
    }
  }

  /// 💾 사용자 타입 저장
  static Future<bool> saveUserType(String userType) async {
    try {
      if (userType.isEmpty) {
        print('❌ 빈 사용자 타입은 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userTypeKey, userType);
      print('✅ 사용자 타입 저장 성공: $userType');
      return true;
    } catch (e) {
      print('❌ 사용자 타입 저장 실패: $e');
      return false;
    }
  }

  /// 💾 사용자 상태 저장
  static Future<bool> saveUserStatus(String status) async {
    try {
      if (status.isEmpty) {
        print('❌ 빈 사용자 상태는 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatusKey, status);
      print('✅ 사용자 상태 저장 성공: $status');
      return true;
    } catch (e) {
      print('❌ 사용자 상태 저장 실패: $e');
      return false;
    }
  }

  /// 💾 사용자 이메일 저장
  static Future<bool> saveUserEmail(String email) async {
    try {
      if (email.isEmpty) {
        print('❌ 빈 이메일은 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userEmailKey, email);
      print('✅ 사용자 이메일 저장 성공: $email');
      return true;
    } catch (e) {
      print('❌ 사용자 이메일 저장 실패: $e');
      return false;
    }
  }

  /// 💾 사용자 ID 저장
  static Future<bool> saveUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        print('❌ 빈 사용자 ID는 저장할 수 없음');
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, userId);
      print('✅ 사용자 ID 저장 성공: $userId');
      return true;
    } catch (e) {
      print('❌ 사용자 ID 저장 실패: $e');
      return false;
    }
  }

  /// 🚪 로그아웃 처리
  static Future<bool> logout() async {
    try {
      print('=== AuthService 로그아웃 시작 ===');

      final prefs = await SharedPreferences.getInstance();

      // 모든 인증 관련 데이터 삭제
      final keys = [
        _accessTokenKey,
        _refreshTokenKey,
        _userTypeKey,
        _userStatusKey,
        _userEmailKey,
        _userIdKey,
      ];

      for (String key in keys) {
        await prefs.remove(key);
      }

      print('✅ AuthService 로그아웃 완료');
      return true;
    } catch (e) {
      print('❌ AuthService 로그아웃 실패: $e');
      return false;
    }
  }

  /// ✅ 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final userStatus = prefs.getString(_userStatusKey);

      bool hasToken = accessToken != null && accessToken.isNotEmpty;
      bool isActive = userStatus == 'ACTIVE' || userStatus == 'VERIFIED';

      print('🔍 로그인 상태 확인: 토큰=$hasToken, 상태=$userStatus, 결과=${hasToken && isActive}');

      return hasToken && isActive;
    } catch (e) {
      print('❌ 로그인 상태 확인 실패: $e');
      return false;
    }
  }

  /// ❓ 회원가입 필요 여부 확인
  static Future<bool> needsSignup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(_accessTokenKey);
      final userStatus = prefs.getString(_userStatusKey);

      bool hasToken = accessToken != null && accessToken.isNotEmpty;
      bool isPending = userStatus == 'PENDING';

      print('🔍 회원가입 필요 확인: 토큰=$hasToken, 상태=$userStatus, 결과=${hasToken && isPending}');

      return hasToken && isPending;
    } catch (e) {
      print('❌ 회원가입 필요 여부 확인 실패: $e');
      return false;
    }
  }

  /// 🔄 사용자 상태를 ACTIVE로 업데이트 (회원가입 완료 후)
  static Future<bool> updateUserStatusToVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatusKey, 'ACTIVE');
      print('✅ 사용자 상태 ACTIVE로 업데이트');
      return true;
    } catch (e) {
      print('❌ 사용자 상태 업데이트 실패: $e');
      return false;
    }
  }

  /// 🔧 강제로 사용자 상태를 ACTIVE로 업데이트 (디버깅용)
  static Future<bool> forceUpdateToVerified() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userStatusKey, 'ACTIVE');
      print('🔧 강제로 사용자 상태 ACTIVE로 업데이트');
      return true;
    } catch (e) {
      print('❌ 강제 상태 업데이트 실패: $e');
      return false;
    }
  }

  /// 🔍 디버깅: 저장된 데이터 확인
  static Future<void> debugStoredData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('=== 저장된 인증 데이터 ===');
      print('Access Token: ${prefs.getString(_accessTokenKey) != null ? "존재" : "없음"}');
      print('Refresh Token: ${prefs.getString(_refreshTokenKey) != null ? "존재" : "없음"}');
      print('User Type: ${prefs.getString(_userTypeKey) ?? "없음"}');
      print('User Status: ${prefs.getString(_userStatusKey) ?? "없음"}');
      print('User Email: ${prefs.getString(_userEmailKey) ?? "없음"}');
      print('User ID: ${prefs.getString(_userIdKey) ?? "없음"}');
      print('========================');
    } catch (e) {
      print('❌ 저장된 데이터 확인 실패: $e');
    }
  }

  /// 🔍 현재 인증 상태 전체 확인 (디버깅용)
  static Future<void> checkFullAuthStatus() async {
    print('=== 🔍 현재 인증 상태 전체 확인 ===');

    // 1. 저장된 데이터 확인
    await debugStoredData();

    // 2. 각 상태 메서드 확인
    final isLoggedIn = await AuthService.isLoggedIn();
    final needsSignup = await AuthService.needsSignup();
    final accessToken = await AuthService.getAccessToken();
    final userStatus = await AuthService.getUserStatus();
    final userType = await AuthService.getUserType();
    final userEmail = await AuthService.getUserEmail();

    print('--- 상태 메서드 결과 ---');
    print('isLoggedIn(): $isLoggedIn');
    print('needsSignup(): $needsSignup');
    print('accessToken 존재: ${accessToken != null}');
    print('userStatus: $userStatus');
    print('userType: $userType');
    print('userEmail: $userEmail');

    // 3. 자동 로그인 조건 확인
    print('--- 자동 로그인 조건 확인 ---');
    print('✅ 토큰 있음: ${accessToken != null}');
    print('✅ 상태 ACTIVE: ${userStatus == 'ACTIVE'}');
    print('✅ 자동 로그인 가능: ${accessToken != null && userStatus == 'ACTIVE'}');

    // 4. 예상 결과
    if (accessToken != null && userStatus == 'ACTIVE') {
      print('🎉 자동 로그인이 되어야 합니다!');
    } else if (accessToken != null && userStatus == 'PENDING') {
      print('📝 회원가입 화면으로 이동해야 합니다');
    } else {
      print('🔑 로그인 화면으로 이동해야 합니다');
    }

    print('================================');
  }

  /// 🔧 강제로 상태를 ACTIVE로 설정 (디버깅용)
  static Future<void> forceSetActiveStatus() async {
    print('=== 🔧 상태를 ACTIVE로 강제 설정 ===');

    final result = await forceUpdateToVerified();
    if (result) {
      print('✅ 상태가 ACTIVE로 설정되었습니다');
      await checkFullAuthStatus();
    } else {
      print('❌ 상태 설정 실패');
    }
  }

  /// 🔑 토큰 유효성 검증
  static Future<bool> validateToken() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        print('❌ 토큰이 없어 검증 불가');
        return false;
      }

      // TODO: 실제 서버 API로 토큰 유효성 검증
      // 예시: GET /auth/validate
      // final response = await http.get(
      //   Uri.parse('${AppConfig.apiBaseUrl}/auth/validate'),
      //   headers: {'Authorization': 'Bearer $accessToken'},
      // );
      // return response.statusCode == 200;

      print('✅ 토큰 검증 성공 (로컬 확인)');
      return true;
    } catch (e) {
      print('❌ 토큰 검증 실패: $e');
      return false;
    }
  }

  /// 🔄 토큰 갱신
  static Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        print('❌ 리프레시 토큰이 없어 갱신 불가');
        return false;
      }

      // TODO: 실제 서버 API로 토큰 갱신
      // 예시: POST /auth/refresh
      // final response = await http.post(
      //   Uri.parse('${AppConfig.apiBaseUrl}/auth/refresh'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'refreshToken': refreshToken}),
      // );
      //
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   await saveAccessToken(data['accessToken']);
      //   return true;
      // }

      print('✅ 토큰 갱신 성공 (임시)');
      return true;
    } catch (e) {
      print('❌ 토큰 갱신 실패: $e');
      return false;
    }
  }

  /// 🗑️ 모든 사용자 데이터 완전 삭제 (회원 탈퇴용)
  static Future<bool> clearAllUserData() async {
    try {
      print('=== 모든 사용자 데이터 삭제 시작 ===');

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // 모든 SharedPreferences 데이터 삭제

      print('✅ 모든 사용자 데이터 삭제 완료');
      return true;
    } catch (e) {
      print('❌ 사용자 데이터 삭제 실패: $e');
      return false;
    }
  }

  /// 📊 사용자 상태 요약 정보 가져오기
  static Future<Map<String, dynamic>> getUserSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return {
        'hasToken': prefs.getString(_accessTokenKey) != null,
        'userType': prefs.getString(_userTypeKey),
        'userStatus': prefs.getString(_userStatusKey),
        'userEmail': prefs.getString(_userEmailKey),
        'userId': prefs.getString(_userIdKey),
        'isLoggedIn': await isLoggedIn(),
        'needsSignup': await needsSignup(),
      };
    } catch (e) {
      print('❌ 사용자 상태 요약 정보 가져오기 실패: $e');
      return {
        'hasToken': false,
        'userType': null,
        'userStatus': null,
        'userEmail': null,
        'userId': null,
        'isLoggedIn': false,
        'needsSignup': false,
      };
    }
  }
}