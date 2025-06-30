import 'package:flutter/material.dart';

// 평가 항목 모델
class EvaluationItem {
  final String id;
  final String title;
  final String description;
  final int maxScore;
  final EvaluationType type;
  int currentScore;

  EvaluationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.maxScore,
    required this.type,
    this.currentScore = 0,
  });

  // 별점으로 변환 (5점 만점)
  double get starRating => (currentScore / maxScore) * 5;

  // 별점에서 점수로 변환
  void setFromStarRating(double stars) {
    currentScore = ((stars / 5) * maxScore).round();
  }
}

enum EvaluationType {
  quantitative, // 정량 항목
  qualitative   // 정성 항목
}

// 근무지 평가 모델
class WorkplaceEvaluation {
  final String id;
  final String workScheduleId;
  final String company;
  final String position;
  final DateTime workDate;
  final List<EvaluationItem> evaluationItems;
  final DateTime evaluatedAt;
  final int totalScore; // 총 100점
  final bool isSubmitted;

  WorkplaceEvaluation({
    required this.id,
    required this.workScheduleId,
    required this.company,
    required this.position,
    required this.workDate,
    required this.evaluationItems,
    required this.evaluatedAt,
    this.isSubmitted = false,
  }) : totalScore = evaluationItems.fold(0, (sum, item) => sum + item.currentScore);

  // 정량 점수 (60점 만점)
  int get quantitativeScore => evaluationItems
      .where((item) => item.type == EvaluationType.quantitative)
      .fold(0, (sum, item) => sum + item.currentScore);

  // 정성 점수 (40점 만점)
  int get qualitativeScore => evaluationItems
      .where((item) => item.type == EvaluationType.qualitative)
      .fold(0, (sum, item) => sum + item.currentScore);

  // 평균 별점 (5점 만점)
  double get averageStarRating => totalScore / 20.0; // 100점을 5점으로 변환

  // 평가 등급
  String get grade {
    if (totalScore >= 90) return 'A+';
    if (totalScore >= 80) return 'A';
    if (totalScore >= 70) return 'B+';
    if (totalScore >= 60) return 'B';
    if (totalScore >= 50) return 'C+';
    if (totalScore >= 40) return 'C';
    return 'D';
  }

  // 등급 색상
  Color get gradeColor {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF4CAF50);
      case 'B+':
      case 'B':
        return const Color(0xFF2196F3);
      case 'C+':
      case 'C':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFF44336);
    }
  }
}

// 오름지수 모델
class StaffRating {
  final String staffId;
  final String staffName;
  final List<WorkplaceEvaluation> evaluations;
  final List<AttendanceRecord> attendanceRecords;
  final DateTime lastUpdated;

  StaffRating({
    required this.staffId,
    required this.staffName,
    required this.evaluations,
    required this.attendanceRecords,
    required this.lastUpdated,
  });

  // 전체 평가 점수 (근무기간에 따라 가중평균)
  double get overallRating {
    if (evaluations.isEmpty) return 0.0;

    double totalWeightedScore = 0;
    double totalWeight = 0;

    for (var evaluation in evaluations) {
      final weight = _getWorkPeriodWeight(evaluation.workDate);
      totalWeightedScore += evaluation.totalScore * weight;
      totalWeight += weight;
    }

    return totalWeight > 0 ? (totalWeightedScore / totalWeight) / 20.0 : 0.0; // 5점 만점으로 변환
  }

  // 근무기간에 따른 가중치 계산
  double _getWorkPeriodWeight(DateTime workDate) {
    final now = DateTime.now();
    final daysDiff = now.difference(workDate).inDays;

    // 최근 근무일수록 높은 가중치
    if (daysDiff <= 30) return 1.0;      // 최근 1개월: 100%
    if (daysDiff <= 90) return 0.8;      // 최근 3개월: 80%
    if (daysDiff <= 180) return 0.6;     // 최근 6개월: 60%
    if (daysDiff <= 365) return 0.4;     // 최근 1년: 40%
    return 0.2;                          // 1년 이상: 20%
  }

  // 출근 성실도 점수 (근태 정보 기반)
  double get attendanceScore {
    if (attendanceRecords.isEmpty) return 5.0;

    final totalRecords = attendanceRecords.length;
    final onTimeRecords = attendanceRecords.where((r) => r.status == AttendanceStatus.onTime).length;
    final lateRecords = attendanceRecords.where((r) => r.status == AttendanceStatus.late).length;
    final absentRecords = attendanceRecords.where((r) => r.status == AttendanceStatus.absent).length;

    // 점수 계산: 정시출근 100%, 지각 70%, 결근 0%
    final score = (onTimeRecords * 1.0 + lateRecords * 0.7 + absentRecords * 0.0) / totalRecords;
    return score * 5.0; // 5점 만점으로 변환
  }

  // 종합 오름지수 (평가점수 70% + 출근성실도 30%)
  double get orumIndex => (overallRating * 0.7) + (attendanceScore * 0.3);

  // 오름지수 색상 (점수에 따라)
  Color get orumColor {
    final index = orumIndex;
    if (index >= 4.5) return const Color(0xFF4CAF50); // 진한 초록
    if (index >= 4.0) return const Color(0xFF8BC34A); // 초록
    if (index >= 3.5) return const Color(0xFFCDDC39); // 연두
    if (index >= 3.0) return const Color(0xFFFFEB3B); // 노랑
    if (index >= 2.5) return const Color(0xFFFF9800); // 주황
    if (index >= 2.0) return const Color(0xFFFF5722); // 빨강-주황
    return const Color(0xFF9E9E9E); // 회색
  }

  // 통계 정보
  Map<String, dynamic> get statistics => {
    'totalEvaluations': evaluations.length,
    'averageScore': overallRating,
    'attendanceRate': attendanceScore / 5.0,
    'recentEvaluations': evaluations.where((e) =>
        DateTime.now().difference(e.workDate).inDays <= 30).length,
  };
}

// 출근 기록 모델
class AttendanceRecord {
  final String id;
  final String workScheduleId;
  final DateTime scheduledTime;
  final DateTime? actualTime;
  final AttendanceStatus status;
  final String? note;

  AttendanceRecord({
    required this.id,
    required this.workScheduleId,
    required this.scheduledTime,
    this.actualTime,
    required this.status,
    this.note,
  });

  // 지각 시간 (분)
  int get lateMinutes {
    if (actualTime == null || status != AttendanceStatus.late) return 0;
    return actualTime!.difference(scheduledTime).inMinutes;
  }
}

enum AttendanceStatus {
  onTime,   // 정시 출근
  late,     // 지각
  absent,   // 결근
}

// 기본 평가 항목들 생성
class EvaluationItemFactory {
  static List<EvaluationItem> createDefaultItems() {
    return [
      // 정량 항목 (60점)
      EvaluationItem(
        id: 'accuracy',
        title: '근무조건의 정확성',
        description: '공고에 기재된 시간/급여/업무 내용 일치 여부',
        maxScore: 25,
        type: EvaluationType.quantitative,
      ),
      EvaluationItem(
        id: 'environment',
        title: '업무환경의 안정성',
        description: '업무공간의 청결, 안전, 기본 편의 제공 여부',
        maxScore: 20,
        type: EvaluationType.quantitative,
      ),
      EvaluationItem(
        id: 'schedule',
        title: '근무일정 준수',
        description: '예고 없는 시간 변경, 중도 취소 발생 여부',
        maxScore: 15,
        type: EvaluationType.quantitative,
      ),

      // 정성 항목 (40점)
      EvaluationItem(
        id: 'communication',
        title: '소통 태도',
        description: '직원에 대한 존중과 배려가 있었는가',
        maxScore: 15,
        type: EvaluationType.qualitative,
      ),
      EvaluationItem(
        id: 'rework',
        title: '재근무 의향',
        description: '다시 함께 일하고 싶은 고용자인가',
        maxScore: 10,
        type: EvaluationType.qualitative,
      ),
      EvaluationItem(
        id: 'payment',
        title: '급여 지급 신뢰도',
        description: '지급 방식이 투명하고 정확했는가',
        maxScore: 15,
        type: EvaluationType.qualitative,
      ),
    ];
  }
}