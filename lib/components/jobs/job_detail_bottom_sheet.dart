import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/jeju_job_item.dart';

class JobDetailBottomSheet extends StatelessWidget {
  final JejuJobItem job;

  const JobDetailBottomSheet({
    Key? key,
    required this.job,
  }) : super(key: key);

  // ✅ static 메서드로 정의
  static void show(BuildContext context, JejuJobItem job) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JobDetailBottomSheet(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 스크롤 가능한 콘텐츠
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildJobInfo(),
                      const SizedBox(height: 20),
                      _buildDescription(),
                      const SizedBox(height: 20),
                      if (job.requirements.isNotEmpty || job.benefits.isNotEmpty)
                        _buildRequirementsAndBenefits(),
                      const SizedBox(height: 20),
                      _buildCompanyInfo(),
                      const SizedBox(height: 20),
                      _buildContactInfo(),
                      const SizedBox(height: 100), // 하단 버튼 여백
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (job.isNew) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A3A3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (job.isUrgent) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '급구',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                job.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          job.company,
          style: const TextStyle(
            fontSize: 18,
            color: Color(0xFF00A3A3),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          job.fullAddress,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildJobInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FFFE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00A3A3).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 급여 정보
          Row(
            children: [
              const Icon(Icons.attach_money, color: Color(0xFF00A3A3), size: 20),
              const SizedBox(width: 8),
              const Text(
                '급여',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.salary,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // 근무 정보
          _buildInfoRow(Icons.work_outline, '근무형태', job.workType),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.schedule, '근무시간', job.workSchedule),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.category, '업종', job.category),
          if (job.deadline != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, '마감일',
              '${job.deadline!.month}/${job.deadline!.day} (${_getDaysLeft()}일 남음)'),
          ],
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.description, color: Color(0xFF00A3A3), size: 20),
            SizedBox(width: 8),
            Text(
              '상세 설명',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            job.description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementsAndBenefits() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.requirements.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.checklist, color: Color(0xFF00A3A3), size: 20),
              SizedBox(width: 8),
              Text(
                '지원 자격',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: job.requirements.map((req) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF00A3A3)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        req,
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],

        if (job.requirements.isNotEmpty && job.benefits.isNotEmpty)
          const SizedBox(height: 20),

        if (job.benefits.isNotEmpty) ...[
          const Row(
            children: [
              Icon(Icons.card_giftcard, color: Color(0xFFFF6B35), size: 20),
              SizedBox(width: 8),
              Text(
                '복리후생',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF6B35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.benefits.map((benefit) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3),
                ),
              ),
              child: Text(
                benefit,
                style: const TextStyle(
                  color: Color(0xFFFF6B35),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCompanyInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.business, color: Color(0xFF00A3A3), size: 20),
            SizedBox(width: 8),
            Text(
              '기업 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00A3A3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(Icons.business, '기업명', job.company),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.person, '대표자', job.representativeName),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, '주소', job.fullAddress),

              if (job.companyDescription != null) ...[
                const SizedBox(height: 16),
                const Text(
                  '기업 소개',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A5568),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.companyDescription!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.contact_phone, color: Color(0xFFFF6B35), size: 20),
            SizedBox(width: 8),
            Text(
              '연락처 정보',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF6B35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 전화번호
        GestureDetector(
          onTap: () => _makePhoneCall(job.contactNumber),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF00A3A3).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone, color: Color(0xFF00A3A3), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '전화번호',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        job.contactNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF00A3A3),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.call, color: Color(0xFF00A3A3), size: 16),
              ],
            ),
          ),
        ),

        // 이메일 (있는 경우)
        if (job.email != null) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _sendEmail(job.email!),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '이메일',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          job.email!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.send, color: Colors.grey[600], size: 16),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 20),

        // 지원하기 버튼
        Container(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _applyToJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00A3A3),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '🌊 지원하기',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF4FD1C7)),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getDaysLeft() {
    if (job.deadline == null) return '0';
    final now = DateTime.now();
    final difference = job.deadline!.difference(now).inDays;
    return difference > 0 ? difference.toString() : '0';
  }

  void _applyToJob() {
    // 지원하기 기능 구현
    HapticFeedback.mediumImpact();
    // TODO: 실제 지원 로직 구현
  }

  void _makePhoneCall(String phoneNumber) async {
    // 전화 걸기 기능
    await Clipboard.setData(ClipboardData(text: phoneNumber));
    // TODO: 실제 전화 걸기 기능 구현
  }

  void _sendEmail(String email) async {
    // 이메일 보내기 기능
    await Clipboard.setData(ClipboardData(text: email));
    // TODO: 실제 이메일 보내기 기능 구현
  }
}