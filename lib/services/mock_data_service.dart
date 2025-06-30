import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/jeju_job_item.dart';

class MockDataService {
  static MockDataService? _instance;
  static MockDataService get instance => _instance ??= MockDataService._();
  MockDataService._();

  Map<String, dynamic>? _mockData;

  Future<void> _loadMockData() async {
    if (_mockData != null) return;

    final String jsonString = await rootBundle.loadString('assets/data/mock_jobs.json');
    _mockData = json.decode(jsonString);
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

    return List.generate(count, (index) {
      final companyIndex = index % companies.length;
      final titleIndex = index % jobTitles.length;
      final regionIndex = index % regions.length;
      final salaryIndex = index % salaries.length;
      final workTypeIndex = index % workTypes.length;

      // 태그 생성 (3개씩)
      final selectedTags = <String>[];
      for (int i = 0; i < 3; i++) {
        selectedTags.add(allTags[(index + i) % allTags.length]);
      }

      return JejuJobItem(
        id: index + 1,
        title: '${jobTitles[titleIndex]} 모집',
        company: companies[companyIndex],
        salary: _formatSalary(salaries[salaryIndex]),
        location: regions[regionIndex],
        isUrgent: index % 7 == 0, // 7개마다 급구
        tags: selectedTags,
        workType: workTypes[workTypeIndex],
        postedDate: DateTime.now().subtract(Duration(days: index % 30)),
      );
    });
  }

  String _formatSalary(int salary) {
    return '시급 ${salary.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    )}원';
  }
}

// 사용법:
// final locations = await MockDataService.instance.getLocations();
// final jobs = await MockDataService.instance.generateJobs(count: 50);