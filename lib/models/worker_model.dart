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