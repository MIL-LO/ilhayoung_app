// lib/services/applicant_management_service.dart - 완전한 지원자 관리 API 서비스

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../config/app_config.dart';

class ApplicantManagementService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  /// 특정 채용공고의 지원자 목록 조회
  static Future<Map<String, dynamic>> getJobApplicants(String recruitId) async {
    try {
      print('=== 채용공고 지원자 목록 조회 API 호출 ===');
      print('공고 ID: $recruitId');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final uri = Uri.parse('$baseUrl/recruits/$recruitId/applications');
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
          dynamic responseData = jsonResponse['data'];
          List<dynamic> applicantsData;

          if (responseData is Map<String, dynamic>) {
            applicantsData = responseData['content'] ?? [];
          } else if (responseData is List) {
            applicantsData = responseData;
          } else {
            applicantsData = [];
          }

          final List<JobApplicant> applicants = applicantsData
              .map((data) => JobApplicant.fromJson(data))
              .toList();

          return {
            'success': true,
            'data': applicants,
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원자 목록을 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 지원자 목록 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 지원서 상세 조회
  static Future<Map<String, dynamic>> getApplicationDetail(String applicationId) async {
    try {
      print('=== 지원서 상세 조회 API 호출 ===');
      print('지원서 ID: $applicationId');

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
            'data': ApplicantDetail.fromJson(jsonResponse['data']),
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '지원서 상세 정보를 불러오는데 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 지원서 상세 조회 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 지원자 상태 변경 (PATCH /api/v1/applications/{applicationId}/status)
  static Future<Map<String, dynamic>> updateApplicationStatus(
      String applicationId,
      String newStatus,
      {String? message}
      ) async {
    try {
      print('=== 지원자 상태 변경 API 호출 ===');
      print('지원서 ID: $applicationId, 새로운 상태: $newStatus');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final requestBody = {
        'status': newStatus,
        if (message != null) 'message': message,
      };

      final uri = Uri.parse('$baseUrl/applications/$applicationId/status');
      print('API URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          // HIRED 상태로 변경된 경우 스케줄 생성 API 호출
          if (newStatus == 'HIRED') {
            print('=== 지원자 승인으로 인한 스케줄 생성 시작 ===');
            final scheduleResult = await _createSchedulesFromApplication(applicationId, accessToken);
            
            if (scheduleResult['success']) {
              print('✅ 스케줄 생성 성공');
              return {
                'success': true,
                'message': '지원자가 승인되었고 스케줄이 생성되었습니다',
                'data': jsonResponse['data'],
                'scheduleCreated': true,
              };
            } else {
              print('⚠️ 스케줄 생성 실패: ${scheduleResult['error']}');
              return {
                'success': true,
                'message': '지원자가 승인되었으나 스케줄 생성에 실패했습니다',
                'data': jsonResponse['data'],
                'scheduleCreated': false,
                'scheduleError': scheduleResult['error'],
              };
            }
          }
          
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '상태가 변경되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상태 변경에 실패했습니다',
          };
        }
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

  /// 지원서 승인 시 스케줄 자동 생성 (POST /api/v1/schedules/applications/{applicationId})
  static Future<Map<String, dynamic>> _createSchedulesFromApplication(
      String applicationId,
      String accessToken) async {
    try {
      print('=== 스케줄 생성 API 호출 ===');
      print('지원서 ID: $applicationId');

      final uri = Uri.parse('$baseUrl/schedules/applications/$applicationId');
      print('API URL: $uri');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      print('스케줄 생성 응답 상태 코드: ${response.statusCode}');
      print('스케줄 생성 응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '스케줄이 생성되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '스케줄 생성에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '스케줄 생성 서버 오류 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 스케줄 생성 예외: $e');
      return {
        'success': false,
        'error': '스케줄 생성 네트워크 오류: $e',
      };
    }
  }

  /// 채용공고 삭제 (DELETE /api/v1/recruits/{recruitId})
  static Future<Map<String, dynamic>> deleteJobPosting(String recruitId) async {
    try {
      print('=== 채용공고 삭제 API 호출 ===');
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
            'message': jsonResponse['message'] ?? '채용공고가 삭제되었습니다',
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '채용공고 삭제에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 채용공고 삭제 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 상태 변경 (PATCH /api/v1/recruits/{recruitId}/status)
  static Future<Map<String, dynamic>> updateJobPostingStatus(
      String recruitId,
      String newStatus,
      ) async {
    try {
      print('=== 채용공고 상태 변경 API 호출 ===');
      print('공고 ID: $recruitId, 새로운 상태: $newStatus');

      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        return {
          'success': false,
          'error': '로그인이 필요합니다',
        };
      }

      final requestBody = {
        'status': newStatus,
      };

      final uri = Uri.parse('$baseUrl/recruits/$recruitId/status');
      print('API URL: $uri');
      print('Request Body: $requestBody');

      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(requestBody),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '공고 상태가 변경되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '상태 변경에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
        };
      }
    } catch (e) {
      print('❌ 채용공고 상태 변경 예외: $e');
      return {
        'success': false,
        'error': '네트워크 오류가 발생했습니다: $e',
      };
    }
  }

  /// 채용공고 수정 (PUT /api/v1/recruits/{recruitId})
  static Future<Map<String, dynamic>> updateJobPosting(
      String recruitId,
      Map<String, dynamic> jobData,
      ) async {
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
      print('Request Body: $jobData');

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(jobData),
      );

      print('응답 상태 코드: ${response.statusCode}');
      print('응답 본문: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        if (jsonResponse['code'] == 'SUCCESS') {
          return {
            'success': true,
            'message': jsonResponse['message'] ?? '채용공고가 수정되었습니다',
            'data': jsonResponse['data'],
          };
        } else {
          return {
            'success': false,
            'error': jsonResponse['message'] ?? '채용공고 수정에 실패했습니다',
          };
        }
      } else {
        return {
          'success': false,
          'error': '서버 오류가 발생했습니다 (${response.statusCode})',
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

/// 지원자 정보 모델
class JobApplicant {
  final String id;
  final String name;
  final String contact;
  final String status;
  final DateTime appliedAt;
  final int climateScore;

  JobApplicant({
    required this.id,
    required this.name,
    required this.contact,
    required this.status,
    required this.appliedAt,
    required this.climateScore,
  });

  factory JobApplicant.fromJson(Map<String, dynamic> json) {
    String status = json['status']?.toString() ?? 'APPLIED';

    // API에서 오는 상태값을 그대로 사용 (백엔드와 일치)
    switch (status.toUpperCase()) {
      case 'APPROVED':
        status = 'HIRED';
        break;
      // 나머지는 그대로 사용
    }

    return JobApplicant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      status: status,
      appliedAt: DateTime.tryParse(json['appliedAt']?.toString() ?? '') ?? DateTime.now(),
      climateScore: json['climateScore']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
      'climateScore': climateScore,
    };
  }

  // copyWith 메소드 추가
  JobApplicant copyWith({
    String? id,
    String? name,
    String? contact,
    String? status,
    DateTime? appliedAt,
    int? climateScore,
  }) {
    return JobApplicant(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      climateScore: climateScore ?? this.climateScore,
    );
  }

  String get statusText {
    switch (status) {
      case 'APPLIED': return '대기중';
      case 'INTERVIEW': return '면접 요청';
      case 'HIRED': return '채용 확정';
      case 'REJECTED': return '거절';
      default: return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'APPLIED': return const Color(0xFF2196F3);
      case 'INTERVIEW': return const Color(0xFF9C27B0);
      case 'HIRED': return const Color(0xFF4CAF50);
      case 'REJECTED': return const Color(0xFFF44336);
      default: return const Color(0xFF757575);
    }
  }

  int get daysSinceApplied {
    return DateTime.now().difference(appliedAt).inDays;
  }
}

/// 지원서 상세 정보 모델
class ApplicantDetail {
  final String id;
  final String name;
  final String birthDate;
  final String contact;
  final String address;
  final String experience;
  final int climateScore;
  final String status;
  final DateTime appliedAt;

  ApplicantDetail({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.contact,
    required this.address,
    required this.experience,
    required this.climateScore,
    required this.status,
    required this.appliedAt,
  });

  factory ApplicantDetail.fromJson(Map<String, dynamic> json) {
    return ApplicantDetail(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      birthDate: json['birthDate']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      climateScore: json['climateScore']?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      appliedAt: DateTime.tryParse(json['appliedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'contact': contact,
      'address': address,
      'experience': experience,
      'climateScore': climateScore,
      'status': status,
      'appliedAt': appliedAt.toIso8601String(),
    };
  }

  int get age {
    try {
      final birth = DateTime.parse(birthDate);
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month ||
          (today.month == birth.month && today.day < birth.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }
}