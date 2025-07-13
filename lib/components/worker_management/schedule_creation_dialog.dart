// lib/components/worker_management/schedule_creation_dialog.dart

import 'package:flutter/material.dart';
import '../../services/schedule_management_service.dart';

class ScheduleCreationDialog extends StatefulWidget {
  final List<dynamic> hiredWorkers;
  final dynamic selectedWorker;
  final VoidCallback onScheduleCreated;

  const ScheduleCreationDialog({
    Key? key,
    required this.hiredWorkers,
    this.selectedWorker,
    required this.onScheduleCreated,
  }) : super(key: key);

  @override
  State<ScheduleCreationDialog> createState() => _ScheduleCreationDialogState();
}

class _ScheduleCreationDialogState extends State<ScheduleCreationDialog> {
  dynamic _selectedWorker;
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  double _hourlyRate = 12000;
  String _workLocation = '제주시';
  String _notes = '';
  bool _isLoading = false;

  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedWorker = widget.selectedWorker ?? widget.hiredWorkers.first;
    _hourlyRate = _selectedWorker['hourlyRate']?.toDouble() ?? 12000;
    _workLocation = _selectedWorker['workLocation']?.toString() ?? '제주시';

    // 안전한 기본 종료 시간 설정
    final currentHour = DateTime.now().hour;
    if (currentHour < 18) {
      final endHour = currentHour + 8;
      _endTime = TimeOfDay(hour: endHour > 23 ? 18 : endHour, minute: 0);
    } else {
      _endTime = const TimeOfDay(hour: 18, minute: 0);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            _buildFormContent(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3748),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.schedule, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '스케줄 생성',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return Flexible(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWorkerSelection(),
            const SizedBox(height: 20),
            _buildDateSelection(),
            const SizedBox(height: 20),
            _buildTimeSelection(),
            const SizedBox(height: 20),
            _buildHourlyRateInput(),
            const SizedBox(height: 20),
            _buildWorkLocationInput(),
            const SizedBox(height: 20),
            _buildNotesInput(),
            const SizedBox(height: 20),
            _buildEstimatedPayDisplay(),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkerSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('직원 선택'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<dynamic>(
            value: _selectedWorker,
            isExpanded: true,
            underline: const SizedBox(),
            items: widget.hiredWorkers.map((worker) {
              return DropdownMenuItem<dynamic>(
                value: worker,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF2D3748),
                      child: Text(
                        worker['name']?.toString().substring(0, 1) ?? '?',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            worker['name']?.toString() ?? '이름 없음',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            worker['workLocation']?.toString() ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedWorker = value;
                _hourlyRate = value['hourlyRate']?.toDouble() ?? 12000;
                _workLocation = value['workLocation']?.toString() ?? '제주시';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('근무 날짜'),
        InkWell(
          onTap: _selectDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF2D3748)),
                const SizedBox(width: 12),
                Text(
                  '${_startDate.year}년 ${_startDate.month}월 ${_startDate.day}일',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('근무 시간'),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(true),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('시작 시간', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        _startTime.format(context),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(false),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('종료 시간', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(
                        _endTime.format(context),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourlyRateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('시급 (원)'),
        TextFormField(
          initialValue: _hourlyRate.toInt().toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '시급을 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            prefixText: '₩ ',
          ),
          onChanged: (value) {
            _hourlyRate = double.tryParse(value) ?? 12000;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildWorkLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('근무지'),
        TextFormField(
          initialValue: _workLocation,
          decoration: InputDecoration(
            hintText: '근무지를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _workLocation = value;
          },
        ),
      ],
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('메모 (선택사항)'),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '추가 메모를 입력하세요',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onChanged: (value) {
            _notes = value;
          },
        ),
      ],
    );
  }

  Widget _buildEstimatedPayDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('예상 급여', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            '₩${_calculateEstimatedPay().toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          Text(
            '근무시간: ${_calculateWorkHours().toStringAsFixed(1)}시간',
            style: TextStyle(fontSize: 12, color: Colors.green[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF2D3748)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('취소', style: TextStyle(color: Color(0xFF2D3748))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _createSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3748),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('스케줄 생성', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2D3748),
        ),
      ),
    );
  }

  void _selectDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
      });
    }
  }

  void _selectTime(bool isStartTime) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = selectedTime;
        } else {
          _endTime = selectedTime;
        }
      });
    }
  }

  double _calculateWorkHours() {
    final start = _startTime.hour + _startTime.minute / 60.0;
    final end = _endTime.hour + _endTime.minute / 60.0;
    return end > start ? end - start : (24 - start) + end;
  }

  double _calculateEstimatedPay() {
    return _calculateWorkHours() * _hourlyRate;
  }

  void _createSchedule() async {
    if (_selectedWorker == null) {
      _showErrorMessage('직원을 선택해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // DateTime 생성 - 더 안전한 방법으로 처리
      final year = _startDate.year;
      final month = _startDate.month;
      final day = _startDate.day;

      final startDateTime = DateTime(year, month, day, _startTime.hour, _startTime.minute);

      DateTime endDateTime;
      // 종료 시간이 시작 시간보다 이른 경우 다음날로 처리
      if (_endTime.hour < _startTime.hour ||
          (_endTime.hour == _startTime.hour && _endTime.minute <= _startTime.minute)) {
        // 다음날
        endDateTime = DateTime(year, month, day + 1, _endTime.hour, _endTime.minute);
        print('야간 근무 감지 - 다음날로 설정');
      } else {
        // 같은 날
        endDateTime = DateTime(year, month, day, _endTime.hour, _endTime.minute);
        print('일반 근무 - 같은 날로 설정');
      }

      print('=== 스케줄 생성 디버그 ===');
      print('선택된 날짜: ${_startDate.toString()}');
      print('시작 시간: ${_startTime.toString()}');
      print('종료 시간: ${_endTime.toString()}');
      print('생성된 시작 DateTime: ${startDateTime.toString()}');
      print('생성된 종료 DateTime: ${endDateTime.toString()}');
      print('ISO 시작: ${startDateTime.toIso8601String()}');
      print('ISO 종료: ${endDateTime.toIso8601String()}');

      final result = await ScheduleManagementService.createSchedule(
        staffId: _selectedWorker['id'],
        jobId: _selectedWorker['jobId'] ?? 'default_job_id',
        startTime: startDateTime,
        endTime: endDateTime,
        hourlyRate: _hourlyRate,
        workLocation: _workLocation,
        notes: _notes.isNotEmpty ? _notes : null,
      );

      if (result['success']) {
        Navigator.pop(context);
        widget.onScheduleCreated();
        _showSuccessMessage('스케줄이 성공적으로 생성되었습니다!');
      } else {
        _showErrorMessage(result['error'] ?? '스케줄 생성에 실패했습니다.');
      }
    } catch (e) {
      print('스케줄 생성 예외: $e');
      _showErrorMessage('스케줄 생성 중 오류가 발생했습니다: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}