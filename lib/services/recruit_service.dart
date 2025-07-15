// lib/services/recruit_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';

class RecruitService {
  
  /// 인기 채용공고 조회
  static Future<Map<String, dynamic>> getFeaturedRecruits({
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('=== 인기 채용공고 조회 API 호출 ===');
      print('요청 파라미터: page=$page, size=$size');

      final url = Uri.parse('${AppConfig.apiBaseUrl}/recruits').replace(
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      print('API URL: $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      final response = await http.get(
        url,
        headers: headers,
      );

      print('응답 상태: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'success': true,
          'data': data['data'] ?? {},
          'message': data['message'] ?? '인기 채용공고 조회 성공',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '인증이 필요합니다.',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '인기 채용공고 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 인기 채용공고 조회 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 카테고리별 채용공고 조회 (keyword 파라미터 사용)
  static Future<Map<String, dynamic>> getRecruitsByCategory({
    required String category,
    int page = 0,
    int size = 10,
  }) async {
    try {
      print('=== 카테고리별 채용공고 조회 API 호출 ===');
      print('카테고리: $category, page=$page, size=$size');

      final url = Uri.parse('${AppConfig.apiBaseUrl}/recruits').replace(
        queryParameters: {
          'keyword': category, // 🔧 keyword 파라미터에 카테고리명 전달
          'page': page.toString(),
          'size': size.toString(),
        },
      );

      print('API URL: $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      // 🔧 토큰 없이 요청 (백엔드에서 권한 제한 없이 변경됨)

      final response = await http.get(
        url,
        headers: headers,
      );

      print('응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'success': true,
          'data': data['data'] ?? {},
          'message': data['message'] ?? '카테고리별 채용공고 조회 성공',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '카테고리별 채용공고 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 카테고리별 채용공고 조회 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 전체 채용공고 조회
  static Future<Map<String, dynamic>> getAllRecruits({
    int page = 0,
    int size = 10,
    String? category,
    String? location,
  }) async {
    try {
      print('=== 전체 채용공고 조회 API 호출 ===');

      String? token;
      try {
        token = await AuthService.getAccessToken();
      } catch (e) {
        print('⚠️ 토큰 없이 요청 진행: $e');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      final url = Uri.parse('${AppConfig.apiBaseUrl}/recruits').replace(
        queryParameters: queryParams,
      );

      print('API URL: $url');

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        url,
        headers: headers,
      );

      print('응답 상태: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        return {
          'success': true,
          'data': data['data'] ?? {},
          'message': data['message'] ?? '전체 채용공고 조회 성공',
        };
      } else {
        final errorData = json.decode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? '전체 채용공고 조회에 실패했습니다.',
        };
      }
    } catch (e) {
      print('❌ 전체 채용공고 조회 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
} 