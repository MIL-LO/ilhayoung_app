class JejuJobItem {
  final String id;
  final String title;               // 공고명
  final String company;             // 기업명
  final String location;            // 간단 위치 (카드용)
  final String fullAddress;        // 근무지 주소 전체
  final String salary;              // 급여 (간단)
  final int hourlyWage;            // 시급 (숫자)
  final String workType;           // 근무형태
  final String workSchedule;       // 근무시간
  final bool isUrgent;             // 급구 여부
  final bool isNew;                // 신규 여부
  final String category;           // 업종
  final DateTime createdAt;        // 등록일
  final DateTime? deadline;        // 마감일

  // 상세 정보 추가
  final String description;        // 상세 설명
  final String contactNumber;      // 기업 연락처
  final String representativeName; // 대표자 이름
  final String? email;             // 이메일 (선택)
  final List<String> benefits;     // 복리후생
  final List<String> requirements; // 지원 자격
  final String? companyDescription; // 기업 소개

  // 기존 필드들 (호환성을 위해 유지)
  final List<String> tags;         // 태그
  final DateTime postedDate;       // 등록일 (createdAt과 동일)

  JejuJobItem({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.fullAddress,
    required this.salary,
    required this.hourlyWage,
    required this.workType,
    required this.workSchedule,
    required this.isUrgent,
    required this.isNew,
    required this.category,
    required this.createdAt,
    this.deadline,
    required this.description,
    required this.contactNumber,
    required this.representativeName,
    this.email,
    this.benefits = const [],
    this.requirements = const [],
    this.companyDescription,
    this.tags = const [],
    DateTime? postedDate,
  }) : postedDate = postedDate ?? createdAt;

  factory JejuJobItem.fromJson(Map<String, dynamic> json) {
    return JejuJobItem(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      fullAddress: json['fullAddress'] ?? json['location'] ?? '',
      salary: json['salary'] ?? '',
      hourlyWage: json['hourlyWage'] ?? 0,
      workType: json['workType'] ?? '',
      workSchedule: json['workSchedule'] ?? '09:00 - 18:00',
      isUrgent: json['isUrgent'] ?? false,
      isNew: json['isNew'] ?? false,
      category: json['category'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      description: json['description'] ?? '자세한 내용은 연락처로 문의해주세요.',
      contactNumber: json['contactNumber'] ?? '064-000-0000',
      representativeName: json['representativeName'] ?? '담당자',
      email: json['email'],
      benefits: List<String>.from(json['benefits'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      companyDescription: json['companyDescription'],
      tags: List<String>.from(json['tags'] ?? []),
      postedDate: json['postedDate'] != null
          ? DateTime.parse(json['postedDate'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'company': company,
      'location': location,
      'fullAddress': fullAddress,
      'salary': salary,
      'hourlyWage': hourlyWage,
      'workType': workType,
      'workSchedule': workSchedule,
      'isUrgent': isUrgent,
      'isNew': isNew,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'description': description,
      'contactNumber': contactNumber,
      'representativeName': representativeName,
      'email': email,
      'benefits': benefits,
      'requirements': requirements,
      'companyDescription': companyDescription,
      'tags': tags,
      'postedDate': postedDate.toIso8601String(),
    };
  }
}