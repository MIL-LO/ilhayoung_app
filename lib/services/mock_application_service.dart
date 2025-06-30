import 'dart:math';
import '../models/application_status.dart';

class MockApplicationService {
  static final MockApplicationService _instance = MockApplicationService._internal();
  factory MockApplicationService() => _instance;
  MockApplicationService._internal();

  static MockApplicationService get instance => _instance;

  List<JobApplication> generateApplications({int count = 15}) {
    final companies = [
      '제주 오션뷰 카페', '한라산 펜션', '제주감귤농장', '성산일출호텔',
      '애월해변카페', '제주관광농원', '서귀포리조트', '제주흑돼지구이',
      '한라봉농장', '제주마트', '올레길펜션', '제주스파', '돌하르방카페'
    ];

    final jobTitles = [
      '바리스타 모집', '서빙 스태프 모집', '프론트데스크 직원 모집',
      '하우스키핑 직원 모집', '주방보조 모집', '감귤수확 알바 모집',
      '농장관리 직원 모집', '판매사원 모집', '매장관리 직원 모집',
      '고객상담 직원 모집', '청소 직원 모집', '배송 기사 모집'
    ];

    final locations = [
      '제주시', '서귀포시', '애월읍', '한림읍', '구좌읍',
      '성산읍', '표선면', '남원읍', '안덕면', '대정읍'
    ];

    final salaries = [
      '시급 10,000원', '시급 12,000원', '시급 14,000원', '시급 16,000원',
      '시급 18,000원', '월급 2,000,000원', '월급 2,500,000원', '월급 3,000,000원'
    ];

    final workTypes = ['아르바이트', '정규직', '계약직', '인턴'];

    final statuses = ApplicationStatus.values;

    final allTags = [
      '주말근무', '평일근무', '4대보험', '퇴직금', '교통비',
      '식사제공', '숙소제공', '야간근무', '주차가능', '신입가능'
    ];

    final random = Random();
    final now = DateTime.now();

    return List.generate(count, (index) {
      final appliedDaysAgo = random.nextInt(30); // 최근 30일 내 지원
      final company = companies[random.nextInt(companies.length)];
      final selectedTags = <String>[];

      // 랜덤하게 2-4개의 태그 선택
      final tagCount = 2 + random.nextInt(3);
      for (int i = 0; i < tagCount; i++) {
        final tag = allTags[random.nextInt(allTags.length)];
        if (!selectedTags.contains(tag)) {
          selectedTags.add(tag);
        }
      }

      return JobApplication(
        id: index + 1,
        jobTitle: jobTitles[random.nextInt(jobTitles.length)],
        company: company,
        location: locations[random.nextInt(locations.length)],
        salary: salaries[random.nextInt(salaries.length)],
        status: statuses[random.nextInt(statuses.length)],
        appliedDate: now.subtract(Duration(days: appliedDaysAgo)),
        workType: workTypes[random.nextInt(workTypes.length)],
        tags: selectedTags,
        isUrgent: random.nextDouble() < 0.2, // 20% 확률로 급구
      );
    });
  }

  // 상태별 필터링
  List<JobApplication> filterByStatus(
    List<JobApplication> applications,
    ApplicationStatus? status
  ) {
    if (status == null) return applications;
    return applications.where((app) => app.status == status).toList();
  }

  // 최근 순 정렬
  List<JobApplication> sortByDate(List<JobApplication> applications) {
    final sorted = List<JobApplication>.from(applications);
    sorted.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    return sorted;
  }

  // 상태별 개수 계산
  Map<ApplicationStatus, int> getStatusCounts(List<JobApplication> applications) {
    final counts = <ApplicationStatus, int>{};
    for (final status in ApplicationStatus.values) {
      counts[status] = applications.where((app) => app.status == status).length;
    }
    return counts;
  }
}