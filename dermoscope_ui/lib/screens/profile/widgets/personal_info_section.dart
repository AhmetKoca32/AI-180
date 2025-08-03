import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../services/api_service.dart';
import 'card_container.dart';

class PersonalInfoSection extends StatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool isEditing = false;
  bool isLoading = false;

  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('PersonalInfo: Kullanıcı profili yükleniyor...');

      // Network test yap
      await ApiService.testNetworkConnection();

      final userData = await ApiService.getUserProfile();
      print('PersonalInfo: API\'den gelen veri: $userData');

      setState(() {
        nameController.text =
            '${userData['first_name'] ?? ''} ${userData['last_name'] ?? ''}'
                .trim();
        ageController.text = userData['age']?.toString() ?? '';
        emailController.text = userData['email'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        isLoading = false;
      });

      print('PersonalInfo: Controller\'lar güncellendi:');
      print('PersonalInfo: - Ad Soyad: ${nameController.text}');
      print('PersonalInfo: - Yaş: ${ageController.text}');
      print('PersonalInfo: - E-posta: ${emailController.text}');
      print('PersonalInfo: - Telefon: ${phoneController.text}');
    } catch (e) {
      print('PersonalInfo: Hata oluştu: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kullanıcı bilgileri yüklenirken hata oluştu: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _saveUserProfile() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Ad ve soyadı ayır
      final nameParts = nameController.text.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      final userData = {
        'first_name': firstName,
        'last_name': lastName,
        'age': ageController.text.isNotEmpty
            ? int.tryParse(ageController.text)
            : null,
        'phone': phoneController.text.isNotEmpty ? phoneController.text : null,
      };

      await ApiService.updateUserProfile(userData);

      setState(() {
        isEditing = false;
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bilgiler başarıyla güncellendi'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Bilgiler güncellenirken hata oluştu: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Kişisel Bilgiler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (!isEditing)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 16, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text(
                        "Doğrulandı",
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(width: 8),
              if (!isLoading)
                IconButton(
                  icon: Icon(
                    isEditing ? Icons.close : Icons.edit,
                    color: AppColors.primary,
                  ),
                  onPressed: () {
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          if (isLoading)
            const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          else ...[
            _buildTextField("Ad Soyad", Icons.person_outline, nameController),
            const SizedBox(height: 16),
            _buildTextField("Yaş", Icons.cake_outlined, ageController),
            const SizedBox(height: 16),
            _buildTextField(
              "E-posta",
              Icons.email_outlined,
              emailController,
              readOnly: true,
            ),
            const SizedBox(height: 16),
            _buildTextField("Telefon", Icons.phone_outlined, phoneController),

            // Test kullanıcısı oluşturma butonu kaldırıldı

            if (isEditing) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              setState(() => isEditing = false);
                              _loadUserProfile(); // Orijinal verileri geri yükle
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        "İptal",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Kaydet",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing || readOnly,
      style: const TextStyle(fontSize: 16, color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isEditing ? AppColors.primary : AppColors.textSecondary,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          icon,
          color: isEditing ? AppColors.primary : AppColors.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: !isEditing,
        fillColor: isEditing ? Colors.transparent : Colors.grey[50],
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
