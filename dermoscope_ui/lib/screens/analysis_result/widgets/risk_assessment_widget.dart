import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RiskAssessmentWidget extends StatelessWidget {
  final String riskLevel;
  final List<Map<String, dynamic>> detectedConditions;

  const RiskAssessmentWidget({
    Key? key,
    required this.riskLevel,
    required this.detectedConditions,
  }) : super(key: key);

  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'moderate':
      case 'orta':
        return const Color(0xFFFF9800); // Orange
      case 'high':
      case 'yüksek':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getRiskTitle(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return 'Düşük Risk';
      case 'moderate':
      case 'orta':
        return 'Orta Risk';
      case 'high':
      case 'yüksek':
        return 'Yüksek Risk';
      default:
        return 'Risk Değerlendirmesi';
    }
  }

  String _getRiskDescription(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return 'Tespit edilen durumlar genel olarak hafif seviyededir. Düzenli bakım ve takip yeterli olacaktır.';
      case 'moderate':
      case 'orta':
        return 'Tespit edilen durumlar dikkat gerektirir. Önerilen bakım rutinini takip edin ve gelişimi izleyin.';
      case 'high':
      case 'yüksek':
        return 'Tespit edilen durumlar acil dikkat gerektirir. Dermatolog konsültasyonu önerilir.';
      default:
        return 'Risk seviyesi değerlendiriliyor...';
    }
  }

  String _getNextSteps(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return 'Önerilen bakım rutinini uygulayın ve 4-6 hafta sonra tekrar kontrol edin.';
      case 'moderate':
      case 'orta':
        return 'Önerilen tedaviyi başlatın ve 2-3 hafta içinde gelişimi takip edin.';
      case 'high':
      case 'yüksek':
        return 'En kısa sürede bir dermatolog ile görüşün ve profesyonel tedavi alın.';
      default:
        return 'Lütfen önerileri takip edin.';
    }
  }

  IconData _getRiskIcon(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return Icons.check_circle;
      case 'moderate':
      case 'orta':
        return Icons.warning;
      case 'high':
      case 'yüksek':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _getRiskIconName(String risk) {
    switch (risk.toLowerCase()) {
      case 'low':
      case 'düşük':
        return 'check_circle';
      case 'moderate':
      case 'orta':
        return 'warning';
      case 'high':
      case 'yüksek':
        return 'error_outline';
      default:
        return 'info';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color riskColor = _getRiskColor(riskLevel);
    final String riskTitle = _getRiskTitle(riskLevel);
    final String riskDescription = _getRiskDescription(riskLevel);
    final String nextSteps = _getNextSteps(riskLevel);
    final IconData riskIcon = _getRiskIcon(riskLevel);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: riskColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: _getRiskIconName(riskLevel),
                  color: riskColor,
                  size: 28,
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Risk Değerlendirmesi',
                      style: AppTheme.lightTheme.textTheme.labelMedium
                          ?.copyWith(
                            color: AppTheme
                                .lightTheme
                                .colorScheme
                                .onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      riskTitle,
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Risk Description
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: riskColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Text(
              riskDescription,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Risk Factors
          Text(
            'Risk Faktörleri',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          ...detectedConditions.map((condition) {
            final String severity = condition["severity"] as String;
            final double confidence = condition["confidence"] as double;
            final Color conditionRiskColor = _getConditionRiskColor(
              severity,
              confidence,
            );

            return Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: conditionRiskColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: conditionRiskColor.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  condition["name"] as String,
                                  style: AppTheme.lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .onSurface,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: conditionRiskColor.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  severity,
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: conditionRiskColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Güvenilirlik: ${confidence.toStringAsFixed(1)}% • Etkilenen alan: ${(condition["affectedArea"] as double).toStringAsFixed(1)}%',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

          SizedBox(height: 3.h),

          // Next Steps
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: riskColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: riskColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: riskColor,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Önerilen Adımlar',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  nextSteps,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConditionRiskColor(String severity, double confidence) {
    if (severity.toLowerCase().contains('şiddetli') || confidence > 90) {
      return AppTheme.lightTheme.colorScheme.error;
    } else if (severity.toLowerCase().contains('orta') || confidence > 75) {
      return const Color(0xFFFF9800); // Orange
    } else {
      return AppTheme.lightTheme.colorScheme.secondary;
    }
  }
}
