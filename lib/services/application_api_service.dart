// lib/services/application_api_service.dart - 지원내역 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application_model.dart';

class ApplicationApiService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 내 지원내역 조회
  static Future<Map<String, dynamic>> getMyApplications({
    int page = 0,
    int size = 20,
    String? status,
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
  }) async {
    try {
      print('=== 내 지원내역 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/applications/my').replace(queryParameters: queryParams);
      print('API URL: $uri');
      print('쿼리 파라미터: $queryParams');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final content = data['content'] as List;

          // JobApplication 객체 리스트로 변환
          final List<JobApplication> applications = [];
          for (var item in content) {
            try {
              applications.add(JobApplication.fromJson(item));
            } catch (e) {
              print('JobApplication 변환 오류: $e');
              print('문제가 된 데이터: $item');
            }
          }

          return {
            'success': true,
            'data': applications,
            'pagination': {
              'totalElements': data['totalElements'] ?? 0,
              'totalPages': data['totalPages'] ?? 0,
              'currentPage': data['number'] ?? 0,
              'pageSize': data['size'] ?? 0,
              'hasNext': !(data['last'] ?? true),
              'hasPrevious': !(data['first'] ?? false),
            },
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원내역을 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 지원내역 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 지원내역 상세 조회
  static Future<Map<String, dynamic>> getApplicationDetail(String applicationId) async {
    try {
      print('=== 지원내역 상세 조회 API 호출 ===');
      print('지원 ID: $applicationId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/applications/$applicationId');
      print('API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상세 정보를 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 지원내역 상세 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 지원 취소 (수정된 API)
  static Future<Map<String, dynamic>> cancelApplication(String applicationId) async {
    try {
      print('=== 지원 취소 API 호출 ===');
      print('지원 ID: $applicationId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/applications/$applicationId');
      print('API URL: $uri');

      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '지원이 취소되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원 취소에 실패했습니다',
          };
        }
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? '서버 오류가 발생했습니다 (${response.statusCode})';
        } catch (e) {
          errorMessage = '서버 오류가 발생했습니다 (${response.statusCode})';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } catch (e) {
      print('❌ 지원 취소 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}