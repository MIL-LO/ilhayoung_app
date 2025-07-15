// lib/models/application_detail_model.dart - 지원서 상세 정보 모델

class ApplicationDetail {
  final String id;
  final String recruitTitle;
  final String companyName;
  final String status;
  final DateTime appliedAt;
  final DateTime recruitDeadline;

  // 지원자 정보
  final String name;
  final String birthDate;
  final String contact;
  final String address;
  final String experience;
  final int climateScore;

  ApplicationDetail({
    required this.id,
    required this.recruitTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
    required this.recruitDeadline,
    required this.name,
    required this.birthDate,
    required this.contact,
    required this.address,
    required this.experience,
    required this.climateScore,
  });

  factory ApplicationDetail.fromJson(Map<String, dynamic> json) {
    return ApplicationDetail(
      id: json['id']?.toString() ?? '',
      recruitTitle: json['recruitTitle']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      appliedAt: _parseDateTime(json['appliedAt']),
      recruitDeadline: _parseDateTime(json['recruitDeadline']),
      name: json['name']?.toString() ?? '',
      birthDate: json['birthDate']?.toString() ?? '',
      contact: json['contact']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      experience: json['experience']?.toString() ?? '',
      climateScore: json['climateScore']?.toInt() ?? 0,
    );
  }

  static DateTime _parseDateTime(dynamic dateString) {
    if (dateString == null) return DateTime.now();

    try {
      return DateTime.parse(dateString.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  // 포맷팅된 데이터 getter들
  String get formattedAppliedDate {
    return '${appliedAt.year}년 ${appliedAt.month}월 ${appliedAt.day}일';
  }

  String get formattedDeadline {
    return '${recruitDeadline.year}년 ${recruitDeadline.month}월 ${recruitDeadline.day}일';
  }

  String get formattedBirthDate {
    try {
      final date = DateTime.parse(birthDate);
      return '${date.year}년 ${date.month}월 ${date.day}일';
    } catch (e) {
      return birthDate;
    }
  }

  String get formattedContact {
    if (contact.length == 11 && contact.startsWith('010')) {
      return '${contact.substring(0, 3)}-${contact.substring(3, 7)}-${contact.substring(7)}';
    }
    return contact;
  }

  String get statusDisplayText {
    switch (status.toUpperCase()) {
      case 'APPLIED':
        return '대기중';
      case 'INTERVIEW':
        return '면접 요청';
      case 'HIRED':
        return '채용 확정';
      case 'REJECTED':
        return '거절됨';
      default:
        return status;
    }
  }
}