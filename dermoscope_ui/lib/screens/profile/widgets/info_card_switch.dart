// lib/widgets/info_card_switch.dart

import 'package:flutter/material.dart';
import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:dermoscope_ui/core/theme/app_text_styles.dart';

class InfoCardSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final void Function(bool) onChanged;
  final Color? activeIconColor;
  final Color? inactiveIconColor;
  final Color? activeBackgroundColor;
  final Color? inactiveBackgroundColor;

  const InfoCardSwitch({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeIconColor,
    this.inactiveIconColor,
    this.activeBackgroundColor,
    this.inactiveBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = value
        ? (activeIconColor ?? AppColors.primary)
        : (inactiveIconColor ?? Colors.grey);
    final Color bgColor = value
        ? (activeBackgroundColor ?? const Color(0xFFEAF1F4))
        : (inactiveBackgroundColor ?? const Color(0xFFF3F4F6));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.primary.withOpacity(0.8)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.small),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
