// lib/screens/employer/salary/salary_management_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../components/common/unified_app_header.dart';

class SalaryManagementScreen extends StatefulWidget {
  const SalaryManagementScreen({Key? key}) : super(key: key);

  @override
  State<SalaryManagementScreen> createState() => _SalaryManagementScreenState();
}

class _SalaryManagementScreenState extends State<SalaryManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  DateTime _selectedMonth = DateTime.now();
  List<EmployeeSalary> _employeeSalaries = [];
  Map<String, int> _monthlySummary = {};

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadSalaryData();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    _fadeController.forward();
  }

  void _loadSalaryData() {
    // 임시 데이터
    _employeeSalaries = [
      EmployeeSalary(
        id: '1',
        employeeName: '김민수',
        position: '바리스타',
        workDays: 22,
        totalHours: 176,
        hourlyWage: 12000,
        baseSalary: 2112000,
        overtime: 48000,
        bonus: 100000,
        deductions: 150000,
        finalSalary: 2110000,
        isPaid: true,
        paidDate: DateTime.now().subtract(const Duration(days: 3)),
      ),
      EmployeeSalary(
        id: '2',
        employeeName: '이영희',
        position: '서빙',
        workDays: 20,
        totalHours: 160,
        hourlyWage: 11000,
        baseSalary: 1760000,
        overtime: 22000,
        bonus: 50000,
        deductions: 120000,
        finalSalary: 1712000,
        isPaid: false,
      ),
      EmployeeSalary(
        id: '3',
        employeeName: '박철수',
        position: '주방보조',
        workDays: 25,
        totalHours: 200,
        hourlyWage: 13000,
        baseSalary: 2600000,
        overtime: 65000,
        bonus: 150000,
        deductions: 180000,
        finalSalary: 2635000,
        isPaid: false,
      ),
      EmployeeSalary(
        id: '4',
        employeeName: '정수진',
        position: '매니저',
        workDays: 26,
        totalHours: 208,
        hourlyWage: 15000,
        baseSalary: 3120000,
        overtime: 120000,
        bonus: 300000,
        deductions: 250000,
        finalSalary: 3290000,
        isPaid: true,
        paidDate: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];

    _calculateMonthlySummary();
    setState(() {});
  }

  void _calculateMonthlySummary() {
    final totalEmployees = _employeeSalaries.length;
    final paidEmployees = _employeeSalaries.where((e) => e.isPaid).length;
    final totalSalary = _employeeSalaries.fold(0, (sum, e) => sum + e.finalSalary);
    final paidSalary = _employeeSalaries.where((e) => e.isPaid).fold(0, (sum, e) => sum + e.finalSalary);
    final unpaidSalary = totalSalary - paidSalary;

    _monthlySummary = {
      'totalEmployees': totalEmployees,
      'paidEmployees': paidEmployees,
      'unpaidEmployees': totalEmployees - paidEmployees,
      'totalSalary': totalSalary,
      'paidSalary': paidSalary,
      'unpaidSalary': unpaidSalary,
    };
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: UnifiedAppHeader(
        title: '급여정산',
        subtitle: '직원 급여를 관리하세요',
        emoji: '💰',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF2D3748), size: 20),
            onPressed: _selectMonth,
            tooltip: '월 선택',
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Color(0xFF2D3748), size: 20),
            onPressed: _exportSalaryData,
            tooltip: '내보내기',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF2D3748),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildMonthSelector(),
                const SizedBox(height: 16),
                _buildSalarySummaryCard(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 16),
                _buildEmployeeList(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Container(
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
      child: Row(
        children: [
          IconButton(
            onPressed: _previousMonth,
            icon: const Icon(Icons.chevron_left, color: Color(0xFF2D3748)),
          ),
          Expanded(
            child: Text(
              '${_selectedMonth.year}년 ${_selectedMonth.month}월',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: const Icon(Icons.chevron_right, color: Color(0xFF2D3748)),
          ),
        ],
      ),
    );
  }

  Widget _buildSalarySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2D3748), Color(0xFF4A5568)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D3748).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                '급여 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '총 직원수',
                  '${_monthlySummary['totalEmployees']}명',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '지급 완료',
                  '${_monthlySummary['paidEmployees']}명',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '총 급여액',
                  _formatCurrency(_monthlySummary['totalSalary']!),
                  Icons.attach_money,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '미지급액',
                  _formatCurrency(_monthlySummary['unpaidSalary']!),
                  Icons.pending,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            '일괄 지급',
            '미지급 급여 일괄 처리',
            Icons.payment,
            const Color(0xFF4CAF50),
            _batchPayment,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            '급여명세서',
            '명세서 생성 및 발송',
            Icons.description,
            const Color(0xFF2196F3),
            _generatePayslips,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title,
      String subtitle,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people, color: Color(0xFF2D3748), size: 20),
            const SizedBox(width: 8),
            const Text(
              '직원별 급여 내역',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const Spacer(),
            Text(
              '총 ${_employeeSalaries.length}명',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._employeeSalaries.map((employee) => _buildEmployeeCard(employee)).toList(),
      ],
    );
  }

  Widget _buildEmployeeCard(EmployeeSalary employee) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: employee.isPaid
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
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
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: employee.isPaid
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    employee.employeeName[0],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: employee.isPaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.employeeName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      employee.position,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: employee.isPaid
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      employee.isPaid ? '지급완료' : '미지급',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: employee.isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                  if (employee.isPaid && employee.paidDate != null)
                    Text(
                      '${employee.paidDate!.month}/${employee.paidDate!.day}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEmployeeStat(
                  '근무일수',
                  '${employee.workDays}일',
                  Icons.calendar_today,
                ),
              ),
              Expanded(
                child: _buildEmployeeStat(
                  '근무시간',
                  '${employee.totalHours}시간',
                  Icons.schedule,
                ),
              ),
              Expanded(
                child: _buildEmployeeStat(
                  '최종급여',
                  _formatCurrency(employee.finalSalary),
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showSalaryDetail(employee),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('상세보기'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: employee.isPaid ? null : () => _paySalary(employee),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: employee.isPaid
                        ? Colors.grey
                        : const Color(0xFF2D3748),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    employee.isPaid ? '지급완료' : '급여지급',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  // 이벤트 핸들러들
  void _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadSalaryData();
    }
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    _loadSalaryData();
  }

  void _nextMonth() {
    if (_selectedMonth.isBefore(DateTime.now())) {
      setState(() {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      });
      _loadSalaryData();
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    _loadSalaryData();
  }

  void _exportSalaryData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('급여 데이터 내보내기 기능 준비 중입니다'),
        backgroundColor: Color(0xFF2D3748),
      ),
    );
  }

  void _batchPayment() {
    final unpaidEmployees = _employeeSalaries.where((e) => !e.isPaid).toList();

    if (unpaidEmployees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('미지급 급여가 없습니다'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('일괄 급여 지급'),
        content: Text('${unpaidEmployees.length}명의 직원에게 급여를 일괄 지급하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                for (var employee in unpaidEmployees) {
                  employee.isPaid = true;
                  employee.paidDate = DateTime.now();
                }
              });
              _calculateMonthlySummary();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${unpaidEmployees.length}명의 급여가 지급되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('지급', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _generatePayslips() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('급여명세서 생성 기능 준비 중입니다'),
        backgroundColor: Color(0xFF2196F3),
      ),
    );
  }

  void _paySalary(EmployeeSalary employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${employee.employeeName} 급여 지급'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('지급액: ${_formatCurrency(employee.finalSalary)}'),
            const SizedBox(height: 8),
            const Text('급여를 지급하시겠습니까?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                employee.isPaid = true;
                employee.paidDate = DateTime.now();
              });
              _calculateMonthlySummary();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${employee.employeeName}님의 급여가 지급되었습니다'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('지급', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSalaryDetail(EmployeeSalary employee) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildSalaryDetailSheet(employee),
    );
  }

  Widget _buildSalaryDetailSheet(EmployeeSalary employee) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: employee.isPaid
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      employee.employeeName[0],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: employee.isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.employeeName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        employee.position,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDetailSection(
                    '근무 정보',
                    [
                      _buildDetailItem('근무일수', '${employee.workDays}일'),
                      _buildDetailItem('총 근무시간', '${employee.totalHours}시간'),
                      _buildDetailItem('시급', _formatCurrency(employee.hourlyWage)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildDetailSection(
                    '급여 계산',
                    [
                      _buildDetailItem('기본급', _formatCurrency(employee.baseSalary)),
                      _buildDetailItem('연장근무수당', _formatCurrency(employee.overtime)),
                      _buildDetailItem('상여금', _formatCurrency(employee.bonus)),
                      _buildDetailItem('공제액', '-${_formatCurrency(employee.deductions)}'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3748).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '최종 지급액',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        Text(
                          _formatCurrency(employee.finalSalary),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '₩${amount.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},'
    )}';
  }
}

// 급여 모델 클래스
class EmployeeSalary {
  final String id;
  final String employeeName;
  final String position;
  final int workDays;
  final int totalHours;
  final int hourlyWage;
  final int baseSalary;
  final int overtime;
  final int bonus;
  final int deductions;
  final int finalSalary;
  bool isPaid;
  DateTime? paidDate;

  EmployeeSalary({
    required this.id,
    required this.employeeName,
    required this.position,
    required this.workDays,
    required this.totalHours,
    required this.hourlyWage,
    required this.baseSalary,
    required this.overtime,
    required this.bonus,
    required this.deductions,
    required this.finalSalary,
    this.isPaid = false,
    this.paidDate,
  });
}