// lib/components/applications/application_card.dart - 지원내역 카드 컴포넌트

import 'package:flutter/material.dart';
import '../../models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback? onActionTap;

  const ApplicationCard({
    Key? key,
    required this.application,
    required this.onTap,
    this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 상태와 날짜
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (application.statusColor ?? Colors.grey).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        application.statusIcon ?? Icons.help_outline,
                        size: 14,
                        color: application.statusColor ?? Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        application.statusText ?? '알 수 없음',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: application.statusColor ?? Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  application.formattedAppliedDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 삭제된 공고인 경우
            if (application.isRecruitDeleted ?? false) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '삭제된 공고입니다',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // 회사명과 직무
            Text(
              application.company,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              application.jobTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: (application.isRecruitDeleted ?? false) ? Colors.grey[500] : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            // 마감일 정보
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: application.isDeadlinePassed
                        ? Colors.red.withOpacity(0.1)
                        : const Color(0xFF00A3A3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    application.isDeadlinePassed
                        ? '마감됨'
                        : 'D-${application.daysUntilDeadline}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: application.isDeadlinePassed
                          ? Colors.red
                          : const Color(0xFF00A3A3),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '마감: ${application.formattedDeadline}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // 액션 버튼 (필요한 경우)
            if (application.hasAction && onActionTap != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onActionTap,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: application.statusColor ?? Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    application.actionText ?? '',
                    style: TextStyle(
                      color: application.statusColor ?? Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}