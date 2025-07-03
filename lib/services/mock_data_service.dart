import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import '../models/jeju_job_item.dart';

class MockDataService {
  static MockDataService? _instance;
  static MockDataService get instance => _instance ??= MockDataService._();
  MockDataService._();

  Map<String, dynamic>? _mockData;

  Future<void> _loadMockData() async {
    if (_mockData != null) return;

    // assets 파일 없이 직접 기본 데이터 사용
    _mockData = _getDefaultMockData();
  }

  Map<String, dynamic> _getDefaultMockData() {
    return {
      "companies": [
        "제주 오션뷰 카페", "한라산 펜션", "제주감귤농장", "성산일출호텔", "애월해변카페",
        "제주관광농원", "서귀포리조트", "제주흑돼지구이", "한라봉농장", "제주마트",
        "제주돌문화공원", "제주신화월드", "제주유나이티드", "제주도청", "제주은행",
        "제주국제대학교", "제주KAL호텔", "제주롯데호텔", "제주하얏트호텔", "제주파라다이스"
      ],
      "jobTitles": [
        "바리스타", "서빙", "프론트데스크", "하우스키핑", "주방보조",
        "감귤수확", "농장관리", "판매사원", "매장관리", "고객상담",
        "가이드", "리셉션", "마케팅", "사무보조", "배송기사"
      ],
      "regions": [
        "제주시", "서귀포시", "애월읍", "한림읍", "구좌읍", "성산읍", "표선면", "남원읍"
      ],
      "salaries": [10000, 11000, 12000, 13000, 14000, 15000, 16000, 17000, 18000, 20000],
      "workTypes": ["정규직", "아르바이트", "계약직"],
      "tags": [
        "주말근무", "평일근무", "야간근무", "장기근무", "단기근무",
        "4대보험", "퇴직금", "교통비", "식비제공", "숙식제공"
      ],
      "locations": [
        "제주 전체", "제주시", "서귀포시", "애월읍", "한림읍", "구좌읍", "성산읍", "표선면", "남원읍"
      ],
      "categories": [
        "전체", "카페/음료", "음식점", "숙박업", "관광/레저", "농업", "유통/판매", "서비스업"
      ]
    };
  }

  Future<List<String>> getLocations() async {
    await _loadMockData();
    return List<String>.from(_mockData!['locations']);
  }

  Future<List<String>> getCategories() async {
    await _loadMockData();
    return List<String>.from(_mockData!['categories']);
  }

  Future<List<JejuJobItem>> generateJobs({int count = 100}) async {
    await _loadMockData();

    final companies = List<String>.from(_mockData!['companies']);
    final jobTitles = List<String>.from(_mockData!['jobTitles']);
    final regions = List<String>.from(_mockData!['regions']);
    final salaries = List<int>.from(_mockData!['salaries']);
    final workTypes = List<String>.from(_mockData!['workTypes']);
    final allTags = List<String>.from(_mockData!['tags']);
    final categories = List<String>.from(_mockData!['categories']);

    final random = Random();
    final now = DateTime.now();

    // 상세 설명 템플릿
    final descriptions = [
      "성실하고 책임감 있는 분을 모집합니다. 경력 무관이며 친절한 마음가짐이 가장 중요합니다.",
      "제주의 아름다운 환경에서 함께 일하실 분을 찾습니다. 고객 서비스 마인드를 가진 분 우대합니다.",
      "팀워크를 중시하는 직장 분위기에서 함께 성장할 인재를 모집합니다.",
      "제주 지역 특성을 이해하고 장기간 근무 가능한 분을 우대합니다.",
      "신입 환영! 체계적인 교육 시스템으로 전문성을 키워드립니다."
    ];

    final benefits = [
      "4대보험 완비", "퇴직금 지급", "교통비 지원", "식사 제공", "야근수당",
      "연차수당", "명절상여금", "우수사원 포상", "교육비 지원", "건강검진"
    ];

    final requirements = [
      "성실하고 책임감 있는 분", "고객 서비스 마인드 보유자", "원활한 의사소통 능력",
      "제주 지역 거주자 우대", "경력 무관 (신입 가능)", "관련 자격증 우대",
      "장기 근무 가능자", "팀워크 중시하는 분", "적극적인 업무 자세"
    ];

    final companyDescriptions = [
      "제주 지역의 대표적인 관광업체로서 고객 만족을 최우선으로 합니다.",
      "청정 제주의 자연환경을 바탕으로 한 친환경 기업입니다.",
      "지역사회와 함께 성장하는 제주의 든든한 파트너입니다.",
      "제주만의 특색있는 서비스로 고객들에게 사랑받고 있습니다."
    ];

    return List.generate(count, (index) {
      final companyIndex = index % companies.length;
      final titleIndex = index % jobTitles.length;
      final regionIndex = index % regions.length;
      final salaryIndex = index % salaries.length;
      final workTypeIndex = index % workTypes.length;
      final categoryIndex = (index % (categories.length - 1)) + 1; // '전체' 제외

      // 랜덤 태그 선택 (2-4개)
      final selectedTags = <String>[];
      final tagCount = 2 + random.nextInt(3);
      for (int i = 0; i < tagCount; i++) {
        final tag = allTags[(index + i) % allTags.length];
        if (!selectedTags.contains(tag)) {
          selectedTags.add(tag);
        }
      }

      // 랜덤 복리후생 선택 (3-5개)
      final selectedBenefits = <String>[];
      final benefitCount = 3 + random.nextInt(3);
      for (int i = 0; i < benefitCount; i++) {
        final benefit = benefits[(index + i) % benefits.length];
        if (!selectedBenefits.contains(benefit)) {
          selectedBenefits.add(benefit);
        }
      }

      // 랜덤 지원자격 선택 (2-4개)
      final selectedRequirements = <String>[];
      final reqCount = 2 + random.nextInt(3);
      for (int i = 0; i < reqCount; i++) {
        final req = requirements[(index + i) % requirements.length];
        if (!selectedRequirements.contains(req)) {
          selectedRequirements.add(req);
        }
      }

      final postedDaysAgo = index % 30;
      final company = companies[companyIndex];
      final hourlyWage = salaries[salaryIndex];

      return JejuJobItem(
        id: (index + 1).toString(),
        title: '${jobTitles[titleIndex]} 모집',
        company: company,
        location: regions[regionIndex],
        fullAddress: '제주특별자치도 ${regions[regionIndex]} ${_generateAddress(index)}',
        salary: _formatSalary(hourlyWage),
        hourlyWage: hourlyWage,
        workType: workTypes[workTypeIndex],
        workSchedule: _generateWorkSchedule(index),
        isUrgent: index % 7 == 0, // 7개마다 급구
        isNew: index % 10 == 0, // 10개마다 신규
        category: categories[categoryIndex],
        createdAt: now.subtract(Duration(days: postedDaysAgo)),
        deadline: random.nextBool()
            ? now.add(Duration(days: 7 + random.nextInt(14)))
            : null,
        description: descriptions[index % descriptions.length],
        contactNumber: _generatePhoneNumber(index),
        representativeName: _generateRepresentativeName(index),
        email: _generateEmail(company, index),
        benefits: selectedBenefits,
        requirements: selectedRequirements,
        companyDescription: companyDescriptions[index % companyDescriptions.length],
        tags: selectedTags,
        postedDate: now.subtract(Duration(days: postedDaysAgo)),
      );
    });
  }

  String _formatSalary(int salary) {
    return '시급 ₩${salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    )}';
  }

  String _generateWorkSchedule(int index) {
    final schedules = [
      '09:00 - 18:00',
      '10:00 - 19:00',
      '14:00 - 22:00',
      '06:00 - 14:00',
      '22:00 - 06:00',
      '08:00 - 17:00',
      '13:00 - 21:00',
      '07:00 - 16:00',
    ];
    return schedules[index % schedules.length];
  }

  String _generateAddress(int index) {
    final addresses = [
      '연동 1234-5 오션뷰빌딩 1층',
      '중앙동 567-8 한라산타워 2층',
      '노형동 890-12 제주플라자 3층',
      '이도이동 345-67 성산빌딩 1층',
      '삼도이동 789-10 애월센터 2층',
      '용담이동 456-78 서귀포타워 1층',
      '건입동 123-45 관광빌딩 4층',
      '화북동 678-90 펜션단지 내',
    ];
    return addresses[index % addresses.length];
  }

  String _generatePhoneNumber(int index) {
    final prefixes = ['064-720', '064-730', '064-740', '064-750', '064-760'];
    final prefix = prefixes[index % prefixes.length];
    final suffix = (1000 + (index % 9000)).toString();
    return '$prefix-$suffix';
  }

  String _generateRepresentativeName(int index) {
    final lastNames = ['김', '이', '박', '최', '정', '강', '조', '윤', '장', '임'];
    final firstNames = ['민수', '영희', '철수', '영수', '정호', '미영', '은정', '준호', '수진', '동현'];

    final lastName = lastNames[index % lastNames.length];
    final firstName = firstNames[index % firstNames.length];
    return '$lastName$firstName';
  }

  String? _generateEmail(String company, int index) {
    if (index % 3 == 0) return null; // 1/3 확률로 이메일 없음

    final domain = company.replaceAll(' ', '').toLowerCase();
    final domains = ['gmail.com', 'naver.com', 'daum.net', '$domain.co.kr'];
    final selectedDomain = domains[index % domains.length];

    return 'contact${index % 100}@$selectedDomain';
  }
}