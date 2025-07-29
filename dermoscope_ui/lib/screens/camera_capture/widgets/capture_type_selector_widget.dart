import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CaptureTypeSelectorWidget extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const CaptureTypeSelectorWidget({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> captureTypes = [
      {
        'id': 'skin',
        'label': 'Cilt',
        'icon': 'face',
        'description': 'Cilt analizi',
      },
      {
        'id': 'hair',
        'label': 'Saç',
        'icon': 'brush',
        'description': 'Saç analizi',
      },
      {
        'id': 'scalp',
        'label': 'Saç Derisi',
        'icon': 'psychology',
        'description': 'Saç derisi analizi',
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: captureTypes.map((type) {
          final bool isSelected = selectedType == type['id'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(type['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: type['icon'],
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      size: 6.w,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      type['label'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
