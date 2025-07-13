// lib/components/applicants/applicant_detail_content.dart

import 'package:flutter/material.dart';
import '../../services/applicant_management_service.dart';
import '../../models/job_posting_model.dart';

class ApplicantDetailContent extends StatelessWidget {
  final ApplicantDetail detail;
  final JobApplicant applicant;
  final JobPosting jobPosting;
  final Function(String) onStatusChanged;

  const ApplicantDetailContent({
    Key? key,
    required this.detail,
    required this.applicant,
    required this.jobPosting,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildContactInfo(),
          const SizedBox(height: 24),
          _buildJobInfo(),
          const SizedBox(height: 24),
          _buildExperienceInfo(),
          const SizedBox(height: 24),
          _buildClimateScoreInfo(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildSection(
      title: '기본 정보',
      icon: Icons.person,
      child: Column(
        children: [
          _buildInfoRow('이름', detail.name.isNotEmpty ? detail.name : '정보 없음'),
          _buildInfoRow('생년월일', detail.birthDate.isNotEmpty ? detail.birthDate : '정보 없음'),
          _buildInfoRow('나이', detail.age > 0 ? '${detail.age}세' : '정보 없음'),
          _buildInfoRow('주소', detail.address.isNotEmpty ? detail.address : '정보 없음'),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return _buildSection(
      title: '연락처 정보',
      icon: Icons.contact_phone,
      child: Column(
        children: [
          _buildInfoRow('전화번호', detail.contact.isNotEmpty ? detail.contact : '정보 없음'),
          _buildInfoRow('지원일', _formatDate(detail.appliedAt)),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
    return _buildSection(
      title: '지원 공고 정보',
      icon: Icons.work,
      child: Column(
        children: [
          _buildInfoRow('공고명', jobPosting.title),
          _buildInfoRow('회사명', jobPosting.companyName),
          _buildInfoRow('근무지', jobPosting.workLocation ?? '정보 없음'),
          _buildInfoRow('급여', jobPosting.salary != null ? '₩${jobPosting.salary}' : '정보 없음'),
        ],
      ),
    );
  }

  Widget _buildExperienceInfo() {
    return _buildSection(
      title: '경력 및 자기소개',
      icon: Icons.history_edu,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text(
          detail.experience.isNotEmpty ? detail.experience : '경력 정보가 없습니다.',
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Color(0xFF2D3748),
          ),
        ),
      ),
    );
  }

  Widget _buildClimateScoreInfo() {
    final score = detail.climateScore;
    Color scoreColor;
    String scoreLevel;

    if (score >= 80) {
      scoreColor = Colors.green;
      scoreLevel = '우수';
    } else if (score >= 60) {
      scoreColor = Colors.orange;
      scoreLevel = '보통';
    } else {
      scoreColor = Colors.red;
      scoreLevel = '미흡';
    }

    return _buildSection(
      title: '제주도 적응 점수',
      icon: Icons.eco,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scoreColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scoreColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '점수: $score점',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '등급: $scoreLevel',
                    style: TextStyle(
                      fontSize: 14,
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                score >= 80 ? Icons.emoji_events :
                score >= 60 ? Icons.thumb_up : Icons.help_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2D3748).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2D3748),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}년 ${date.month}월 ${date.day}일';
  }
}