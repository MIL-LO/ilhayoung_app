// lib/components/applications/application_status_tabs.dart - 상태 탭 컴포넌트

import 'package:flutter/material.dart';
import '../../models/application_model.dart';

class ApplicationStatusTabs extends StatelessWidget {
  final List<JobApplication> allApplications;
  final Map<ApplicationStatus, int> statusCounts;
  final ApplicationStatus? selectedStatus;
  final Function(ApplicationStatus?) onStatusChanged;

  const ApplicationStatusTabs({
    Key? key,
    required this.allApplications,
    required this.statusCounts,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusTab(null, '전체', allApplications.length, const Color(0xFF00A3A3)),
            ...ApplicationStatus.values.map((status) {
              return _buildStatusTab(
                status,
                status.displayName,
                statusCounts[status] ?? 0,
                status.color,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTab(ApplicationStatus? status, String label, int count, Color color) {
    final isSelected = selectedStatus == status;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onStatusChanged(status),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? color : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}