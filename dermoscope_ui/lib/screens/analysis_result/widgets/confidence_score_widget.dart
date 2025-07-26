import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConfidenceScoreWidget extends StatefulWidget {
  final double score;
  final String timestamp;

  const ConfidenceScoreWidget({
    Key? key,
    required this.score,
    required this.timestamp,
  }) : super(key: key);

  @override
  State<ConfidenceScoreWidget> createState() => _ConfidenceScoreWidgetState();
}

class _ConfidenceScoreWidgetState extends State<ConfidenceScoreWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 85) {
      return AppTheme.lightTheme.colorScheme.secondary; // Success green
    } else if (score >= 70) {
      return const Color(0xFFFF9800); // Warning orange
    } else {
      return AppTheme.lightTheme.colorScheme.error; // Error red
    }
  }

  String _getScoreLabel(double score) {
    if (score >= 85) {
      return 'Yüksek Güvenilirlik';
    } else if (score >= 70) {
      return 'Orta Güvenilirlik';
    } else {
      return 'Düşük Güvenilirlik';
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final DateTime dateTime = DateTime.parse(timestamp);
      final String formattedDate =
          '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      final String formattedTime =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      return '$formattedDate - $formattedTime';
    } catch (e) {
      return 'Bilinmeyen Tarih';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color scoreColor = _getScoreColor(widget.score);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: scoreColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'analytics',
                  color: scoreColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analiz Güvenilirliği',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      _formatTimestamp(widget.timestamp),
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          // Score Display
          Row(
            children: [
              // Circular Progress Indicator
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: AnimatedBuilder(
                  animation: _scoreAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        // Background circle
                        Container(
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: scoreColor.withValues(alpha: 0.1),
                          ),
                        ),
                        // Progress circle
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            value: _scoreAnimation.value,
                            strokeWidth: 6,
                            backgroundColor: scoreColor.withValues(alpha: 0.2),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(scoreColor),
                          ),
                        ),
                        // Score text
                        Positioned.fill(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${(widget.score * _scoreAnimation.value).toInt()}%',
                                  style: AppTheme
                                      .lightTheme.textTheme.headlineSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: scoreColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              SizedBox(width: 6.w),

              // Score Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getScoreLabel(widget.score),
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      widget.score >= 85
                          ? 'AI analizi yüksek doğrulukla tamamlandı. Sonuçlar güvenilir kabul edilebilir.'
                          : widget.score >= 70
                              ? 'AI analizi orta düzeyde güvenilirlikle tamamlandı. Ek değerlendirme önerilir.'
                              : 'AI analizi düşük güvenilirlikle tamamlandı. Tekrar görüntü alınması önerilir.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Güvenilirlik Seviyesi',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${widget.score.toStringAsFixed(1)}%',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _scoreAnimation.value,
                    backgroundColor: scoreColor.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                    minHeight: 6,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
