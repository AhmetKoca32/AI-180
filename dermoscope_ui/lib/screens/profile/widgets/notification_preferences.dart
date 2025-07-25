import 'package:dermoscope_ui/screens/profile/widgets/card_container.dart';
import 'package:dermoscope_ui/screens/profile/widgets/info_card_switch.dart';
import 'package:flutter/material.dart';
import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:dermoscope_ui/core/theme/app_text_styles.dart';
import 'package:intl/intl.dart';

class NotificationPreferencesSection extends StatefulWidget {
  const NotificationPreferencesSection({super.key});

  @override
  State<NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<NotificationPreferencesSection> {
  bool analysisReminder = false;
  bool routineWarning = false;
  bool educationalContent = false;
  bool emergencyAlerts = false;
  TimeOfDay reminderTime = const TimeOfDay(hour: 9, minute: 00);

  /// 24 saatlik formatta TimeOfDay'ı String'e çevirir
  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.Hm().format(dt);
  }

  Future<void> _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: AppColors.primary,
              dialHandColor: AppColors.primary,
              dialBackgroundColor: Color(0xFFF2F7FA),
              dayPeriodColor: Color(0xFFF1F5F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != reminderTime) {
      setState(() => reminderTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications, color: AppColors.primary),
              SizedBox(width: 8),
              Text("Bildirim Tercihleri", style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 16),
          InfoCardSwitch(
            icon: Icons.bar_chart,
            title: "Analiz Hatırlatıcıları",
            subtitle: "Düzenli cilt analizi için hatırlatmalar",
            value: analysisReminder,
            onChanged: (v) => setState(() => analysisReminder = v),
            activeIconColor: AppColors.primary,
            inactiveIconColor: Colors.grey,
            activeBackgroundColor: const Color(0xFFEAF1F4),
            inactiveBackgroundColor: const Color(0xFFF5F7F8),
          ),
          InfoCardSwitch(
            icon: Icons.access_time,
            title: "Rutin Uyarıları",
            subtitle: "Cilt bakım rutini hatırlatmaları",
            value: routineWarning,
            onChanged: (v) => setState(() => routineWarning = v),
            activeIconColor: AppColors.primary,
            inactiveIconColor: Colors.grey,
            activeBackgroundColor: const Color(0xFFEAF1F4),
            inactiveBackgroundColor: const Color(0xFFF5F7F8),
          ),
          InfoCardSwitch(
            icon: Icons.school_outlined,
            title: "Eğitici İçerik",
            subtitle: "Günlük cilt bakım ipuçları",
            value: educationalContent,
            onChanged: (v) => setState(() => educationalContent = v),
            activeIconColor: AppColors.primary,
            inactiveIconColor: Colors.grey,
            activeBackgroundColor: const Color(0xFFEAF1F4),
            inactiveBackgroundColor: const Color(0xFFF5F7F8),
          ),
          InfoCardSwitch(
            icon: Icons.warning_amber_rounded,
            title: "Acil Durum Bildirimleri",
            subtitle: "Yüksek riskli durumlar için uyarılar",
            value: emergencyAlerts,
            onChanged: (v) => setState(() => emergencyAlerts = v),
            activeIconColor: Colors.red.shade600,
            inactiveIconColor: Colors.red.shade100,
            activeBackgroundColor: const Color(0xFFFFEBEB),
            inactiveBackgroundColor: const Color(0xFFFCEDED),
          ),
          const SizedBox(height: 2),
          _buildReminderTimeCard(),
        ],
      ),
    );
  }

  Widget _buildReminderTimeCard() {
    return GestureDetector(
      onTap: _selectReminderTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.primary.withOpacity(0.9)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.access_time, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hatırlatma Saati", style: AppTextStyles.subtitle),
                  SizedBox(height: 4),
                  Text(
                    "Günlük bildirimlerin gönderileceği saat",
                    style: AppTextStyles.small,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1F4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                formatTime(reminderTime),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
