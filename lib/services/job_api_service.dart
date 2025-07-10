// lib/services/job_api_service.dart - 정리된 채용공고 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_posting_model.dart';

class JobApiService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 채용공고 목록 조회
  static Future<Map<String, dynamic>> getJobPostings({
    int page = 0,
    int size = 20,
    String? keyword,
    String? location,
    String? workPeriod,
    int? minSalary,
    int? maxSalary,
    String? jobType,
    String sortBy = 'createdAt',
    String sortDirection = 'desc',
  }) async {
    try {
      print('=== 채용공고 목록 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (location != null && location != '제주 전체' && location != '전체') {
        queryParams['location'] = location;
      }
      if (workPeriod != null) {
        queryParams['workPeriod'] = workPeriod;
      }
      if (minSalary != null) {
        queryParams['minSalary'] = minSalary.toString();
      }
      if (maxSalary != null) {
        queryParams['maxSalary'] = maxSalary.toString();
      }
      if (jobType != null && jobType != '전체') {
        queryParams['jobType'] = jobType;
      }

      final uri = Uri.parse('$baseUrl/recruits').replace(queryParameters: queryParams);
      print('API URL: $uri');
      print('쿼리 파라미터: $queryParams');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(uri, headers: headers);

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final content = data['content'] as List;

          // JobPosting 객체 리스트로 변환
          final List<JobPosting> jobPostings = [];
          for (var item in content) {
            try {
              jobPostings.add(JobPosting.fromJson(item));
            } catch (e) {
              print('JobPosting 변환 오류: $e');
              print('문제가 된 데이터: $item');
            }
          }

          return {
            'success': true,
            'data': jobPostings,
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
            'error': jsonResponse['message'] ?? '채용공고를 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 채용공고 목록 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 상세 조회
  static Future<Map<String, dynamic>> getJobDetail(String recruitId) async {
    try {
      print('=== 채용공고 상세 조회 API 호출 ===');
      print('공고 ID: $recruitId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final uri = Uri.parse('$baseUrl/recruits/$recruitId');
      print('API URL: $uri');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      final response = await http.get(uri, headers: headers);

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
      print('❌ 채용공고 상세 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 지원
  static Future<Map<String, dynamic>> applyToJob(String recruitId) async {
    try {
      print('=== 채용공고 지원 API 호출 ===');
      print('공고 ID: $recruitId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/recruits/$recruitId/apply');
      print('API URL: $uri');

      final response = await http.post(
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
            'message': jsonResponse['message'] ?? '지원이 완료되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원에 실패했습니다',
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
      print('❌ 채용공고 지원 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}