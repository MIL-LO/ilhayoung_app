// lib/services/job_api_service.dart - 내 공고 조회 기능 추가된 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_posting_model.dart';

class JobApiService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 채용공고 목록 조회 (전체 공고 + 내 공고)
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
    bool myJobsOnly = false, // 내 공고만 조회할지 여부
  }) async {
    try {
      print('=== 채용공고 목록 조회 API 호출 ===');
      print('내 공고만 조회: $myJobsOnly');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      // 내 공고 조회와 전체 공고 조회 엔드포인트 분기
      String endpoint = myJobsOnly ? '/recruits/my' : '/recruits';

      // 쿼리 파라미터 구성
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      };

      // 내 공고 조회가 아닐 때만 필터 적용
      if (!myJobsOnly) {
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
      }

      final uri = Uri.parse('$baseUrl$endpoint').replace(queryParameters: queryParams);
      print('API URL: $uri');
      print('쿼리 파라미터: $queryParams');

      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }

      // 내 공고 조회 시 토큰 필수 체크
      if (myJobsOnly && accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
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
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
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

      // 사용자 정보 조회 (지원에 필요한 정보)
      final userInfoResult = await _getUserInfoForApplication();
      if (!userInfoResult['success']) {
        return {
          'success': false,
          'error': userInfoResult['error'] ?? '사용자 정보를 불러올 수 없습니다',
        };
      }

      final userInfo = userInfoResult['data'];

      // 지원 데이터 구성
      final applicationData = {
        'name': userInfo['name'] ?? '',
        'birthDate': userInfo['birthDate'] ?? '',
        'contact': userInfo['phone'] ?? '',
        'address': userInfo['address'] ?? '',
        'experience': userInfo['experience'] ?? '',
        'climateScore': userInfo['climateScore'] ?? 85, // 기본값
      };

      final uri = Uri.parse('$baseUrl/recruits/$recruitId/applications');
      print('API URL: $uri');
      print('지원 데이터: $applicationData');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(applicationData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  /// 인기/추천 채용공고 조회 (홈 화면용)
  static Future<Map<String, dynamic>> getFeaturedJobs({
    int size = 5,
  }) async {
    try {
      print('=== 인기 채용공고 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final queryParams = <String, String>{
        'page': '0',
        'size': size.toString(),
        'sortBy': 'applicationCount', // 지원자 수 기준 정렬
        'sortDirection': 'desc',
        'featured': 'true', // 인기 공고 플래그 (API에서 지원하는 경우)
      };

      final uri = Uri.parse('$baseUrl/recruits').replace(queryParameters: queryParams);
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

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS' && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          final content = data['content'] as List;

          final List<JobPosting> jobPostings = [];
          for (var item in content) {
            try {
              jobPostings.add(JobPosting.fromJson(item));
            } catch (e) {
              print('JobPosting 변환 오류: $e');
            }
          }

          return {
            'success': true,
            'data': jobPostings,
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '인기 공고를 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 인기 채용공고 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 지원에 필요한 사용자 정보 조회 (내부 메서드)
  static Future<Map<String, dynamic>> _getUserInfoForApplication() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/users/me');
      print('사용자 정보 조회 API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('사용자 정보 조회 응답 상태: ${response.statusCode}');
      print('사용자 정보 조회 응답 본문: ${response.body}');

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
            'error': jsonResponse['message'] ?? '사용자 정보를 불러올 수 없습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '사용자 정보 조회에 실패했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 사용자 정보 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 공통 헤더 생성 (유틸리티 메서드)
  static Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }
}