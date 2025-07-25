import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'card_container.dart';

class PersonalInfoSection extends StatefulWidget {
  const PersonalInfoSection({super.key});

  @override
  State<PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<PersonalInfoSection> {
  bool isEditing = false;

  final nameController = TextEditingController(text: "Ayşe Demir");
  final ageController = TextEditingController(text: "28");
  final emailController = TextEditingController(text: "ayse.demir@email.com");
  final phoneController = TextEditingController(text: "+90 532 123 4567");

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.grey),
              const SizedBox(width: 8),
              const Text('Kişisel Bilgiler', style: AppTextStyles.title),
              const Spacer(),
              if (!isEditing)
                Chip(
                  label: const Text("Doğrulandı"),
                  backgroundColor: Colors.teal.shade100,
                  labelStyle: const TextStyle(color: Colors.teal),
                ),
              IconButton(
                icon: Icon(isEditing ? Icons.close : Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditing = !isEditing;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildTextField("Ad Soyad", Icons.person_outline, nameController),
          const SizedBox(height: 12),
          _buildTextField("Yaş", Icons.cake_outlined, ageController),
          const SizedBox(height: 12),
          _buildTextField("E-posta", Icons.email_outlined, emailController),
          const SizedBox(height: 12),
          _buildTextField("Telefon", Icons.phone_outlined, phoneController),

          if (isEditing) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => isEditing = false),
                    child: const Text(
                      "İptal",
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => isEditing = false);
                      // TODO: Kaydetme işlemi
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      "Kaydet",
                      style: TextStyle(color: AppColors.lightBackground),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
