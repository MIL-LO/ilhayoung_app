import 'package:flutter/material.dart';
import '../../../services/worker_management_service.dart';
import '../../../models/worker_model.dart';
import '../../../models/job_posting_model.dart';

class WorkerManagementScreen extends StatefulWidget {
  final JobPosting jobPosting;

  const WorkerManagementScreen({
    Key? key,
    required this.jobPosting,
  }) : super(key: key);

  @override
  State<WorkerManagementScreen> createState() => _WorkerManagementScreenState();
}

class _WorkerManagementScreenState extends State<WorkerManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  List<Worker> _allWorkers = [];
  Map<String, List<Worker>> _workersByStatus = {};
  bool _isLoading = true;

  final List<String> _statusList = ['ALL', 'HIRED', 'WORKING', 'COMPLETED', 'TERMINATED'];
  final Map<String, String> _statusNames = {
    'ALL': '전체',
    'HIRED': '채용완료',
    'WORKING': '근무중',
    'COMPLETED': '근무완료',
    'TERMINATED': '중도종료',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusList.length, vsync: this);
    _loadWorkers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await WorkerManagementService.getJobWorkers(widget.jobPosting.id);

      if (result['success']) {
        final List<Worker> workers = result['data'];

        setState(() {
          _allWorkers = workers;
          _workersByStatus = {
            'ALL': workers,
            'HIRED': workers.where((w) => w.status == 'HIRED').toList(),
            'WORKING': workers.where((w) => w.status == 'WORKING').toList(),
            'COMPLETED': workers.where((w) => w.status == 'COMPLETED').toList(),
            'TERMINATED': workers.where((w) => w.status == 'TERMINATED').toList(),
          };
        });
      } else {
        _showErrorMessage(result['error']);
      }
    } catch (e) {
      _showErrorMessage('네트워크 오류가 발생했습니다: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.jobPosting.title} - 근무자 관리',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              '총 ${_allWorkers.length}명 근무',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2D3748)),
            onPressed: _loadWorkers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D3748)),
        ),
      )
          : Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusList.map((status) {
                final workers = _workersByStatus[status] ?? [];
                return _buildWorkerList(workers);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicator: BoxDecoration(
          color: const Color(0xFF2D3748),
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorPadding: const EdgeInsets.all(4),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF2D3748),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        tabs: _statusList.map((status) {
          final count = _workersByStatus[status]?.length ?? 0;
          return Tab(
            text: '${_statusNames[status]} ($count)',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWorkerList(List<Worker> workers) {
    if (workers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '등록된 근무자가 없습니다',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: workers.length,
      itemBuilder: (context, index) {
        return _buildWorkerCard(workers[index]);
      },
    );
  }

  Widget _buildWorkerCard(Worker worker) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.work,
                  color: Color(0xFF2D3748),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      worker.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      worker.contact,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(worker.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getStatusColor(worker.status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(worker.status),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(worker.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (worker.startDate != null)
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '근무시작: ${_formatDate(worker.startDate!)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                if (worker.endDate != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    '종료: ${_formatDate(worker.endDate!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          if (worker.hourlyRate != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '시급: ${worker.hourlyRate!.toStringAsFixed(0)}원',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showWorkerDetail(worker),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2D3748)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '상세보기',
                    style: TextStyle(color: Color(0xFF2D3748), fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showStatusChangeDialog(worker),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3748),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    '상태변경',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'HIRED':
        return '채용완료';
      case 'WORKING':
        return '근무중';
      case 'COMPLETED':
        return '근무완료';
      case 'TERMINATED':
        return '중도종료';
      default:
        return '알 수 없음';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'HIRED':
        return const Color(0xFF2196F3);
      case 'WORKING':
        return const Color(0xFF4CAF50);
      case 'COMPLETED':
        return const Color(0xFF9C27B0);
      case 'TERMINATED':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  void _showWorkerDetail(Worker worker) {
    // 근무자 상세 정보 모달 구현
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF2D3748),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _getStatusText(worker.status),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // 상세 정보 표시 영역
            const Expanded(
              child: Center(
                child: Text('근무자 상세 정보 구현 예정'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusChangeDialog(Worker worker) {
    // 상태 변경 다이얼로그 구현
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${worker.name}님 상태 변경'),
        content: const Text('상태 변경 기능 구현 예정'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}