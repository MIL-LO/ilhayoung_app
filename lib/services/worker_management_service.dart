import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../config/app_config.dart';
import '../models/worker_model.dart';
import 'auth_service.dart';

class WorkerManagementService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // 승인된 지원자를 근무자로 등록 (스케줄 생성)
  static Future<Map<String, dynamic>> createWorkerSchedule({
    required String applicationId,
    required String jobId,
    required DateTime startDate,
    DateTime? endDate,
    double? hourlyRate,
    String? workLocation,
    Map<String, dynamic>? workDetails,
  }) async {
    try {
      print('=== 근무자 스케줄 생성 API 호출 ===');
      print('지원서 ID: $applicationId');
      print('공고 ID: $jobId');
      print('시작일: ${startDate.toIso8601String()}');
      print('시급: $hourlyRate');

      // 1. 로그인 상태 먼저 확인
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ 로그인 상태가 아님');
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      // 2. 액세스 토큰 가져오기
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('❌ 액세스 토큰 없음');
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      print('✅ 인증 확인 완료');

      // 3. 실제 API 호출 - 스케줄 생성 엔드포인트 사용
      final response = await http.post(
        Uri.parse('$baseUrl/schedules/applications/$applicationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'jobId': jobId,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'hourlyRate': hourlyRate,
          'workLocation': workLocation,
          'workDetails': workDetails,
        }),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData['data'],
          'message': '근무자 스케줄이 성공적으로 생성되었습니다'
        };
      } else if (response.statusCode == 401) {
        print('❌ 인증 실패 (401)');
        return {'success': false, 'error': '인증이 만료되었습니다. 다시 로그인해주세요.', 'errorType': 'AUTH'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '근무자 등록에 실패했습니다'};
      }
    } catch (e) {
      print('❌ 근무자 등록 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 승인된 지원자를 근무자로 등록 (기존 호환성을 위한 wrapper)
  static Future<Map<String, dynamic>> createWorker({
    required String applicationId,
    required String jobId,
    required DateTime startDate,
    DateTime? endDate,
    double? hourlyRate,
    String? workLocation,
    Map<String, dynamic>? workDetails,
  }) async {
    return await createWorkerSchedule(
      applicationId: applicationId,
      jobId: jobId,
      startDate: startDate,
      endDate: endDate,
      hourlyRate: hourlyRate,
      workLocation: workLocation,
      workDetails: workDetails,
    );
  }

  // 전체 근로자 출석 현황 조회 (API 문서 기반)
  static Future<Map<String, dynamic>> getWorkersOverview() async {
    try {
      print('=== 전체 근로자 출석 현황 조회 API 호출 ===');

      // 1. 로그인 상태 먼저 확인
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ 로그인 상태가 아님');
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      // 2. 액세스 토큰 가져오기
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('❌ 액세스 토큰 없음');
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      print('✅ 인증 확인 완료');

      final response = await http.get(
        Uri.parse('$baseUrl/attendances/overview'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];

        if (data == null) {
          print('📋 근무자 데이터가 null - 빈 리스트 반환');
          return {'success': true, 'data': <Worker>[]};
        }

        // WorkerOverviewDto를 Worker 모델로 변환
        final List<Worker> workers = (data['workers'] as List? ?? [])
            .map((item) => Worker.fromAttendanceData(item))
            .toList();

        // 통계 정보와 근무자 목록을 모두 반환
        return {
          'success': true, 
          'data': {
            'totalWorkers': data['totalWorkers'] ?? 0,
            'presentWorkers': data['presentWorkers'] ?? 0,
            'absentWorkers': data['absentWorkers'] ?? 0,
            'lateWorkers': data['lateWorkers'] ?? 0,
            'workers': workers,
          }
        };
      } else if (response.statusCode == 401) {
        print('❌ 인증 실패 (401)');
        return {'success': false, 'error': '인증이 만료되었습니다. 다시 로그인해주세요.', 'errorType': 'AUTH'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '근무자 목록 조회에 실패했습니다'};
      }
    } catch (e) {
      print('❌ 근무자 목록 조회 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 특정 공고의 근무자 목록 조회 (기존 호환성을 위한 wrapper)
  static Future<Map<String, dynamic>> getJobWorkers(String jobId) async {
    // 먼저 출석 현황 API 시도
    final overviewResult = await getWorkersOverview();
    
    // 출석 현황에 데이터가 있으면 반환
    if (overviewResult['success']) {
      final data = overviewResult['data'];
      if (data is Map<String, dynamic> && (data['workers'] as List).isNotEmpty) {
        return overviewResult;
      }
    }
    
    // 출석 현황이 비어있으면 HIRED 상태인 지원자들을 근무자로 표시
    print('📋 출석 현황이 비어있음 - HIRED 지원자들을 근무자로 표시');
    return await _getHiredApplicantsAsWorkers();
  }

  // HIRED 상태인 지원자들을 근무자로 변환
  static Future<Map<String, dynamic>> _getHiredApplicantsAsWorkers() async {
    try {
      print('=== 모든 공고에서 HIRED 직원 조회 시작 ===');
      
      // 1. 내 공고 목록 조회
      final jobsResult = await _getMyJobPostings();
      if (!jobsResult['success']) {
        return jobsResult;
      }
      
      final List<dynamic> myJobs = jobsResult['data'];
      print('📋 총 공고 수: ${myJobs.length}');
      
      List<Worker> allWorkers = [];
      
      // 2. 각 공고별로 HIRED 상태인 지원자 조회
      for (final job in myJobs) {
        try {
          final applicantsResult = await _getJobApplicants(job['id']);
          
          if (applicantsResult['success']) {
            final List<dynamic> applicants = applicantsResult['data'];
            
            // HIRED 상태인 지원자만 필터링
            final hiredApplicants = applicants.where((applicant) => 
              applicant['status'] == 'HIRED'
            ).toList();
            
            // Worker 객체로 변환
            for (final applicant in hiredApplicants) {
              final worker = Worker.fromHiredApplicant(applicant, job);
              allWorkers.add(worker);
            }
            
            print('공고 "${job['title']}": HIRED 지원자 ${hiredApplicants.length}명');
          }
        } catch (e) {
          print('⚠️ 공고 ${job['id']} 지원자 조회 실패: $e');
        }
      }
      
      print('✅ 고용된 직원 수: ${allWorkers.length}');
      
      return {
        'success': true,
        'data': allWorkers,
      };
    } catch (e) {
      print('❌ HIRED 지원자 조회 실패: $e');
      return {
        'success': false,
        'error': '근무자 목록 조회에 실패했습니다: $e',
      };
    }
  }

  // 내 공고 목록 조회 (헬퍼 메서드)
  static Future<Map<String, dynamic>> _getMyJobPostings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/recruits/my?page=0&size=20&sortBy=createdAt&sortDirection=desc'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        final content = data['content'] as List;
        
        return {'success': true, 'data': content};
      } else {
        return {'success': false, 'error': '공고 목록 조회에 실패했습니다'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 공고별 지원자 목록 조회 (헬퍼 메서드)
  static Future<Map<String, dynamic>> _getJobApplicants(String recruitId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/recruits/$recruitId/applications'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'];
        final content = data['content'] as List;
        
        return {'success': true, 'data': content};
      } else {
        return {'success': false, 'error': '지원자 목록 조회에 실패했습니다'};
      }
    } catch (e) {
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 근무자 상태 업데이트
  static Future<Map<String, dynamic>> updateWorkerStatus(
      String workerId,
      String status,
      ) async {
    try {
      print('=== 근무자 상태 업데이트 API 호출 ===');
      print('근무자 ID: $workerId');
      print('새 상태: $status');

      // 1. 로그인 상태 먼저 확인
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ 로그인 상태가 아님');
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      // 2. 액세스 토큰 가져오기
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('❌ 액세스 토큰 없음');
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      print('✅ 인증 확인 완료');

      final response = await http.patch(
        Uri.parse('$baseUrl/workers/$workerId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'status': status}),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'message': '근무자 상태가 변경되었습니다',
          'data': responseData['data']
        };
      } else if (response.statusCode == 401) {
        print('❌ 인증 실패 (401)');
        return {'success': false, 'error': '인증이 만료되었습니다. 다시 로그인해주세요.', 'errorType': 'AUTH'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': '근무자를 찾을 수 없습니다'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '상태 변경에 실패했습니다'};
      }
    } catch (e) {
      print('❌ 근무자 상태 업데이트 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 근무자 스케줄 목록 조회
  static Future<Map<String, dynamic>> getWorkerSchedules(String workerId) async {
    try {
      print('=== 근무자 스케줄 목록 조회 API 호출 ===');
      print('근무자 ID: $workerId');

      // 1. 로그인 상태 먼저 확인
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ 로그인 상태가 아님');
        return {'success': false, 'error': '로그인이 필요합니다', 'errorType': 'AUTH'};
      }

      // 2. 액세스 토큰 가져오기
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('❌ 액세스 토큰 없음');
        return {'success': false, 'error': '인증 토큰이 없습니다', 'errorType': 'AUTH'};
      }

      print('✅ 인증 확인 완료');

      final response = await http.get(
        Uri.parse('$baseUrl/workers/$workerId/schedules'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData['data']
        };
      } else if (response.statusCode == 401) {
        print('❌ 인증 실패 (401)');
        return {'success': false, 'error': '인증이 만료되었습니다. 다시 로그인해주세요.', 'errorType': 'AUTH'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'error': '근무자를 찾을 수 없습니다'};
      } else {
        final error = json.decode(response.body);
        return {'success': false, 'error': error['message'] ?? '스케줄 조회에 실패했습니다'};
      }
    } catch (e) {
      print('❌ 근무자 스케줄 조회 오류: $e');
      return {'success': false, 'error': '네트워크 오류: $e'};
    }
  }

  // 디버깅용: Auth 상태와 함께 근무자 관리 API 체크
  static Future<Map<String, dynamic>> debugCheckAuthAndWorkerAPI() async {
    print('=== 🔧 Auth 상태 및 근무자 관리 API 디버깅 ===');

    // 1. Auth 상태 전체 확인
    await AuthService.checkFullAuthStatus();

    // 2. 테스트 공고로 근무자 목록 조회 테스트
    final testJobId = 'test_job_id';
    final result = await getJobWorkers(testJobId);

    print('근무자 목록 API 호출 결과: ${result['success'] ? "성공" : "실패 - ${result['error']}"}');
    if (result['success']) {
      final workers = result['data'] as List<Worker>;
      print('근무자 수: ${workers.length}');
    }

    print('============================');

    return result;
  }

  static Future<Map<String, dynamic>> updateApplicantStatus(
      String jobId,
      String applicantId,
      String newStatus,
      ) async {
    try {
      print('=== 지원자 상태 변경 ===');
      print('공고 ID: $jobId');
      print('지원자 ID: $applicantId');
      print('새로운 상태: $newStatus');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {'success': false, 'error': '로그인이 필요합니다'};
      }

      final requestBody = {
        'status': newStatus,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/jobs/$jobId/applicants/$applicantId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('요청 본문: $requestBody');
      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '지원자 상태가 변경되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상태 변경에 실패했습니다',
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
          'error': '해당 지원자를 찾을 수 없습니다',
        };
      } else if (response.statusCode == 400) {
        final errorResponse = json.decode(response.body);
        return {
          'success': false,
          'error': errorResponse['message'] ?? '잘못된 요청입니다',
        };
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 지원자 상태 변경 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }
}