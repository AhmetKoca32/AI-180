import 'package:dermoscope_ui/screens/profile/logout_button.dart';
import 'package:dermoscope_ui/screens/profile/widgets/security_section.dart';
import 'package:flutter/material.dart';

import 'widgets/notification_preferences.dart';
import 'widgets/personal_info_section.dart';
import 'widgets/profile_header.dart';
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
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profil Ayarları",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                // Kaydetme işlemi
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Değişiklikler kaydedildi'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              icon: const Icon(Icons.save, size: 18),
              label: const Text(
                'Kaydet',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(width * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: const [
                ProfileHeader(),
                SizedBox(height: 20),
                PersonalInfoSection(),
                SizedBox(height: 20),
                SkinProfileSection(),
                SizedBox(height: 20),
                NotificationPreferencesSection(),
                SizedBox(height: 20),
                SecuritySection(),
                SizedBox(height: 20),
                LogoutButton(),
                SizedBox(height: 32),
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
        ),
      ),
    );
  }
}
