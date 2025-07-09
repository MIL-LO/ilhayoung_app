// lib/services/job_api_service.dart

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/job_posting_model.dart';
import '../core/constants/app_constants.dart';
import 'auth_service.dart';

class JobApiService {
  static const String _baseUrl = AppConstants.baseUrl;

  /// 채용공고 목록 조회
  static Future<Map<String, dynamic>> getJobPostings({
    int page = 0,
    int size = 20,
    String? location,
    String? category,
    String? search,
    String? salaryMin,
    String? salaryMax,
    String? workPeriod,
    List<String>? workDays,
    String? status = 'ACTIVE',
  }) async {
    try {
      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        if (status != null) 'status': status,
        if (location != null && location != '전체' && location != '제주 전체') 'workLocation': location,
        if (category != null && category != '전체') 'category': category,
        if (search != null && search.isNotEmpty) 'search': search,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (workPeriod != null) 'workPeriod': workPeriod,
      };

      // workDays 파라미터 추가
      if (workDays != null && workDays.isNotEmpty) {
        for (int i = 0; i < workDays.length; i++) {
          queryParams['workDays[$i]'] = workDays[i];
        }
      }

      // URI 생성
      final uri = Uri.parse('$_baseUrl/api/v1/recruits').replace(
        queryParameters: queryParams,
      );

      print('=== 채용공고 목록 조회 API 호출 ===');
      print('URL: $uri');
      print('쿼리 파라미터: $queryParams');

      // 헤더 설정
      final headers = await _getHeaders();

      // API 호출
      final response = await http.get(uri, headers: headers);

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // API 응답 구조 확인
        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // JobPosting 모델로 변환
          final List<JobPosting> jobPostings = [];
          if (data['content'] != null) {
            for (var item in data['content']) {
              try {
                jobPostings.add(JobPosting.fromJson(item));
              } catch (e) {
                print('JobPosting 변환 오류: $e');
                print('문제가 된 데이터: $item');
              }
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
              'hasPrevious': !(data['first'] ?? true),
            },
            'message': '채용공고 목록을 성공적으로 조회했습니다.',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '알 수 없는 오류가 발생했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('채용공고 목록 조회 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 상세 조회
  static Future<Map<String, dynamic>> getJobPostingDetail(String jobId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/recruits/$jobId');
      final headers = await _getHeaders();

      print('=== 채용공고 상세 조회 API 호출 ===');
      print('URL: $uri');

      final response = await http.get(uri, headers: headers);

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final jobPosting = JobPosting.fromJson(jsonResponse['data']);

          return {
            'success': true,
            'data': jobPosting,
            'message': '채용공고 상세 정보를 성공적으로 조회했습니다.',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '알 수 없는 오류가 발생했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('채용공고 상세 조회 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 지원
  static Future<Map<String, dynamic>> applyToJob(String jobId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/v1/recruits/$jobId/apply');
      final headers = await _getHeaders();

      print('=== 채용공고 지원 API 호출 ===');
      print('URL: $uri');

      final response = await http.post(uri, headers: headers);

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '지원이 완료되었습니다.',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원에 실패했습니다.',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다. (${response.statusCode})',
        };
      }
    } catch (e) {
      print('채용공고 지원 API 오류: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 헤더 생성 (인증 토큰 포함)
  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 인증 토큰 추가
    final token = await AuthService.getAccessToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}