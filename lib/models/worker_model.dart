class Worker {
  final String id;
  final String applicationId; // 지원서 ID와 연결
  final String jobId;
  final String name;
  final String contact;
  final String address;
  final DateTime hiredDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // HIRED, WORKING, COMPLETED, TERMINATED
  final double? hourlyRate;
  final String? workLocation;
  final Map<String, dynamic>? workDetails;

  Worker({
    required this.id,
    required this.applicationId,
    required this.jobId,
    required this.name,
    required this.contact,
    required this.address,
    required this.hiredDate,
    this.startDate,
    this.endDate,
    required this.status,
    this.hourlyRate,
    this.workLocation,
    this.workDetails,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] ?? '',
      applicationId: json['applicationId'] ?? '',
      jobId: json['jobId'] ?? '',
      name: json['name'] ?? '',
      contact: json['contact'] ?? '',
      address: json['address'] ?? '',
      hiredDate: DateTime.parse(json['hiredDate']),
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] ?? 'HIRED',
      hourlyRate: json['hourlyRate']?.toDouble(),
      workLocation: json['workLocation'],
      workDetails: json['workDetails'],
    );
  }

  // 출석 현황 API 데이터로부터 Worker 객체 생성
  factory Worker.fromAttendanceData(Map<String, dynamic> json) {
    return Worker(
      id: json['staffId'] ?? '',
      applicationId: '', // 출석 데이터에는 없음
      jobId: '', // 출석 데이터에는 없음
      name: json['staffName'] ?? '',
      contact: '', // 출석 데이터에는 없음
      address: '', // 출석 데이터에는 없음
      hiredDate: DateTime.now(), // 기본값
      startDate: null,
      endDate: null,
      status: _mapAttendanceStatusToWorkerStatus(json['todayStatus'] ?? 'SCHEDULED'),
      hourlyRate: null, // 출석 데이터에는 없음
      workLocation: json['workLocation'] ?? '',
      workDetails: null,
    );
  }

  // 출석 상태를 근무자 상태로 매핑 (백엔드 WorkStatus enum과 일치)
  static String _mapAttendanceStatusToWorkerStatus(String attendanceStatus) {
    switch (attendanceStatus.toUpperCase()) {
      case 'SCHEDULED': // 예정
        return 'HIRED';
      case 'PRESENT':   // 출근
      case 'LATE':      // 지각
        return 'WORKING';
      case 'COMPLETED': // 완료
        return 'COMPLETED';
      case 'ABSENT':    // 결근
        return 'TERMINATED';
      default:
        return 'HIRED';
    }
  }

  // HIRED 상태인 지원자 데이터로부터 Worker 객체 생성
  factory Worker.fromHiredApplicant(Map<String, dynamic> applicant, Map<String, dynamic> job) {
    return Worker(
      id: applicant['id'] ?? '',
      applicationId: applicant['id'] ?? '',
      jobId: job['id'] ?? '',
      name: applicant['name'] ?? '',
      contact: applicant['contact'] ?? '',
      address: applicant['address'] ?? '',
      hiredDate: DateTime.now(), // 지원서 생성일을 고용일로 사용
      startDate: null, // 스케줄 생성 후 설정
      endDate: null,
      status: 'HIRED', // HIRED 상태로 고정
      hourlyRate: (job['salary'] as num?)?.toDouble(),
      workLocation: job['workLocation'] ?? '',
      workDetails: {
        'jobType': job['jobType'],
        'position': job['position'],
        'companyName': job['companyName'],
      },
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'jobId': jobId,
      'name': name,
      'contact': contact,
      'address': address,
      'hiredDate': hiredDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'hourlyRate': hourlyRate,
      'workLocation': workLocation,
      'workDetails': workDetails,
    };
  }

  Worker copyWith({
    String? id,
    String? applicationId,
    String? jobId,
    String? name,
    String? contact,
    String? address,
    DateTime? hiredDate,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    double? hourlyRate,
    String? workLocation,
    Map<String, dynamic>? workDetails,
  }) {
    return Worker(
      id: id ?? this.id,
      applicationId: applicationId ?? this.applicationId,
      jobId: jobId ?? this.jobId,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      address: address ?? this.address,
      hiredDate: hiredDate ?? this.hiredDate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      workLocation: workLocation ?? this.workLocation,
      workDetails: workDetails ?? this.workDetails,
    );
  }
}