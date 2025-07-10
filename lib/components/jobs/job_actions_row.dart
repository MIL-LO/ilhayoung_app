// lib/components/jobs/job_actions_row.dart

import 'package:flutter/material.dart';
import '../../models/job_posting_model.dart';
import 'job_action_button.dart';

class JobActionsRow extends StatelessWidget {
  final JobPosting job;
  final VoidCallback? onRefresh;
  final VoidCallback? onViewApplicants;

  const JobActionsRow({
    Key? key,
    required this.job,
    this.onRefresh,
    this.onViewApplicants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 첫 번째 줄: 수정, 삭제 버튼
        Row(
          children: [
            Expanded(
              child: JobActionButton(
                job: job,
                actionType: 'edit',
                onSuccess: onRefresh,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: JobActionButton(
                job: job,
                actionType: 'delete',
                onSuccess: onRefresh,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 두 번째 줄: 상태 변경, 지원자 보기 버튼
        Row(
          children: [
            Expanded(
              child: JobActionButton(
                job: job,
                actionType: 'status',
                onSuccess: onRefresh,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: JobActionButton(
                job: job,
                actionType: 'applicants',
                onTap: onViewApplicants,
              ),
            ),
          ],
        ),
      ],
    );
  }
}