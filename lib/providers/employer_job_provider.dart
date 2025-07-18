import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/job_posting_model.dart' show JobPosting; // 공통 모델 명시적 import

// 공고 데이터 모델 - 공통 모델 사용
// JobPosting 클래스는 models/job_posting_model.dart에서 import하여 사용

// 공통 모델의 fromJson을 사용하므로 별도 파싱 함수 불필요


// 공고 상태 클래스
class JobState {
  final List<JobPosting> allJobs;
  final List<JobPosting> myJobs;
  final bool isLoading;
  final String? error;
  final int totalElements;

  JobState({
    this.allJobs = const [],
    this.myJobs = const [],
    this.isLoading = false,
    this.error,
    this.totalElements = 0,
  });

  JobState copyWith({
    List<JobPosting>? allJobs,
    List<JobPosting>? myJobs,
    bool? isLoading,
    String? error,
    int? totalElements,
  }) {
    return JobState(
      allJobs: allJobs ?? this.allJobs,
      myJobs: myJobs ?? this.myJobs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

// 필터 상태 클래스
class JobFilter {
  final String location;
  final String category;
  final String searchQuery;

  JobFilter({
    this.location = '제주 전체',
    this.category = '전체',
    this.searchQuery = '',
  });

  JobFilter copyWith({
    String? location,
    String? category,
    String? searchQuery,
  }) {
    return JobFilter(
      location: location ?? this.location,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// API 서비스
class JobApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  // 전체 공고 조회
  static Future<Map<String, dynamic>> getAllJobs({
    int page = 0,
    int size = 20,
    String? keyword,
    String? location,
    String? jobType,
  }) async {
    try {
      print('=== 전체 공고 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (keyword != null && keyword.isNotEmpty) {
        queryParams['keyword'] = keyword;
      }
      if (location != null && location != '제주 전체' && location != '전체') {
        queryParams['location'] = location;
      }
      if (jobType != null && jobType != '전체') {
        queryParams['jobType'] = jobType;
      }

      final uri = Uri.parse('$baseUrl/recruits').replace(queryParameters: queryParams);
      print('전체 공고 API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('전체 공고 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          final data = jsonResponse['data'];
          final List<dynamic> content = data['content'] ?? [];

          final jobs = content.map((item) => JobPosting.fromJson(item)).toList();

          return {
            'jobs': jobs,
            'totalElements': data['totalElements'] ?? 0,
            'totalPages': data['totalPages'] ?? 0,
            'hasNext': !(data['last'] ?? true),
          };
        } else {
          throw Exception(jsonResponse['message'] ?? '데이터를 가져오는데 실패했습니다');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: 서버 오류가 발생했습니다');
      }
    } catch (e) {
      print('전체 공고 조회 오류: $e');
      rethrow;
    }
  }

  // 내 공고 조회
  static Future<Map<String, dynamic>> getMyJobs({
    int page = 0,
    int size = 20,
  }) async {
    try {
      print('=== 내 공고 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }

      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };

      final uri = Uri.parse('$baseUrl/recruits/my').replace(queryParameters: queryParams);
      print('내 공고 API URL: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('내 공고 응답: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          final data = jsonResponse['data'];
          final List<dynamic> content = data['content'] ?? [];

          final jobs = content.map((item) => JobPosting.fromJson(item)).toList();

          return {
            'jobs': jobs,
            'totalElements': data['totalElements'] ?? 0,
            'totalPages': data['totalPages'] ?? 0,
            'hasNext': !(data['last'] ?? true),
          };
        } else {
          throw Exception(jsonResponse['message'] ?? '내 공고를 가져오는데 실패했습니다');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: 서버 오류가 발생했습니다');
      }
    } catch (e) {
      print('내 공고 조회 오류: $e');
      rethrow;
    }
  }

  // 새로운 구조의 공고 등록 (기존 방식 - 임시)
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
      print('=== 공고 등록 API 호출 (기존 방식) ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }

      final requestBody = {
        'title': title,
        'description': description,
        'position': position,
        'salary': salary,
        'workTime': workTime,
        'location': location,
        'contact': contact,
        'workDays': workDays,
      };

      print('공고 등록 데이터: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/recruits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('공고 등록 응답: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': '공고가 성공적으로 등록되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          throw Exception(jsonResponse['message'] ?? '공고 등록에 실패했습니다');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: 서버 오류가 발생했습니다');
      }
    } catch (e) {
      print('공고 등록 오류: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // 새로운 구조의 공고 등록
  static Future<Map<String, dynamic>> createJob({
    required String title,
    required String workLocation,
    required int salary,
    required String jobType,
    required String position,
    required Map<String, dynamic> workSchedule,
    required String gender,
    required String description,
    required List<String> images,
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
      print('=== 새로운 공고 등록 API 호출 ===');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        throw Exception('로그인이 필요합니다');
      }

      final requestBody = {
        'title': title,
        'workLocation': workLocation,
        'salary': salary,
        'jobType': jobType,
        'position': position,
        'workSchedule': workSchedule,
        'gender': gender,
        'description': description,
        'images': images,
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

      print('새로운 공고 등록 데이터: $requestBody');

      final response = await http.post(
        Uri.parse('$baseUrl/recruits'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('새로운 공고 등록 응답: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': '공고가 성공적으로 등록되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          throw Exception(jsonResponse['message'] ?? '공고 등록에 실패했습니다');
        }
      } else {
        final errorBody = response.body;
        print('에러 응답 본문: $errorBody');

        try {
          final errorJson = json.decode(errorBody);
          final errorMessage = errorJson['message'] ?? errorJson['error'] ?? '알 수 없는 오류가 발생했습니다';
          throw Exception('HTTP ${response.statusCode}: $errorMessage');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: 서버 오류가 발생했습니다');
        }
      }
    } catch (e) {
      print('새로운 공고 등록 오류: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

// Provider들
final jobFilterProvider = StateNotifierProvider<JobFilterNotifier, JobFilter>((ref) {
  return JobFilterNotifier();
});

class JobFilterNotifier extends StateNotifier<JobFilter> {
  JobFilterNotifier() : super(JobFilter());

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updateCategory(String category) {
    state = state.copyWith(category: category);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void resetFilters() {
    state = JobFilter();
  }
}

final jobProvider = StateNotifierProvider<JobNotifier, JobState>((ref) {
  return JobNotifier(ref);
});

class JobNotifier extends StateNotifier<JobState> {
  final Ref ref;

  JobNotifier(this.ref) : super(JobState());

  // 전체 공고 로드
  Future<void> loadAllJobs({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final filter = ref.read(jobFilterProvider);

      final result = await JobApiService.getAllJobs(
        keyword: filter.searchQuery.isNotEmpty ? filter.searchQuery : null,
        location: filter.location,
        jobType: filter.category,
      );

      state = state.copyWith(
        allJobs: List<JobPosting>.from(result['jobs']),
        totalElements: result['totalElements'],
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 내 공고 로드
  Future<void> loadMyJobs({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      final result = await JobApiService.getMyJobs();

      state = state.copyWith(
        myJobs: List<JobPosting>.from(result['jobs']),
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // 초기 데이터 로드
  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);

    await Future.wait([
      loadAllJobs(),
      loadMyJobs(),
    ]);
  }

  // 기존 방식의 공고 등록 (임시 - 하위 호환성)
  Future<bool> createJobOld({
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
      final result = await JobApiService.createJobOld(
        title: title,
        description: description,
        position: position,
        salary: salary,
        workTime: workTime,
        location: location,
        contact: contact,
        workDays: workDays,
      );

      if (result['success']) {
        // 공고 등록 후 내 공고 다시 로드
        await loadMyJobs(refresh: true);
        return true;
      } else {
        state = state.copyWith(error: result['error']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // 새로운 방식의 공고 등록
  Future<bool> createJob({
    required String title,
    required String description,
    required String position,
    required String salary,
    required String workTime,
    required String location,
    required String contact,
    required List<String> workDays,
    // 새로운 필드들 (선택적)
    String? workLocation,
    int? salaryAmount,
    String? jobType,
    String? gender,
    String? deadline,
    String? paymentDate,
    String? companyName,
    String? companyAddress,
    String? companyContact,
    String? representativeName,
    String? startTime,
    String? endTime,
    String? workPeriod,
    int? recruitmentCount, // 모집인원 추가
    String? workStartDate, // 근무 시작일 추가
    String? workEndDate, // 근무 종료일 추가
    int? workDurationMonths, // 근무 기간 (개월수) 추가
  }) async {
    try {
      // 새로운 구조로 직접 API 호출
      final result = await JobApiService.createJob(
        title: title,
        workLocation: workLocation ?? location,
        salary: salaryAmount ?? _extractSalaryAmount(salary),
        jobType: jobType ?? position,
        position: position,
        workSchedule: {
          'days': workDays,
          'startTime': startTime ?? _extractStartTime(workTime),
          'endTime': endTime ?? _extractEndTime(workTime),
          'workPeriod': workPeriod ?? 'ONE_TO_THREE',
        },
        gender: gender ?? '무관',
        description: description,
        images: const <String>[],
        deadline: deadline ?? DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        paymentDate: paymentDate ?? '매월 25일',
        companyName: companyName ?? '내 업체',
        companyAddress: companyAddress ?? location,
        companyContact: companyContact ?? contact,
        representativeName: representativeName ?? '대표자',
        recruitmentCount: recruitmentCount ?? 1, // 모집인원 기본값 1
        workStartDate: workStartDate ?? DateTime.now().add(const Duration(days: 7)).toIso8601String().substring(0, 10), // 근무 시작일
        workEndDate: workEndDate ?? DateTime.now().add(const Duration(days: 90)).toIso8601String().substring(0, 10), // 근무 종료일
        workDurationMonths: workDurationMonths ?? 3, // 근무 기간 기본값 3개월
      );

      if (result['success']) {
        // 공고 등록 후 내 공고 다시 로드
        await loadMyJobs(refresh: true);
        return true;
      } else {
        state = state.copyWith(error: result['error']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // 헬퍼 메서드들
  int _extractSalaryAmount(String salary) {
    final regex = RegExp(r'(\d+)');
    final match = regex.firstMatch(salary);
    return int.tryParse(match?.group(1) ?? '0') ?? 0;
  }

  String _extractStartTime(String workTime) {
    final parts = workTime.split(' - ');
    return parts.isNotEmpty ? parts[0].trim() : '09:00';
  }

  String _extractEndTime(String workTime) {
    final parts = workTime.split(' - ');
    return parts.length > 1 ? parts[1].trim() : '18:00';
  }

  // 필터 적용된 전체 공고 가져오기
  List<JobPosting> get filteredAllJobs {
    final filter = ref.read(jobFilterProvider);
    List<JobPosting> jobs = state.allJobs;

    // 검색어 필터
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      jobs = jobs.where((job) =>
      job.title.toLowerCase().contains(query) ||
          job.companyName.toLowerCase().contains(query)
      ).toList();
    }

    // 지역 필터
    if (filter.location != '제주 전체') {
      jobs = jobs.where((job) => job.workLocation.contains(filter.location)).toList();
    }

    // 카테고리 필터
    if (filter.category != '전체') {
      jobs = jobs.where((job) => job.position == filter.category).toList();
    }

    return jobs;
  }
}

// 탭 Provider
final selectedTabProvider = StateProvider<int>((ref) => 0);

// 상수 Provider들
final locationsProvider = Provider<List<String>>((ref) => [
  '제주 전체', '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍', '성산읍', '표선면', '남원읍'
]);