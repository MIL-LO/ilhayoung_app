// lib/components/worker_management/common_widgets.dart

import 'package:flutter/material.dart';

class WorkerManagementEmptyState extends StatelessWidget {
  final String type;
  final IconData? icon;
  final String? description;

  const WorkerManagementEmptyState({
    Key? key,
    required this.type,
    this.icon,
    this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? (type == '출근 기록' ? Icons.access_time : Icons.schedule),
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '${type}이 없습니다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description ?? '선택한 날짜에 대한 ${type}이 없습니다',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class WorkerManagementLoadingWidget extends StatelessWidget {
  final String? message;

  const WorkerManagementLoadingWidget({
    Key? key,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
          ),
          const SizedBox(height: 16),
          Text(
            message ?? '데이터를 불러오는 중...',
            style: const TextStyle(fontSize: 16, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    );
  }
}

class WorkerManagementErrorWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const WorkerManagementErrorWidget({
    Key? key,
    required this.errorMessage,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            style: TextStyle(fontSize: 16, color: Colors.red[400]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('다시 시도'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3748),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class SummaryItemWidget extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryItemWidget({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusFilterDropdown extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const StatusFilterDropdown({
    Key? key,
    required this.selectedStatus,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFF2D3748)),
          const SizedBox(width: 8),
          const Text(
            '필터:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<String>(
              value: selectedStatus,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'ALL', child: Text('전체')),
                DropdownMenuItem(value: 'PRESENT', child: Text('출근')),
                DropdownMenuItem(value: 'LATE', child: Text('지각')),
                DropdownMenuItem(value: 'ABSENT', child: Text('결근')),
                DropdownMenuItem(value: 'SCHEDULED', child: Text('예정')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onStatusChanged(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ExpandableFAB extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onScheduleCreation;
  final VoidCallback onHiredWorkers;

  const ExpandableFAB({
    Key? key,
    required this.isExpanded,
    required this.onToggle,
    required this.onScheduleCreation,
    required this.onHiredWorkers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isExpanded ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                heroTag: "schedule_fab",
                onPressed: isExpanded ? onScheduleCreation : null,
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.schedule, size: 20),
                label: const Text('스케줄 생성', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: isExpanded ? 56 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isExpanded ? 1.0 : 0.0,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: FloatingActionButton.extended(
                heroTag: "workers_fab",
                onPressed: isExpanded ? onHiredWorkers : null,
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                icon: const Icon(Icons.people, size: 20),
                label: const Text('고용된 직원', style: TextStyle(fontSize: 14)),
              ),
            ),
          ),
        ),
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: onToggle,
          backgroundColor: const Color(0xFF2D3748),
          foregroundColor: Colors.white,
          child: AnimatedRotation(
            turns: isExpanded ? 0.125 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Icon(isExpanded ? Icons.close : Icons.add),
          ),
        ),
      ],
    );
  }
}

class WorkerManagementTabBar extends StatelessWidget {
  final TabController tabController;

  const WorkerManagementTabBar({
    Key? key,
    required this.tabController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(6),
        ),
        indicatorPadding: const EdgeInsets.all(3),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(
            icon: Icon(Icons.access_time, size: 18),
            text: '출근 관리',
          ),
          Tab(
            icon: Icon(Icons.schedule, size: 18),
            text: '스케줄 관리',
          ),
        ],
      ),
    );
  }
}