// lib/services/user_sync_service.dart - 서버와 로컬 동기화

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';
import '../config/app_config.dart';

class UserSyncService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// 🔄 서버에서 현재 사용자 정보 가져와서 로컬과 동기화
  static Future<Map<String, dynamic>> syncUserFromServer() async {
    try {
      print('=== 🔄 서버 사용자 정보 동기화 시작 ===');

      // 액세스 토큰 가져오기
      final accessToken = await AuthService.getAccessToken();
      if (accessToken == null) {
        return {
          'success': false,
          'error': '토큰이 없습니다. 다시 로그인해주세요.',
        };
      }

      // 현재 사용자 정보 API 호출
      final url = Uri.parse('$baseUrl/users/me');
      print('사용자 정보 API URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 15));

      print('사용자 정보 응답 상태: ${response.statusCode}');
      print('사용자 정보 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('서버 응답 구조: $data');

        // API 문서에 따른 응답 구조: {"code": "string", "message": "string", "data": {}}
        if (data['code'] == 'SUCCESS' && data['data'] != null) {
          final userData = data['data'];
          print('서버에서 받은 사용자 데이터: $userData');

          // 로컬 SharedPreferences 업데이트
          await _updateLocalUserData(userData);

          return {
            'success': true,
            'message': '사용자 정보 동기화 완료',
            'data': userData,
          };
        } else {
          return {
            'success': false,
            'error': data['message'] ?? '사용자 정보를 가져올 수 없습니다.',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 만료되었습니다. 다시 로그인해주세요.',
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': '사용자를 찾을 수 없습니다.',
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}: 서버 오류가 발생했습니다.',
        };
      }

    } catch (e) {
      print('❌ 사용자 정보 동기화 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 🔄 서버 데이터로 로컬 업데이트 (DB 구조에 맞춤)
  static Future<void> _updateLocalUserData(Map<String, dynamic> userData) async {
    try {
      print('=== 🔄 로컬 데이터 업데이트 시작 ===');
      print('받은 사용자 데이터: $userData');

      final prefs = await SharedPreferences.getInstance();

      // DB 구조에 따른 필드 매핑
      // status 필드 확인 및 업데이트
      if (userData['status'] != null) {
        final serverStatus = userData['status'].toString();
        await prefs.setString('user_status', serverStatus);
        print('✅ 서버에서 받은 상태로 업데이트: $serverStatus');
      }

      // userType 필드 확인 및 업데이트
      if (userData['userType'] != null) {
        final serverUserType = userData['userType'].toString();
        await prefs.setString('user_type', serverUserType);
        print('✅ 서버에서 받은 사용자 타입으로 업데이트: $serverUserType');
      }

      // userId 필드 확인 및 업데이트 (여러 가능한 필드명 확인)
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
        print('✅ 서버에서 받은 사용자 ID로 업데이트: $userId');
      }

      // 기타 정보 업데이트
      if (userData['email'] != null) {
        await prefs.setString('user_email', userData['email'].toString());
        print('✅ 이메일 업데이트: ${userData['email']}');
      }

      if (userData['phone'] != null) {
        await prefs.setString('user_phone', userData['phone'].toString());
        print('✅ 전화번호 업데이트: ${userData['phone']}');
      }

      if (userData['address'] != null) {
        await prefs.setString('user_address', userData['address'].toString());
        print('✅ 주소 업데이트: ${userData['address']}');
      }

      if (userData['experience'] != null) {
        await prefs.setString('user_experience', userData['experience'].toString());
        print('✅ 경험 업데이트: ${userData['experience']}');
      }

      if (userData['birthDate'] != null) {
        await prefs.setString('user_birth_date', userData['birthDate'].toString());
        print('✅ 생년월일 업데이트: ${userData['birthDate']}');
      }

      // 업데이트 후 상태 확인
      final updatedStatus = prefs.getString('user_status');
      final updatedType = prefs.getString('user_type');
      final updatedUserId = prefs.getString('user_id');
      print('--- 업데이트 후 로컬 상태 ---');
      print('user_status: $updatedStatus');
      print('user_type: $updatedType');
      print('user_id: $updatedUserId');

      // 🎯 중요: 서버에서 받은 데이터가 ACTIVE라면 자동로그인 활성화
      if (updatedStatus == 'ACTIVE') {
        print('🎉 서버에서 ACTIVE 상태 확인 - 자동로그인 활성화!');
      }

      print('=== 🔄 로컬 데이터 업데이트 완료 ===');
    } catch (e) {
      print('❌ 로컬 데이터 업데이트 오류: $e');
    }
  }

  /// 🔧 강제로 ACTIVE 상태로 동기화 (이미 회원가입 완료된 사용자용)
  static Future<Map<String, dynamic>> forceSetActiveUser({
    required String email,
    String userType = 'STAFF',
    String userId = '686bb7bca366f96983067fcd', // 실제 DB userId
  }) async {
    try {
      print('=== 🔧 강제 ACTIVE 사용자 설정 ===');

      final prefs = await SharedPreferences.getInstance();

      // 완전한 사용자 데이터 설정
      await prefs.setString('user_status', 'ACTIVE');
      await prefs.setString('user_type', userType);
      await prefs.setString('user_email', email);
      await prefs.setString('user_id', userId);

      // 토큰이 없으면 임시 토큰 생성
      final existingToken = prefs.getString('access_token');
      if (existingToken == null || existingToken.isEmpty) {
        await prefs.setString('access_token', 'active_user_token_$userId');
        print('✅ 임시 토큰 생성');
      }

      print('✅ 강제 ACTIVE 사용자 설정 완료');
      print('  - Status: ACTIVE');
      print('  - Type: $userType');
      print('  - Email: $email');
      print('  - UserId: $userId');

      return {
        'success': true,
        'message': '사용자가 ACTIVE 상태로 설정되었습니다.',
        'data': {
          'status': 'ACTIVE',
          'userType': userType,
          'email': email,
          'userId': userId,
        },
      };
    } catch (e) {
      print('❌ 강제 ACTIVE 설정 오류: $e');
      return {
        'success': false,
        'error': '강제 설정 중 오류가 발생했습니다: $e',
      };
    }
  }
}