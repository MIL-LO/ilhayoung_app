import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/evaluation_models.dart';
import '../../components/common/unified_app_header.dart';

class WorkplaceEvaluationScreen extends StatefulWidget {
  final String workScheduleId;
  final String company;
  final String position;
  final DateTime workDate;

  const WorkplaceEvaluationScreen({
    Key? key,
    required this.workScheduleId,
    required this.company,
    required this.position,
    required this.workDate,
  }) : super(key: key);

  @override
  State<WorkplaceEvaluationScreen> createState() => _WorkplaceEvaluationScreenState();
}

class _WorkplaceEvaluationScreenState extends State<WorkplaceEvaluationScreen>
    with TickerProviderStateMixin {

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  List<EvaluationItem> _evaluationItems = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadEvaluationItems();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
  }

  void _loadEvaluationItems() {
    setState(() {
      _evaluationItems = EvaluationItemFactory.createDefaultItems();
    });
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
        title: '근무지 평가',
        subtitle: '${widget.company} - ${widget.position}',
        emoji: '⭐',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00A3A3)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // 근무 정보 카드
            _buildWorkInfoCard(),

            // 평가 설명
            _buildEvaluationGuide(),

            // 평가 항목들
            Expanded(
              child: _buildEvaluationItems(),
            ),
          ],
        ),
      ),
      bottomSheet: _buildSubmitButton(),
    );
  }

  Widget _buildWorkInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A3A3), Color(0xFF00D4AA)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00A3A3).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.work,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.company,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      widget.position,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '${widget.workDate.year}년 ${widget.workDate.month}월 ${widget.workDate.day}일',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationGuide() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00A3A3), size: 20),
              SizedBox(width: 8),
              Text(
                '평가 안내',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A3A3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '근무 완료 후 고용주를 평가해주세요. 평가는 익명으로 진행되며, 다른 구직자들에게 도움이 됩니다.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Color(0xFF00A3A3), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '총 100점 (정량 60점 + 정성 40점)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationItems() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 정량 항목
          _buildSectionHeader('정량 항목', '60점', const Color(0xFF00A3A3)),
          ..._evaluationItems
              .where((item) => item.type == EvaluationType.quantitative)
              .map((item) => _buildEvaluationCard(item))
              .toList(),

          const SizedBox(height: 20),

          // 정성 항목
          _buildSectionHeader('정성 항목', '40점', const Color(0xFFFF6B35)),
          ..._evaluationItems
              .where((item) => item.type == EvaluationType.qualitative)
              .map((item) => _buildEvaluationCard(item))
              .toList(),

          const SizedBox(height: 100), // 하단 버튼 여백
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String maxScore, Color color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.category, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Text(
            maxScore,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationCard(EvaluationItem item) {
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
          // 제목과 점수
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(item.currentScore, item.maxScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.currentScore}/${item.maxScore}점',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(item.currentScore, item.maxScore),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // 설명
          Text(
            item.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // 별점 평가
          Row(
            children: [
              const Text(
                '평가: ',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () => _updateRating(item, index + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          index < item.starRating
                              ? Icons.star
                              : Icons.star_border,
                          color: const Color(0xFFFFD700),
                          size: 28,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Text(
                _getRatingText(item.starRating),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final totalScore = _evaluationItems.fold(0, (sum, item) => sum + item.currentScore);
    final isComplete = _evaluationItems.every((item) => item.currentScore > 0);

    return Container(
      height: 110, // 높이를 100에서 110으로 더 증가
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // 총점 표시 - 훨씬 더 크게 확대
          Container(
            width: 100, // 너비를 90에서 100으로 더 증가
            height: 78, // 명시적 높이 설정
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // 패딩 더 증가
            decoration: BoxDecoration(
              color: const Color(0xFF00A3A3).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00A3A3).withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '총점',
                  style: TextStyle(
                    fontSize: 13, // 라벨 폰트 크기 증가
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6), // 간격 더 증가
                Text(
                  '$totalScore',
                  style: const TextStyle(
                    fontSize: 24, // 점수 폰트를 20에서 24로 크게 증가
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00A3A3),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 12, // /100 폰트 크기도 증가
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 제출 버튼
          Expanded(
            child: Container(
              height: 78, // 버튼도 명시적 높이 설정
              child: ElevatedButton(
                onPressed: isComplete && !_isSubmitting ? _submitEvaluation : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isComplete ? const Color(0xFF00A3A3) : Colors.grey,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 0), // 패딩을 0으로 설정
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isComplete ? '평가 제출하기' : '모든 항목을 평가해주세요',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 이벤트 핸들러들
  void _updateRating(EvaluationItem item, int stars) {
    setState(() {
      item.setFromStarRating(stars.toDouble());
    });

    HapticFeedback.lightImpact();
  }

  void _submitEvaluation() async {
    setState(() {
      _isSubmitting = true;
    });

    // 평가 제출 시뮬레이션
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // 평가 생성
      final evaluation = WorkplaceEvaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        workScheduleId: widget.workScheduleId,
        company: widget.company,
        position: widget.position,
        workDate: widget.workDate,
        evaluationItems: List.from(_evaluationItems),
        evaluatedAt: DateTime.now(),
        isSubmitted: true,
      );

      // 성공 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '평가가 제출되었습니다! 🎉',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '총 ${evaluation.totalScore}점 (${evaluation.grade}등급)',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00A3A3),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 화면 닫기
      Navigator.pop(context, evaluation);
    }
  }

  // Helper 메서드들
  Color _getScoreColor(int current, int max) {
    final ratio = current / max;
    if (ratio >= 0.8) return const Color(0xFF4CAF50);
    if (ratio >= 0.6) return const Color(0xFF2196F3);
    if (ratio >= 0.4) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }

  String _getRatingText(double rating) {
    if (rating >= 4.5) return '매우 좋음';
    if (rating >= 3.5) return '좋음';
    if (rating >= 2.5) return '보통';
    if (rating >= 1.5) return '나쁨';
    if (rating >= 0.5) return '매우 나쁨';
    return '';
  }
}