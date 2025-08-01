import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConditionCardWidget extends StatelessWidget {
  // Description temizleme fonksiyonu (markdown, yıldız, Elbette vs.)
  String _cleanDescription(String? description) {
    if (description == null) return '';
    return description
        .replaceAll(RegExp(r'\*\*'), '')
        .replaceAll(RegExp(r'\*'), '')
        .replaceAll(RegExp(r'•|_|\-|\n'), ' ')
        .replaceAll(RegExp(r'Elbette', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  final Map<String, dynamic> condition;
  final Function(bool) onExpansionChanged;

  const ConditionCardWidget({
    Key? key,
    required this.condition,
    required this.onExpansionChanged,
  }) : super(key: key);

  Color _getConditionColor(String conditionType) {
    switch (conditionType) {
      case 'acne':
        return AppTheme.lightTheme.colorScheme.error;
      case 'pigmentation':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'texture':
        return const Color(0xFFFF9800); // Orange
      case 'eczema':
        return const Color(0xFF9C27B0); // Purple
      case 'melanoma':
        return const Color(0xFF000000); // Black
      case 'hair_loss':
        return const Color(0xFF795548); // Brown
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getConditionIcon(String conditionType) {
    switch (conditionType) {
      case 'acne':
        return 'circle';
      case 'pigmentation':
        return 'palette';
      case 'texture':
        return 'texture';
      case 'eczema':
        return 'healing';
      case 'melanoma':
        return 'warning';
      case 'hair_loss':
        return 'face';
      default:
        return 'medical_services';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'hafif':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'orta şiddetli':
      case 'orta':
        return const Color(0xFFFF9800); // Orange
      case 'şiddetli':
      case 'yüksek':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color conditionColor = _getConditionColor(
      condition["type"] as String,
    );
    final Color severityColor = _getSeverityColor(
      condition["severity"] as String,
    );
    final bool isExpanded = condition["isExpanded"] as bool? ?? false;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: conditionColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: onExpansionChanged,
          initiallyExpanded: isExpanded,
          tilePadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          childrenPadding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 3.h),
          leading: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: conditionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: _getConditionIcon(condition["type"] as String),
              color: conditionColor,
              size: 24,
            ),
          ),
          title: Text(
            condition["name"] as String,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    condition["severity"] as String,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: severityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Text(
                  '${(condition["confidence"] as double).toStringAsFixed(1)}% güvenilirlik',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          trailing: CustomIconWidget(
            iconName: isExpanded ? 'expand_less' : 'expand_more',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  _cleanDescription(condition["description"] as String?),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 2.h),

                // Statistics Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Etkilenen Alan',
                        '${(condition["affectedArea"] as double).toStringAsFixed(1)}%',
                        Icons.area_chart,
                        conditionColor,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _buildStatCard(
                        'Güvenilirlik',
                        '${(condition["confidence"] as double).toStringAsFixed(1)}%',
                        Icons.verified,
                        severityColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Medical Terms
                if (condition["medicalTerms"] != null &&
                    (condition["medicalTerms"] as List).isNotEmpty) ...[
                  Text(
                    'Tıbbi Terimler',
                    style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: (condition["medicalTerms"] as List<String>)
                        .map(
                          (term) => Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              term,
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon.codePoint.toString(),
            color: color,
            size: 20,
          ),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
String _cleanDescription(String? description) {
  if (description == null) return '';
  return description
      .replaceAll(RegExp(r'\*\*'), '') // çift yıldızları kaldır
      .replaceAll(RegExp(r'\*'), '') // tek yıldızları kaldır
      .replaceAll(RegExp(r'•|_|\-|\n'), ' ') // diğer karakterleri kaldır
      .replaceAll(RegExp(r'Elbette', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
