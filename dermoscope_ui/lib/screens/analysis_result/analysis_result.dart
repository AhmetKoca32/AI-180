import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/api_service.dart';
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
    final String? imagePath = ModalRoute.of(context)?.settings.arguments as String?;
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() => _isLoading = true);
      final result = await ApiService.sendImageForDiagnosis(imagePath);
      setState(() {
        _isLoading = false;
        if (result != null) {
          // Sadece hastalık bilgisini güncelle
          analysisData['detectedConditions'] = [
            {
              'id': result['class_code'] ?? '',
              'name': result['class_name_tr'] ?? '',
              'type': result['class_code'] ?? '',
              "confidence": 92.3,
              "severity": "Orta Şiddetli",
              "affectedArea": 15.2,
              "description":
                  "Yüz bölgesinde orta şiddetli akne lezyonları tespit edildi.",
              "medicalTerms": ["Komedonal akne", "İnflamatuar papüller"],
              "isExpanded": false,
            }
          ];
        }
      });
    }
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

  void _retryAnalysis() {
    Navigator.pushReplacementNamed(context, '/camera-capture');
  }

  @override
  Widget build(BuildContext context) {
    final String? imagePath =
        ModalRoute.of(context)?.settings.arguments as String?;
    print('AnalysisResults build method called');
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
      body: analysisData.isEmpty
          ? _buildErrorState()
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              'Analiz Başarısız',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Görüntü analizi sırasında bir hata oluştu. Lütfen tekrar deneyin veya daha net bir görüntü çekin.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _retryAnalysis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tekrar Dene',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/dashboard'),
              child: Text(
                'Ana Sayfaya Dön',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
