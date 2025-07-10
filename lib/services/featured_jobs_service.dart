// lib/services/featured_jobs_service.dart - 수정된 인기 채용공고 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_posting_model.dart';

class FeaturedJobsService {
  static const String baseUrl = 'https://api.ilhayoung.com/api/v1';

  /// 인기/추천 채용공고 조회
  static Future<Map<String, dynamic>> getFeaturedJobs({
    int size = 10,
  }) async {
    try {
      print('=== 인기 채용공고 조회 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      final queryParams = <String, String>{
        'size': size.toString(),
      };

      final uri = Uri.parse('$baseUrl/recruits/featured').replace(queryParameters: queryParams);
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
          // 🔧 안전한 데이터 파싱
          final data = jsonResponse['data'];
          List<JobPosting> featuredJobs = [];

          if (data != null) {
            // data가 Map인 경우 (페이지네이션 구조)
            if (data is Map<String, dynamic>) {
              // content 필드가 있는 경우
              if (data.containsKey('content') && data['content'] is List) {
                final List<dynamic> content = data['content'];
                featuredJobs = _parseJobPostings(content);
              }
              // data 자체가 단일 객체인 경우 (배열이 아닌)
              else {
                try {
                  featuredJobs = [JobPosting.fromJson(data)];
                } catch (e) {
                  print('단일 JobPosting 변환 오류: $e');
                }
              }
            }
            // data가 List인 경우 (직접 배열)
            else if (data is List) {
              featuredJobs = _parseJobPostings(data);
            }
          }

          return {
            'success': true,
            'data': featuredJobs,
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '인기 채용공고를 불러오는데 실패했습니다',
          };
        }
      } else if (response.statusCode == 404) {
        // 404인 경우 빈 리스트 반환 (API 엔드포인트가 아직 없을 수 있음)
        print('⚠️ 인기 채용공고 API 엔드포인트가 없습니다. 빈 리스트 반환');
        return {
          'success': true,
          'data': <JobPosting>[], // 빈 리스트
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 인기 채용공고 조회 예외: $e');

      // 🔧 네트워크 오류 시 빈 리스트 반환 (앱이 중단되지 않도록)
      return {
        'success': true,
        'data': <JobPosting>[], // 빈 리스트로 graceful degradation
        'warning': '인기 채용공고를 불러올 수 없습니다',
      };
    }
  }

  /// JobPosting 리스트 안전하게 파싱하는 헬퍼 메서드
  static List<JobPosting> _parseJobPostings(List<dynamic> content) {
    final List<JobPosting> jobs = [];

    for (var item in content) {
      try {
        if (item is Map<String, dynamic>) {
          jobs.add(JobPosting.fromJson(item));
        } else {
          print('⚠️ 잘못된 데이터 타입: $item');
        }
      } catch (e) {
        print('❌ JobPosting 변환 오류: $e');
        print('문제가 된 데이터: $item');
        // 개별 아이템 변환 실패 시 해당 아이템만 건너뛰고 계속 진행
      }
    }

    return jobs;
  }

  /// 🎯 임시 더미 데이터 (API 개발 전 테스트용)
  static Future<Map<String, dynamic>> getFeaturedJobsDemo() async {
    // 개발/테스트용 더미 데이터
    await Future.delayed(const Duration(seconds: 1)); // 네트워크 지연 시뮬레이션

    return {
      'success': true,
      'data': <JobPosting>[], // 실제 JobPosting 객체들을 넣을 수 있음
    };
  }
}