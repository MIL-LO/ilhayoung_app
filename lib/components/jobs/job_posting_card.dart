// lib/components/jobs/job_posting_card.dart

import 'package:flutter/material.dart';

class JobPostingCard extends StatelessWidget {
  final JobPosting job;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const JobPostingCard({
    Key? key,
    required this.job,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: job.status == JobStatus.active
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: job.status == JobStatus.active
                      ? Colors.green.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  job.status == JobStatus.active ? '모집중' : '마감',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: job.status == JobStatus.active ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job.location,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                job.workTime,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            job.salary,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildJobStat('지원자', job.applicantCount.toString(), Icons.people),
              const SizedBox(width: 16),
              _buildJobStat('조회수', job.viewCount.toString(), Icons.visibility),
              const Spacer(),
              Row(
                children: [
                  IconButton(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    color: const Color(0xFF2D3748),
                    tooltip: '수정',
                  ),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.red,
                    tooltip: '삭제',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$value $label',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// 공고 모델 클래스
class JobPosting {
  final String id;
  final String title;
  final String company;
  final JobStatus status;
  final String position;
  final String salary;
  final String workTime;
  final String location;
  final int applicantCount;
  final int viewCount;
  final DateTime createdAt;
  final DateTime deadline;

  JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.status,
    required this.position,
    required this.salary,
    required this.workTime,
    required this.location,
    required this.applicantCount,
    required this.viewCount,
    required this.createdAt,
    required this.deadline,
  });
}

enum JobStatus {
  active,
  closed,
}