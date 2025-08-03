import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:dermoscope_ui/screens/analysis_result/new_analysis_result.dart';
import 'package:dermoscope_ui/services/api_service.dart' as api_service;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HairAnalysisForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onAnalysisComplete;

  const HairAnalysisForm({Key? key, required this.onAnalysisComplete})
    : super(key: key);

  @override
  _HairAnalysisFormState createState() => _HairAnalysisFormState();
}

class _HairAnalysisFormState extends State<HairAnalysisForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    'stress_level': TextEditingController(),
    'body_water_content': TextEditingController(),
    'total_protein': TextEditingController(),
    'total_keratine': TextEditingController(),
    'iron': TextEditingController(),
    'calcium': TextEditingController(),
    'vitamin': TextEditingController(),
    'manganese': TextEditingController(),
    'liver_data': TextEditingController(),
    'hair_texture': TextEditingController(
      text: '3',
    ), // Default to middle value (3)
  };

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.lightBackground,
            Colors.white,
            AppColors.lightBackground.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Header Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detaylı Saç Analizi',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Daha doğru sonuçlar için lütfen aşağıdaki bilgileri doldurunuz.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Section
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildNumberField(
                    'Stres Seviyesi (0-10)',
                    'stress_level',
                    icon: Icons.emoji_emotions_outlined,
                    min: 0,
                    max: 10,
                    isInteger: true,
                    hint: '0-10 arası değer giriniz',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Vücut Su Oranı (%)',
                    'body_water_content',
                    icon: Icons.water_drop_outlined,
                    min: 0,
                    max: 100,
                    hint: '0-100 arası yüzde giriniz (örn: 60)',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Toplam Protein (g/dL)',
                    'total_protein',
                    icon: Icons.biotech_outlined,
                    min: 0,
                    hint: 'Örn: 7.0',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Keratin Seviyesi (mg/dL)',
                    'total_keratine',
                    icon: Icons.auto_awesome_outlined,
                    min: 0,
                    hint: 'Örn: 0.9',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Demir Seviyesi (µg/dL)',
                    'iron',
                    icon: Icons.bloodtype_outlined,
                    min: 0,
                    hint: 'Örn: 80',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Kalsiyum Seviyesi (mg/dL)',
                    'calcium',
                    icon: Icons.egg_outlined,
                    min: 0,
                    hint: 'Örn: 9.5',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'D Vitamini Seviyesi (ng/mL)',
                    'vitamin',
                    icon: Icons.medication_outlined,
                    min: 0,
                    hint: 'Örn: 30',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Mangan Seviyesi (µg/L)',
                    'manganese',
                    icon: Icons.science_outlined,
                    min: 0,
                    hint: 'Örn: 1.5',
                  ),
                  const SizedBox(height: 16),
                  _buildNumberField(
                    'Karaciğer Fonksiyon Testi (AST/ALT)',
                    'liver_data',
                    icon: Icons.health_and_safety_outlined,
                    min: 0,
                    hint: 'Örn: 1.1',
                  ),
                  const SizedBox(height: 20),
                  _buildSliderField(
                    'Saç Dokusu (İnce - Kalın)',
                    'hair_texture',
                  ),
                  const SizedBox(height: 32),

                  // Enhanced Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Analiz Yapılıyor...',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Analizi Tamamla',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    String key, {
    required IconData icon,
    double? min,
    double? max,
    bool isInteger = false,
    String? hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: _controllers[key],
        keyboardType: isInteger
            ? TextInputType.number
            : const TextInputType.numberWithOptions(decimal: true),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.border.withOpacity(0.5),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.warning, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Bu alan zorunludur';
          }

          final numVal = isInteger
              ? int.tryParse(value)
              : double.tryParse(value.replaceAll(',', '.'));

          if (numVal == null) {
            return 'Geçerli bir sayı girin';
          }

          if (isInteger && !value.contains('.') && !value.contains(',')) {
            // Integer validation
            if (min != null && numVal < min) {
              return 'En az ${min.toInt()} olmalı';
            }
            if (max != null && numVal > max) {
              return 'En fazla ${max.toInt()} olabilir';
            }
          } else {
            // Double validation
            if (min != null && numVal < min) {
              return 'En az $min olmalı';
            }
            if (max != null && numVal > max) {
              return 'En fazla $max olabilir';
            }
          }

          return null;
        },
        inputFormatters: [
          if (isInteger) FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }

  Widget _buildSliderField(String label, String key) {
    final currentValue = double.tryParse(_controllers[key]!.text) ?? 3.0;
    final value = currentValue.clamp(1.0, 5.0);
    final intValue = value.round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            AppColors.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                child: Icon(Icons.tune, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border.withOpacity(0.3),
              trackHeight: 6,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              thumbShape: RoundSliderThumbShape(
                enabledThumbRadius: 12,
                elevation: 4,
              ),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: AppColors.primary,
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              label: value.round().toString(),
              onChanged: (newValue) {
                setState(() {
                  final clampedValue = newValue.clamp(1.0, 5.0);
                  _controllers[key]!.text = clampedValue.toStringAsFixed(1);
                  print('Slider value changed to: ${_controllers[key]!.text}');
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSliderLabel('1', 'Çok Kötü', intValue == 1),
                _buildSliderLabel('2', 'Kötü', intValue == 2),
                _buildSliderLabel('3', 'Orta', intValue == 3),
                _buildSliderLabel('4', 'İyi', intValue == 4),
                _buildSliderLabel('5', 'Çok İyi', intValue == 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderLabel(String value, String label, bool isSelected) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  bool _isLoading = false;

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Debug: Print all form values
    print('Form values before processing:');
    _controllers.forEach((key, controller) {
      print('$key: ${controller.text}');
    });

    try {
      setState(() {
        _isLoading = true;
      });

      // Parse and log hair texture value
      final hairTextureText = _controllers['hair_texture']!.text;
      print('Hair texture text: "$hairTextureText"');
      final hairTextureValue = double.tryParse(hairTextureText) ?? 3.0;
      print('Parsed hair texture value: $hairTextureValue');

      final formData = {
        'stress_level': double.parse(_controllers['stress_level']!.text),
        'body_water_content': double.parse(
          _controllers['body_water_content']!.text.replaceAll(',', '.'),
        ),
        'total_protein': double.parse(
          _controllers['total_protein']!.text.replaceAll(',', '.'),
        ),
        'total_keratine': double.parse(
          _controllers['total_keratine']!.text.replaceAll(',', '.'),
        ),
        'iron': double.parse(_controllers['iron']!.text.replaceAll(',', '.')),
        'calcium': double.parse(
          _controllers['calcium']!.text.replaceAll(',', '.'),
        ),
        'vitamin': double.parse(
          _controllers['vitamin']!.text.replaceAll(',', '.'),
        ),
        'manganese': double.parse(
          _controllers['manganese']!.text.replaceAll(',', '.'),
        ),
        'liver_data': double.parse(
          _controllers['liver_data']!.text.replaceAll(',', '.'),
        ),
        'hair_texture': hairTextureValue,
      };

      // Show loading indicator
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      // Call the API with form data
      try {
        print('Form verileri gönderiliyor...');
        print('Gönderilen veriler: $formData');

        final result = await api_service.ApiService.submitHairAnalysis(
          formData,
        );
        print('API yanıtı alındı: $result');

        if (mounted) {
          print('Yeni analiz sayfasına yönlendiriliyor...');
          // Navigate to analysis results page with the API response
          await Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) {
                print('NewAnalysisResult oluşturuluyor...');
                return NewAnalysisResult(
                  analysisData: result,
                  isHairAnalysis: true,
                );
              },
            ),
          );
          print('Yönlendirme tamamlandı');
        }
      } catch (e, stackTrace) {
        print('API çağrısı sırasında hata oluştu:');
        print('Hata: $e');
        print('Stack trace: $stackTrace');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Analiz sırasında hata oluştu: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        rethrow;
      }
    } catch (e) {
      print('Error submitting hair analysis: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analiz sırasında hata oluştu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
