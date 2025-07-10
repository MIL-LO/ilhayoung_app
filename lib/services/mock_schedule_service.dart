// import 'dart:math';
// import 'package:flutter/material.dart';
// import '../models/work_schedule.dart';
//
// class MockScheduleService {
//   static final MockScheduleService _instance = MockScheduleService._internal();
//   factory MockScheduleService() => _instance;
//   MockScheduleService._internal();
//
//   static MockScheduleService get instance => _instance;
//
//   List<WorkSchedule> generateSchedules({int months = 2}) {
//     final companies = [
//       {'name': '제주 오션뷰 카페', 'color': const Color(0xFF00A3A3)},
//       {'name': '한라산 펜션', 'color': const Color(0xFFFF6B35)},
//       {'name': '제주감귤농장', 'color': const Color(0xFF2196F3)},
//       {'name': '성산일출호텔', 'color': const Color(0xFF9C27B0)},
//       {'name': '애월해변카페', 'color': const Color(0xFF4CAF50)},
//       {'name': '서귀포리조트', 'color': const Color(0xFFE91E63)},
//       {'name': '제주흑돼지구이', 'color': const Color(0xFF795548)},
//       {'name': '한라봉농장', 'color': const Color(0xFFFF9800)},
//     ];
//
//     final positions = [
//       '바리스타', '서빙', '프론트데스크', '하우스키핑',
//       '농장관리', '매장관리', '주방보조', '청소'
//     ];
//
//     final statuses = ['scheduled', 'working', 'completed'];
//     final timeSlots = [
//       ['09:00', '18:00'],
//       ['10:00', '19:00'],
//       ['14:00', '22:00'],
//       ['06:00', '14:00'],
//       ['22:00', '06:00'], // 야간근무
//     ];
//
//     List<WorkSchedule> schedules = [];
//     final random = Random();
//     final now = DateTime.now();
//
//     for (int month = 0; month < months; month++) {
//       final targetMonth = DateTime(now.year, now.month + month, 1);
//       final daysInMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
//
//       for (int day = 1; day <= daysInMonth; day++) {
//         final date = DateTime(targetMonth.year, targetMonth.month, day);
//
//         // 각 날짜마다 랜덤하게 0-4개의 스케줄 생성
//         final schedulesPerDay = random.nextInt(5);
//
//         for (int i = 0; i < schedulesPerDay; i++) {
//           final company = companies[random.nextInt(companies.length)];
//           final timeSlot = timeSlots[random.nextInt(timeSlots.length)];
//           String status;
//
//           // 날짜에 따른 상태 결정
//           if (date.isBefore(now)) {
//             status = 'completed';
//           } else if (date.day == now.day &&
//                      date.month == now.month &&
//                      date.year == now.year) {
//             status = random.nextBool() ? 'working' : 'scheduled';
//           } else {
//             status = 'scheduled';
//           }
//
//           schedules.add(
//             WorkSchedule(
//               id: schedules.length + 1,
//               company: company['name'] as String,
//               position: positions[random.nextInt(positions.length)],
//               date: date,
//               startTime: timeSlot[0],
//               endTime: timeSlot[1],
//               status: status,
//               companyColor: company['color'] as Color,
//               isMyWork: random.nextDouble() < 0.3, // 30% 확률로 내 근무
//             ),
//           );
//         }
//       }
//     }
//
//     // 날짜순 정렬
//     schedules.sort((a, b) => a.date.compareTo(b.date));
//
//     return schedules;
//   }
//
//   // 특정 날짜의 스케줄 가져오기
//   List<WorkSchedule> getSchedulesForDate(List<WorkSchedule> allSchedules, DateTime date) {
//     return allSchedules.whimport 'dart:math';
// // import 'package:flutter/material.dart';
// // import '../models/work_schedule.dart';
// //
// // class MockScheduleService {
// //   static final MockScheduleService _instance = MockScheduleService._internal();
// //   factory MockScheduleService() => _instance;
// //   MockScheduleService._internal();
// //
// //   static MockScheduleService get instance => _instance;
// //
// //   List<WorkSchedule> generateSchedules({int months = 2}) {
// //     final companies = [
// //       {'name': '제주 오션뷰 카페', 'color': const Color(0xFF00A3A3)},
// //       {'name': '한라산 펜션', 'color': const Color(0xFFFF6B35)},
// //       {'name': '제주감귤농장', 'color': const Color(0xFF2196F3)},
// //       {'name': '성산일출호텔', 'color': const Color(0xFF9C27B0)},
// //       {'name': '애월해변카페', 'color': const Color(0xFF4CAF50)},
// //       {'name': '서귀포리조트', 'color': const Color(0xFFE91E63)},
// //       {'name': '제주흑돼지구이', 'color': const Color(0xFF795548)},
// //       {'name': '한라봉농장', 'color': const Color(0xFFFF9800)},
// //     ];
// //
// //     final positions = [
// //       '바리스타', '서빙', '프론트데스크', '하우스키핑',
// //       '농장관리', '매장관리', '주방보조', '청소'
// //     ];
// //
// //     final statuses = ['scheduled', 'working', 'completed'];
// //     final timeSlots = [
// //       ['09:00', '18:00'],
// //       ['10:00', '19:00'],
// //       ['14:00', '22:00'],
// //       ['06:00', '14:00'],
// //       ['22:00', '06:00'], // 야간근무
// //     ];
// //
// //     List<WorkSchedule> schedules = [];
// //     final random = Random();
// //     final now = DateTime.now();
// //
// //     for (int month = 0; month < months; month++) {
// //       final targetMonth = DateTime(now.year, now.month + month, 1);
// //       final daysInMonth = DateTime(targetMonth.year, targetMonth.month + 1, 0).day;
// //
// //       for (int day = 1; day <= daysInMonth; day++) {
// //         final date = DateTime(targetMonth.year, targetMonth.month, day);
// //
// //         // 각 날짜마다 랜덤하게 0-4개의 스케줄 생성
// //         final schedulesPerDay = random.nextInt(5);
// //
// //         for (int i = 0; i < schedulesPerDay; i++) {
// //           final company = companies[random.nextInt(companies.length)];
// //           final timeSlot = timeSlots[random.nextInt(timeSlots.length)];
// //           String status;
// //
// //           // 날짜에 따른 상태 결정
// //           if (date.isBefore(now)) {
// //             status = 'completed';
// //           } else if (date.day == now.day &&
// //                      date.month == now.month &&
// //                      date.year == now.year) {
// //             status = random.nextBool() ? 'working' : 'scheduled';
// //           } else {
// //             status = 'scheduled';
// //           }
// //
// //           schedules.add(
// //             WorkSchedule(
// //               id: schedules.length + 1,
// //               company: company['name'] as String,
// //               position: positions[random.nextInt(positions.length)],
// //               date: date,
// //               startTime: timeSlot[0],
// //               endTime: timeSlot[1],
// //               status: status,
// //               companyColor: company['color'] as Color,
// //               isMyWork: random.nextDouble() < 0.3, // 30% 확률로 내 근무
// //             ),
// //           );
// //         }
// //       }
// //     }
// //
// //     // 날짜순 정렬
// //     schedules.sort((a, b) => a.date.compareTo(b.date));
// //
// //     return schedules;
// //   }
// //
// //   // 특정 날짜의 스케줄 가져오기
// //   List<WorkSchedule> getSchedulesForDate(List<WorkSchedule> allSchedules, DateTime date) {
// //     return allSchedules.where((schedule) =>
// //       schedule.date.year == date.year &&
// //       schedule.date.month == date.month &&
// //       schedule.date.day == date.day
// //     ).toList();
// //   }
// //
// //   // 내 근무만 필터링
// //   List<WorkSchedule> filterMyWork(List<WorkSchedule> schedules, bool showMyWorkOnly) {
// //     if (showMyWorkOnly) {
// //       return schedules.where((schedule) => schedule.isMyWork).toList();
// //     }
// //     return schedules;
// //   }
// //
// //   // 월별 스케줄 가져오기
// //   List<WorkSchedule> getSchedulesForMonth(List<WorkSchedule> allSchedules, DateTime month) {
// //     return allSchedules.where((schedule) =>
// //       schedule.date.year == month.year &&
// //       schedule.date.month == month.month
// //     ).toList();
// //   }
// // }ere((schedule) =>
//       schedule.date.year == date.year &&
//       schedule.date.month == date.month &&
//       schedule.date.day == date.day
//     ).toList();
//   }
//
//   // 내 근무만 필터링
//   List<WorkSchedule> filterMyWork(List<WorkSchedule> schedules, bool showMyWorkOnly) {
//     if (showMyWorkOnly) {
//       return schedules.where((schedule) => schedule.isMyWork).toList();
//     }
//     return schedules;
//   }
//
//   // 월별 스케줄 가져오기
//   List<WorkSchedule> getSchedulesForMonth(List<WorkSchedule> allSchedules, DateTime month) {
//     return allSchedules.where((schedule) =>
//       schedule.date.year == month.year &&
//       schedule.date.month == month.month
//     ).toList();
//   }
// }