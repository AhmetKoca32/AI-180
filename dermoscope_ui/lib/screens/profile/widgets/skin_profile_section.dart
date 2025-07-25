import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:dermoscope_ui/core/theme/app_text_styles.dart';
import 'package:dermoscope_ui/screens/profile/widgets/card_container.dart';
import 'package:dermoscope_ui/screens/profile/widgets/info_card_switch.dart';
import 'package:flutter/material.dart';

class SkinProfileSection extends StatefulWidget {
  const SkinProfileSection({super.key});

  @override
  State<SkinProfileSection> createState() => _SkinProfileSectionState();
}

class _SkinProfileSectionState extends State<SkinProfileSection> {
  double _stres = 0;
  int selectedSkinType = 2;

  bool hasAllergies = false;
  bool takesMeds = false;
  bool hasFamilyHistory = false;

  final List<Map<String, dynamic>> skinTypes = [
    {"label": "Type I\nÇok açık", "color": Color(0xFFFFF2E5)},
    {"label": "Type II\nAçık", "color": Color(0xFFFFE0CC)},
    {"label": "Type III\nOrta", "color": Color(0xFFFFC7A6)},
    {"label": "Type IV\nEsmer", "color": Color(0xFFE1A370)},
    {"label": "Type V\nKoyu", "color": Color(0xFFB57642)},
    {"label": "Type VI\nÇok koyu", "color": Color(0xFF8B5C2C)},
  ];

  String _getEmoji(double value) {
    if (value <= 0) return "😌";
    if (value <= 1) return "🙂";
    if (value <= 2) return "😐";
    if (value <= 3) return "😟";
    return "😣";
  }

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.face, color: Colors.grey),
              SizedBox(width: 8),
              Text('Cilt Profili', style: AppTextStyles.title),
            ],
          ),
          const SizedBox(height: 16),

          const Text("Fitzpatrick Cilt Tipi", style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: skinTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final selected = selectedSkinType == index;
                return GestureDetector(
                  onTap: () => setState(() => selectedSkinType = index),
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: skinTypes[index]['color'],
                      borderRadius: BorderRadius.circular(12),
                      border: selected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(color: Colors.transparent),
                    ),
                    child: Center(
                      child: Text(
                        skinTypes[index]['label'] ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: selected ? Colors.black : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Stres Seviyesi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A2B3C),
                    ),
                  ),

                  Spacer(),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getEmoji(_stres),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF2C6671),
                        inactiveTrackColor: const Color(0xFFE5F1F4),
                        thumbColor: const Color(0xFF2C6671),
                        overlayColor: const Color(0x332C6671),
                        trackHeight: 6,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 12,
                        ),
                      ),
                      child: Slider(
                        value: _stres,
                        min: 0,
                        max: 4,
                        divisions: 4,
                        onChanged: (value) {
                          setState(() {
                            _stres = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Düşük', style: TextStyle(color: Colors.grey)),
                    Text('Yüksek', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          const SizedBox(height: 24),
          const Text("Tıbbi Geçmiş", style: AppTextStyles.subtitle),
          const SizedBox(height: 12),
          InfoCardSwitch(
            icon: Icons.medical_services_outlined,
            title: "Alerjiler",
            subtitle: "Bilinen cilt alerileriniz var mı?",
            value: hasAllergies,
            onChanged: (v) => setState(() => hasAllergies = v),
          ),
          const SizedBox(height: 12),
          InfoCardSwitch(
            icon: Icons.local_pharmacy_outlined,
            title: "İlaçlar",
            subtitle: "Düzenli kullandığınız ilaçlar var mı?",
            value: takesMeds,
            onChanged: (v) => setState(() => takesMeds = v),
          ),
          const SizedBox(height: 12),
          InfoCardSwitch(
            icon: Icons.family_restroom,
            title: "Aile Geçmişi",
            subtitle: "Ailede cilt hastalığı geçmişi var mı?",
            value: hasFamilyHistory,
            onChanged: (v) => setState(() => hasFamilyHistory = v),
          ),
        ],
      ),
    );
  }
}
