// lib/components/jobs/job_list_section.dart

import 'package:flutter/material.dart';
import 'job_posting_card.dart';

class JobListSection extends StatelessWidget {
  final String title;
  final List<JobPosting> jobs;
  final Color color;
  final Function(JobPosting) onEdit;
  final Function(JobPosting) onDelete;

  const JobListSection({
    Key? key,
    required this.title,
    required this.jobs,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${jobs.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (jobs.isEmpty)
          _buildEmptyState()
        else
          ...jobs.map((job) => JobPostingCard(
            job: job,
            onEdit: () => onEdit(job),
            onDelete: () => onDelete(job),
          )).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.work_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              '${title.split(' ')[0]}이 없습니다',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}