import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActionButtonsWidget extends StatelessWidget {
  final VoidCallback onSaveToHistory;
  final VoidCallback onConsultSpecialist;
  final String riskLevel;
  final bool isLoading;

  const ActionButtonsWidget({
    Key? key,
    required this.onSaveToHistory,
    required this.onConsultSpecialist,
    required this.riskLevel,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isHighRisk =
        riskLevel.toLowerCase() == 'high' ||
        riskLevel.toLowerCase() == 'yüksek';

    return Column(
      children: [
        // Primary Action Button (Save to History)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSaveToHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.lightTheme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Kaydediliyor...',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'save',
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        size: 20,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'Geçmişe Kaydet',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                      ),
                    ],
                  ),
          ),
        ),

        SizedBox(height: 2.h),

        // Secondary Action Button (Consult Specialist)
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isLoading ? null : onConsultSpecialist,
            style: OutlinedButton.styleFrom(
              foregroundColor: isHighRisk
                  ? AppTheme.lightTheme.colorScheme.error
                  : AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: isHighRisk
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.primary,
                width: 1.5,
              ),
              padding: EdgeInsets.symmetric(vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: isHighRisk
                  ? AppTheme.lightTheme.colorScheme.error.withValues(
                      alpha: 0.05,
                    )
                  : Colors.transparent,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: isHighRisk ? 'priority_high' : 'chat',
                  color: isHighRisk
                      ? AppTheme.lightTheme.colorScheme.error
                      : AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Text(
                  isHighRisk ? 'Acil Uzman Konsültasyonu' : 'Uzman ile Görüş',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isHighRisk
                        ? AppTheme.lightTheme.colorScheme.error
                        : AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Additional Actions Row
        Row(
          children: [
            // View History Button
            Expanded(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/skin-analysis-history');
                      },
                style: TextButton.styleFrom(
                  foregroundColor:
                      AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'history',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Geçmişi Görüntüle',
                      style: AppTheme.lightTheme.textTheme.labelMedium
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

            // Vertical Divider
            Container(
              width: 1,
              height: 4.h,
              color: AppTheme.lightTheme.colorScheme.outline,
            ),

            // New Analysis Button
            Expanded(
              child: TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(context, '/camera-capture');
                      },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.lightTheme.colorScheme.primary,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'camera_alt',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Yeni Analiz',
                      style: AppTheme.lightTheme.textTheme.labelMedium
                          ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // High Risk Warning (if applicable)
        if (isHighRisk) ...[
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.error.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.error.withValues(
                  alpha: 0.3,
                ),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Önemli Uyarı',
                        style: AppTheme.lightTheme.textTheme.titleSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.error,
                            ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        'Yüksek risk tespit edildi. Lütfen en kısa sürede bir dermatolog ile görüşün.',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface,
                              height: 1.3,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
