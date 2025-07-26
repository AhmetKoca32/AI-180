import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisImageWidget extends StatelessWidget {
  final String imageUrl;
  final List<Map<String, dynamic>> detectedConditions;

  const AnalysisImageWidget({
    Key? key,
    required this.imageUrl,
    required this.detectedConditions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.h,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Main analyzed image
            CustomImageWidget(
              imageUrl: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),

            // AI Detection Overlays
            ...detectedConditions.asMap().entries.map((entry) {
              final index = entry.key;
              final condition = entry.value;
              return _buildDetectionOverlay(condition, index);
            }).toList(),

            // Gradient overlay for better text visibility
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 15.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Analysis info overlay
            Positioned(
              bottom: 2.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.9,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'psychology',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'AI Analizi Tamamlandı',
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${detectedConditions.length} Durum Tespit Edildi',
                        style: AppTheme.lightTheme.textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionOverlay(Map<String, dynamic> condition, int index) {
    final Color markerColor = _getConditionColor(condition["type"] as String);
    final double topPosition = 10.0 + (index * 8.0); // Stagger positions
    final double leftPosition = 15.0 + (index * 12.0);

    return Positioned(
      top: topPosition.h,
      left: leftPosition.w,
      child: GestureDetector(
        onTap: () {
          // Could show detailed condition info in a popup
        },
        child: Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: markerColor.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
}
