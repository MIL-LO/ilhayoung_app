import 'package:flutter/material.dart';
import '../../../models/jeju_job_item.dart';

class JobCard extends StatelessWidget {
  final JejuJobItem job;
  final VoidCallback onTap;

  const JobCard({
    Key? key,
    required this.job,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: job.isUrgent
                ? const Color(0xFFFF6B35).withOpacity(0.3)
                : const Color(0xFF00A3A3).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 4),
            _buildTitle(),
            const SizedBox(height: 6),
            _buildSalary(),
            const SizedBox(height: 4),
            _buildLocationInfo(),
            const SizedBox(height: 6),
            _buildTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            job.company,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF00A3A3),
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (job.isUrgent)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '급구',
              style: TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      job.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSalary() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF00A3A3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        job.salary,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF00A3A3),
        ),
      ),
    );
  }

  Widget _buildLocationInfo() {
    return Row(
      children: [
        Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          job.location,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(width: 8),
        Icon(Icons.work_outline, size: 12, color: Colors.grey[600]),
        const SizedBox(width: 2),
        Text(
          job.workType,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 3,
      runSpacing: 2,
      children: job.tags.take(2).map((tag) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          tag,
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      )).toList(),
    );
  }
}