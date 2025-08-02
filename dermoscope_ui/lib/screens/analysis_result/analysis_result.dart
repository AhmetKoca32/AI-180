import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/text_utils.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart' as api_service;
import '../../services/exceptions/api_exception.dart';
import './widgets/action_buttons_widget.dart';
import './widgets/analysis_image_widget.dart';
import './widgets/condition_card_widget.dart';
import './widgets/confidence_score_widget.dart';
import './widgets/progress_comparison_widget.dart';
import './widgets/recommendations_widget.dart';
import './widgets/risk_assessment_widget.dart';

class AnalysisResults extends StatefulWidget {
  const AnalysisResults({Key? key}) : super(key: key);

  @override
  State<AnalysisResults> createState() => _AnalysisResultsState();
}

class _AnalysisResultsState extends State<AnalysisResults> {
  bool _isDescriptionLoading = false;
  String? _descriptionError;

  // Metin temizleme fonksiyonu
  String _cleanDescription(String? description) {
    return TextUtils.cleanText(description, fallback: 'Açıklama bulunamadı');
  }

  Future<void> _fetchLLMDescription(String conditionName) async {
    print('Fetching LLM description for: $conditionName');

    if (!mounted) return;
    
    setState(() {
      _isDescriptionLoading = true;
      _descriptionError = null;
    });
    
    try {
      final desc = await api_service.ApiService.getAdvice(
        '$conditionName nedir? kısa 1 cümle ile açıkla, sadece açıklama ver. Ayrıca mesela iki ayrı terim varsa onları tek paragrafda açıkla.',
      );
      
      if (!mounted) return;

      // Create a deep copy of the current state
      final updatedAnalysisData = Map<String, dynamic>.from(analysisData);

      // Update the description in the detected conditions
      if (updatedAnalysisData['detectedConditions'] != null &&
          (updatedAnalysisData['detectedConditions'] as List).isNotEmpty) {
        final updatedConditions = List<Map<String, dynamic>>.from(
          updatedAnalysisData['detectedConditions'],
        );

        if (updatedConditions.isNotEmpty) {
          updatedConditions[0] = Map<String, dynamic>.from(updatedConditions[0])
            ..['description'] = _cleanDescription(desc);
          updatedAnalysisData['detectedConditions'] = updatedConditions;

          // Update the state with the new data
          setState(() {
            analysisData.clear();
            analysisData.addAll(updatedAnalysisData);
            _isDescriptionLoading = false;
            print('Updated analysisData with description');
          });
        }
      }
    } catch (e) {
      print('Error fetching LLM description: $e');
      if (mounted) {
        setState(() {
          _descriptionError =
              'Açıklama alınamadı: ' +
              (e is Exception ? e.toString() : 'Bilinmeyen hata');
          _isDescriptionLoading = false;
        });
      }
    }
  }

  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Mock analysis data
  final Map<String, dynamic> analysisData = {
    "analysisId": "DRM_2025071515_001",
    "timestamp": "2025-07-15T15:04:09.752295",
    "analyzedImage":
        "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=800&h=600&fit=crop",
    "confidenceScore": 87.5,
    "overallRiskLevel": "moderate", // low, moderate, high
    "detectedConditions": [
      {
        "id": "acne_001",
        "name": "Akne Vulgaris",
        "type": "acne",
        "confidence": 92.3,
        "severity": "Orta Şiddetli",
        "affectedArea": 15.2,
        "description":
            "Yüz bölgesinde orta şiddetli akne lezyonları tespit edildi.",
        "medicalTerms": ["Komedonal akne", "İnflamatuar papüller"],
        "isExpanded": false,
      },
    ],
    "recommendations": {
      "skincare": [
        {
          "category": "Temizlik",
          "products": [
            "Salisilik asit içeren temizleyici",
            "Nazik köpük temizleyici",
          ],
          "frequency": "Günde 2 kez",
          "duration": "4-6 hafta",
        },
        {
          "category": "Tedavi",
          "products": ["Benzoil peroksit %2.5", "Niasinamid serum"],
          "frequency": "Akşam uygulaması",
          "duration": "8-12 hafta",
        },
        {
          "category": "Nemlendirme",
          "products": ["Yağsız nemlendirici", "Hyaluronik asit serum"],
          "frequency": "Günde 2 kez",
          "duration": "Sürekli kullanım",
        },
      ],
      "lifestyle": [
        "Günlük güneş koruyucu kullanımı (SPF 30+)",
        "Düzenli uyku (7-8 saat)",
        "Stres yönetimi teknikleri",
        "Dengeli beslenme programı",
      ],
      "timeline":
          "İlk iyileşme belirtileri 2-3 hafta içinde görülecektir. Tam sonuç için 8-12 hafta sürekli kullanım gereklidir.",
    },
    "previousAnalysis": {
      "date": "2025-06-15",
      "confidenceScore": 82.1,
      "overallRiskLevel": "moderate",
      "imageUrl":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop",
      "improvementPercentage": 12.3,
    },
  };

  @override
  void initState() {
    super.initState();
    _triggerHapticFeedback();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchDiagnosisIfNeeded());
  }

  Future<void> _fetchDiagnosisIfNeeded() async {
    String? imagePath;
    String? captureType;

    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      
      if (args is Map) {
        imagePath = args['imagePath'] as String?;
        captureType = args['captureType'] as String?;
      } else if (args is String) {
        imagePath = args;
      }

      if (imagePath == null || imagePath.isEmpty) {
        throw Exception('Analiz için bir resim bulunamadı');
      }

      setState(() => _isLoading = true);
      
      String modelName = 'skin_canser_model.h5';
      if (captureType == 'hair') {
        modelName = 'hair_model.h5';
      } else if (captureType == 'scalp' || captureType == 'other') {
        modelName = 'other_model.h5';
      }

      print('Analiz için model seçildi: $modelName');

      Map<String, dynamic>? result;
      String conditionName = 'Bilinmeyen Durum';
      double confidence = 92.3;

      try {
        // API'den sonuç al
        result = await api_service.ApiService.sendImageForDiagnosis(
          imagePath,
          modelName: modelName,
        );

        if (!mounted) return;
        print('API Yanıtı: $result');
        
        if (result == null) {
          throw Exception('API yanıtı boş döndü');
        }

        // Hata kontrolü
        if (result['error'] != null) {
          throw Exception(result['error']);
        }

        // Handle Gemini API response or regular result
        if (result['llm_result'] is Map) {
          // If llm_result is an object, extract and clean the diagnosis
          final llmResult = result['llm_result'] as Map;
          
          // Try to get diagnosis from different possible fields
          conditionName = TextUtils.cleanText(
            llmResult['diagnosis']?.toString() ?? 
            llmResult['name']?.toString() ??
            result['class_name_tr']?.toString(),
            fallback: 'Bilinmeyen Durum'
          );
          
          // Clean up any remaining JSON-like structures
          conditionName = conditionName.replaceAll(RegExp(r'"|\[\]'), '').trim();
        } else if (result['llm_result'] is String) {
          // If llm_result is a string, clean it up
          conditionName = TextUtils.cleanLlmResponse(
            result['llm_result']?.toString()
          );
        } else {
          // Fallback to class_name_tr if available
          conditionName = TextUtils.cleanText(
            result['class_name_tr']?.toString(),
            fallback: 'Bilinmeyen Durum'
          );
        }

        // Güven skorunu hesapla
        if (result['confidence'] != null) {
          confidence = (result['confidence'] is double)
              ? (result['confidence'] * 100).clamp(0, 100)
              : (double.tryParse(result['confidence'].toString()) ?? 0).clamp(0, 100);
        }

        print('Durum adı: $conditionName, Güven: $confidence%');

        // Create a deep copy of analysisData to ensure state updates work correctly
        final updatedAnalysisData = Map<String, dynamic>.from(analysisData);

        // Create the condition data with all required fields
        final conditionData = {
          'id': result['class_code']?.toString() ?? 'unknown',
          'name': conditionName,
          'type': result['class_code']?.toString() ?? 'unknown',
          'confidence': confidence,
          'severity': result['llm_result']?['severity']?.toString() ?? 'Orta',
          'affectedArea': 15.2,
          'description': TextUtils.cleanLlmResponse(
                          result['llm_result']?['description']?.toString() ??
                          result['llm_result']?.toString()
                        ) ?? 'Analiz tamamlandı. Detaylar yükleniyor...',
          'medicalTerms': [],
          'isExpanded': true,
        };
        
        // Eğer llm_result bir string ise, onu description olarak kullan
        if (result['llm_result'] is String) {
          conditionData['description'] = TextUtils.cleanLlmResponse(
            result['llm_result']?.toString()
          );
        }

        // Update the analysis data
        updatedAnalysisData['detectedConditions'] = [conditionData];
        updatedAnalysisData['confidenceScore'] = confidence;
        updatedAnalysisData['analyzedImage'] = imagePath;

        // Add missing fields if they don't exist
        updatedAnalysisData['overallRiskLevel'] = updatedAnalysisData['overallRiskLevel'] ?? 'moderate';
        updatedAnalysisData['timestamp'] = updatedAnalysisData['timestamp'] ?? DateTime.now().toIso8601String();

        // Update the state with the new data
        if (mounted) {
          setState(() {
            analysisData.clear();
            analysisData.addAll(updatedAnalysisData);
            _isLoading = false;
          });

          // Debug prints
          print('Updated analysisData: $analysisData');
          print('Condition data: ${analysisData['detectedConditions']}');

          // Fetch the LLM description after the UI has updated
          _fetchLLMDescription(conditionName);
        }
      } on ApiException catch (e) {
        print('API Hatası: ${e.statusCode} - ${e.message}');
        String errorMessage;
        bool isWarning = false;
        
        // Map backend errors to user-friendly messages
        switch (e.statusCode) {
          case 429:
            errorMessage = 'Çok fazla istek gönderdiniz. Lütfen 1 saat sonra tekrar deneyin.';
            isWarning = true;
            break;
          case 500:
            errorMessage = 'Sistem şu anda meşgul. Lütfen daha sonra tekrar deneyin.';
            break;
          case 0:
            errorMessage = 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
            isWarning = true;
            break;
          case 400:
            errorMessage = 'Geçersiz istek. Lütfen uygulamayı güncelleyin.';
            break;
          case 401:
          case 403:
            errorMessage = 'Yetkilendirme hatası. Lütfen uygulamayı yeniden başlatın.';
            break;
          case 404:
            errorMessage = 'İstenen kaynak bulunamadı. Lütfen uygulamayı güncelleyin.';
            break;
          case 503:
            errorMessage = 'Sistem bakımda. Lütfen daha sonra tekrar deneyin.';
            isWarning = true;
            break;
          default:
            errorMessage = 'Beklenmeyen bir hata oluştu. Lütfen daha sonra tekrar deneyin.';
        }
        
        _showError(errorMessage, isWarning: isWarning);
      } on FormatException catch (e) {
        print('Veri formatı hatası: $e');
        _showError('Geçersiz veri alındı. Lütfen farklı bir resim ile tekrar deneyin.');
      } on TimeoutException catch (e) {
        print('Zaman aşımı hatası: $e');
        _showError('İşlem çok uzun sürdü. Lütfen internet bağlantınızı kontrol edip tekrar deneyin.', isWarning: true);
      } catch (e) {
        print('Beklenmeyen hata: $e');
        _showError('Beklenmeyen bir hata oluştu. Lütfen uygulamayı kapatıp tekrar açın.');
      }
    } on SocketException catch (e) {
      print('Ağ hatası: $e');
      _showError('İnternet bağlantınız yok. Lütfen bağlantınızı kontrol edip tekrar deneyin.', isWarning: true);
    } catch (e) {
      print('Beklenmeyen hata: $e');
      _showError('Beklenmeyen bir hata oluştu. Lütfen uygulamayı kapatıp tekrar açın.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  void _showError(String message, {bool isWarning = false}) {
    if (!mounted) return;
    
    // Remove any technical details that might be after a colon
    final cleanMessage = message.split(':').first.trim();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cleanMessage,
          style: TextStyle(color: isWarning ? Colors.orange : Colors.white),
        ),
        backgroundColor: isWarning ? Colors.orange.withOpacity(0.1) : Colors.red[800],
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _triggerHapticFeedback() {
    final riskLevel = analysisData["overallRiskLevel"] as String;
    if (riskLevel == "high") {
      HapticFeedback.heavyImpact();
    } else if (riskLevel == "moderate") {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _shareAnalysis() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate PDF generation and sharing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz raporu başarıyla paylaşıldı'),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    }
  }

  void _saveToHistory() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analiz geçmişe kaydedildi'),
          backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        ),
      );
    }
  }

  void _consultSpecialist() {
    Navigator.pushNamed(context, '/chat-consultation');
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? imagePath;
    if (args is String) {
      imagePath = args;
    } else if (args is Map<String, String>) {
      imagePath = args['imagePath'];
    } else {
      imagePath = null;
    }

    // Debug prints
    print('AnalysisResults build method called');
    print('Current analysisData: $analysisData');
    if (analysisData['detectedConditions'] != null) {
      print('Detected conditions: ${analysisData['detectedConditions']}');
    }
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        title: Text(
          'Analiz Sonuçları',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _shareAnalysis,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  )
                : CustomIconWidget(
                    iconName: 'share',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body:
          analysisData.isEmpty ||
              !analysisData.containsKey('detectedConditions')
          ? _buildLoadingState()
          : SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Analysis Image with AI Overlays
                  AnalysisImageWidget(
                    imageUrl: imagePath ?? analysisData["analyzedImage"],
                    detectedConditions:
                        analysisData["detectedConditions"]
                            as List<Map<String, dynamic>>,
                  ),

                  SizedBox(height: 2.h),

                  // Confidence Score
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ConfidenceScoreWidget(
                      score: analysisData["confidenceScore"] as double,
                      timestamp: analysisData["timestamp"] as String,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Risk Assessment
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: RiskAssessmentWidget(
                      riskLevel: analysisData["overallRiskLevel"] as String,
                      detectedConditions:
                          analysisData["detectedConditions"]
                              as List<Map<String, dynamic>>,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Detected Conditions
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tespit Edilen Durumlar',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    AppTheme.lightTheme.colorScheme.onSurface,
                              ),
                        ),
                        SizedBox(height: 2.h),
                        // LLM'den açıklama alanı
                      
                        ...(analysisData["detectedConditions"]
                                as List<Map<String, dynamic>>)
                            .map(
                              (condition) => Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: ConditionCardWidget(
                                  condition: condition,
                                  onExpansionChanged: (isExpanded) {
                                    setState(() {
                                      condition["isExpanded"] = isExpanded;
                                    });
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Recommendations
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: RecommendationsWidget(
                      recommendations:
                          analysisData["recommendations"]
                              as Map<String, dynamic>,
                      conditionName: analysisData["conditionName"] ?? '',
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Progress Comparison (if available)
                  if (analysisData["previousAnalysis"] != null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: ProgressComparisonWidget(
                        currentAnalysis: analysisData,
                        previousAnalysis:
                            analysisData["previousAnalysis"]
                                as Map<String, dynamic>,
                      ),
                    ),

                  SizedBox(height: 4.h),

                  // Action Buttons
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: ActionButtonsWidget(
                      onSaveToHistory: _saveToHistory,
                      onConsultSpecialist: _consultSpecialist,
                      riskLevel: analysisData["overallRiskLevel"] as String,
                      isLoading: _isLoading,
                    ),
                  ),

                  SizedBox(height: 4.h),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    print('_buildLoadingState called');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Analiz yapılıyor...',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
