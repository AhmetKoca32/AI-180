import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class ConsultationTypeSelector extends StatelessWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const ConsultationTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final consultationTypes = [
      {
        'type': 'Skin',
        'label': 'Cilt',
        'icon': 'face',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'type': 'Hair',
        'label': 'Saç',
        'icon': 'brush',
        'color': AppTheme.lightTheme.colorScheme.secondary,
      },
      {
        'type': 'General',
        'label': 'Genel',
        'icon': 'medical_services',
        'color': AppTheme.lightTheme.colorScheme.tertiary,
      },
    ];

    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.2,
            ),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: consultationTypes.map((type) {
          final isSelected = selectedType == type['type'];
          return Expanded(
            child: GestureDetector(
              onTap: () => onTypeChanged(type['type'] as String),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (type['color'] as Color).withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? (type['color'] as Color)
                        : AppTheme.lightTheme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: type['icon'] as String,
                      color: isSelected
                          ? (type['color'] as Color)
                          : AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                      size: 14,
                    ),
                    Text(
                      type['label'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? (type['color'] as Color)
                            : AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        fontSize: 10,
                      ),
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
