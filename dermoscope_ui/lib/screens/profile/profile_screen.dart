import 'package:dermoscope_ui/screens/profile/logout_button.dart';
import 'package:dermoscope_ui/screens/profile/widgets/security_section.dart';
import 'package:flutter/material.dart';
import 'widgets/notification_preferences.dart';
import 'widgets/profile_header.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/skin_profile_section.dart';
/* import 'widgets/report_summary_section.dart';
import 'widgets/data_export_section.dart';
import 'widgets/app_preferences_section.dart';
import 'widgets/security_section.dart';
import 'widgets/privacy_section.dart'; */

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Ayarları"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // paylaşım işlemi
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            ProfileHeader(),
            SizedBox(height: 16),
            PersonalInfoSection(),
            SizedBox(height: 16),
            SkinProfileSection(),
            SizedBox(height: 16),
            NotificationPreferencesSection(),
            SizedBox(height: 16),
            SecuritySection(),
            SizedBox(height: 16),
            LogoutButton(),
            /* ReportSummarySection(),
            
            DataExportSection(),
            SizedBox(height: 16),
            AppPreferencesSection(),
            SizedBox(height: 16),
            
            PrivacySection(),
            SizedBox(height: 32),
            LogoutButton(), // eğer ayrı widget yaparsak */
          ],
        ),
      ),
    );
  }
}
