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
  });

  factory JejuJobItem.fromJson(Map<String, dynamic> json) {
    return JejuJobItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      company: json['company'] ?? '',
      location: json['location'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      salary: json['salary'] ?? '',
      hourlyWage: json['hourlyWage'] ?? 0,
      workType: json['workType'] ?? '',
      workSchedule: json['workSchedule'] ?? '',
      isUrgent: json['isUrgent'] ?? false,
      isNew: json['isNew'] ?? false,
      category: json['category'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      description: json['description'] ?? '',
      contactNumber: json['contactNumber'] ?? '',
      representativeName: json['representativeName'] ?? '',
      email: json['email'],
      benefits: List<String>.from(json['benefits'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      companyDescription: json['companyDescription'],
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
    };
  }
}