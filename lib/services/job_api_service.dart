// lib/services/job_api_service.dart - 내 공고 조회 기능 추가된 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_posting_model.dart';
import '../config/app_config.dart';

class JobApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

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

      // 🔧 내 공고 조회 시에만 토큰 필요, 전체 공고 조회는 토큰 불필요
      if (myJobsOnly) {
        if (accessToken != null) {
          headers['Authorization'] = 'Bearer $accessToken';
        } else {
          return {
            'success': false,
            'error': '로그인이 필요합니다',
          };
        }
      }
      // 전체 공고 조회는 토큰 없이 요청 (백엔드에서 권한 제한 없이 변경됨)

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
          // API 응답 데이터를 더 자세히 분석
          final data = jsonResponse['data'];
          print('=== API 응답 데이터 분석 ===');
          print('전체 데이터: $data');
          print('position: ${data['position']}');
          print('description: ${data['description']}');
          print('companyContact: ${data['companyContact']}');
          print('representativeName: ${data['representativeName']}');
          print('paymentDate: ${data['paymentDate']}');
          print('jobType: ${data['jobType']}');
          print('gender: ${data['gender']}');
          print('================================');
          
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
      } else if (response.statusCode == 404) {
        final jsonResponse = json.decode(response.body);
        final errorCode = jsonResponse['code'];
        
        // 삭제된 공고인지 확인
        if (errorCode == 'RECRUIT_DELETED') {
          return {
            'success': false,
            'error': '삭제된 채용 공고입니다',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '채용공고를 찾을 수 없습니다',
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

  /// 인기/추천 채용공고 조회 (홈 화면용) - 토큰 불필요
  static Future<Map<String, dynamic>> getFeaturedJobs({
    int size = 5,
  }) async {
    try {
      print('=== 인기 채용공고 조회 API 호출 (토큰 불필요) ===');

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

      // 🔧 토큰 없이 요청 (백엔드에서 권한 제한 없이 변경됨)

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

  /// 채용공고 등록 (새로운 방식)
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String workLocation,
    required int salary,
    required String jobType,
    required String position,
    required Map<String, dynamic> workSchedule,
    String? gender,
    required String description,
    List<String>? images,
    required String deadline,
    required String paymentDate,
    required String companyName,
    required String companyAddress,
    required String companyContact,
    required String representativeName,
    required int recruitmentCount,
    required String workStartDate,
    required String workEndDate,
    required int workDurationMonths,
  }) async {
    try {
      print('=== 채용공고 등록 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/recruits');
      print('API URL: $uri');

      final requestData = {
        'title': title,
        'workLocation': workLocation,
        'salary': salary,
        'jobType': jobType,
        'position': position,
        'workSchedule': workSchedule,
        'gender': gender ?? '무관',
        'description': description,
        'images': images ?? [],
        'deadline': deadline,
        'paymentDate': paymentDate,
        'companyName': companyName,
        'companyAddress': companyAddress,
        'companyContact': companyContact,
        'representativeName': representativeName,
        'recruitmentCount': recruitmentCount,
        'workStartDate': workStartDate,
        'workEndDate': workEndDate,
        'workDurationMonths': workDurationMonths,
      };

      print('요청 데이터: $requestData');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '공고가 성공적으로 등록되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '공고 등록에 실패했습니다',
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
      print('❌ 채용공고 등록 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 등록 (기존 방식 - 하위 호환성)
  static Future<Map<String, dynamic>> createJobOld({
    required String title,
    required String description,
    required String position,
    required String salary,
    required String workTime,
    required String location,
    required String contact,
    required List<String> workDays,
  }) async {
    try {
      print('=== 채용공고 등록 API 호출 (기존 방식) ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/recruits');
      print('API URL: $uri');

      // 기존 방식의 데이터 구조
      final requestData = {
        'title': title,
        'description': description,
        'position': position,
        'salary': salary,
        'workTime': workTime,
        'location': location,
        'contact': contact,
        'workDays': workDays,
      };

      print('요청 데이터: $requestData');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '공고가 성공적으로 등록되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '공고 등록에 실패했습니다',
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
      print('❌ 채용공고 등록 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 수정
  static Future<Map<String, dynamic>> updateJob({
    required String recruitId,
    String? title,
    String? workLocation,
    int? salary,
    String? jobType,
    String? position,
    Map<String, dynamic>? workSchedule,
    String? gender,
    String? description,
    List<String>? images,
    String? deadline,
    String? paymentDate,
    String? companyName,
    String? companyAddress,
    String? companyContact,
    String? representativeName,
    int? recruitmentCount,
    String? workStartDate,
    String? workEndDate,
    int? workDurationMonths,
  }) async {
    try {
      print('=== 채용공고 수정 API 호출 ===');
      print('공고 ID: $recruitId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/recruits/$recruitId');
      print('API URL: $uri');

      // null이 아닌 필드만 포함
      final requestData = <String, dynamic>{};
      if (title != null) requestData['title'] = title;
      if (workLocation != null) requestData['workLocation'] = workLocation;
      if (salary != null) requestData['salary'] = salary;
      if (jobType != null) requestData['jobType'] = jobType;
      if (position != null) requestData['position'] = position;
      if (workSchedule != null) requestData['workSchedule'] = workSchedule;
      if (gender != null) requestData['gender'] = gender;
      if (description != null) requestData['description'] = description;
      if (images != null) requestData['images'] = images;
      if (deadline != null) requestData['deadline'] = deadline;
      if (paymentDate != null) requestData['paymentDate'] = paymentDate;
      if (companyName != null) requestData['companyName'] = companyName;
      if (companyAddress != null) requestData['companyAddress'] = companyAddress;
      if (companyContact != null) requestData['companyContact'] = companyContact;
      if (representativeName != null) requestData['representativeName'] = representativeName;
      if (recruitmentCount != null) requestData['recruitmentCount'] = recruitmentCount;
      if (workStartDate != null) requestData['workStartDate'] = workStartDate;
      if (workEndDate != null) requestData['workEndDate'] = workEndDate;
      if (workDurationMonths != null) requestData['workDurationMonths'] = workDurationMonths;

      print('요청 데이터: $requestData');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '공고가 성공적으로 수정되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '공고 수정에 실패했습니다',
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
      print('❌ 채용공고 수정 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

}