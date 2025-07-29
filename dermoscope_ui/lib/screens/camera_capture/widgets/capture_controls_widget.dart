import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CaptureControlsWidget extends StatelessWidget {
  final bool isReady;
  final bool isCapturing;
  final VoidCallback onCapture;
  final VoidCallback onGalleryTap;

  const CaptureControlsWidget({
    Key? key,
    required this.isReady,
    required this.isCapturing,
    required this.onCapture,
    required this.onGalleryTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gallery Button
          GestureDetector(
            onTap: onGalleryTap,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Gallery thumbnail placeholder
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[700]!,
                          Colors.grey[500]!,
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: CustomIconWidget(
                      iconName: 'photo_library',
                      color: Colors.white,
                      size: 6.w,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Capture Button
          GestureDetector(
            onTap: isReady ? onCapture : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCapturing
                    ? AppTheme.lightTheme.colorScheme.tertiary
                    : isReady
                        ? Colors.white
                        : Colors.grey[600],
                border: Border.all(
                  color: isReady
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.grey[400]!,
                  width: 4,
                ),
                boxShadow: isReady
                    ? [
                        BoxShadow(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isCapturing
                  ? Center(
                      child: SizedBox(
                        width: 8.w,
                        height: 8.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    )
                  : Center(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: isReady ? 12.w : 10.w,
                        height: isReady ? 12.w : 10.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReady
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.grey[500],
                        ),
                      ),
                    ),
            ),
          ),

          // Spacer to balance layout
          SizedBox(width: 15.w),
        ],
      ),
    );
  }
}
