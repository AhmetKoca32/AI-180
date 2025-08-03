import 'dart:io';

import 'package:dermoscope_ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NewAnalysisResult extends StatefulWidget {
  final Map<String, dynamic>? analysisData;
  final String? imagePath;
  final bool isHairAnalysis;

  const NewAnalysisResult({
    Key? key,
    this.analysisData,
    this.imagePath,
    this.isHairAnalysis = false,
  }) : super(key: key);

  @override
  State<NewAnalysisResult> createState() => _NewAnalysisResultState();
}

class _NewAnalysisResultState extends State<NewAnalysisResult> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  late Map<String, dynamic> _analysisData;

  @override
  void initState() {
    super.initState();
    print('NewAnalysisResult initState çağrıldı');
    print('Gelen veriler: ${widget.analysisData}');
    _initializeData();
    print('Veri yapısı başarıyla yüklendi');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeData() {
    print('_initializeData çağrıldı');
    try {
      _analysisData = widget.analysisData ?? _getDefaultAnalysisData();
      print('Analiz verileri yüklendi: ${_analysisData.keys.toList()}');

      // Eğer saç analizi ise, veri yapısını kontrol et
      if (widget.isHairAnalysis) {
        print('Saç analizi verileri:');
        print('  - analysis: ${_analysisData['analysis'] != null}');
        print(
          '  - hair_health_score: ${_analysisData['analysis']?['hair_health_score']}',
        );
        print(
          '  - recommendations: ${_analysisData['analysis']?['recommendations']}',
        );
      }
    } catch (e, stackTrace) {
      print('_initializeData hatası: $e');
      print('Stack trace: $stackTrace');
      _analysisData = _getDefaultAnalysisData();
    }
  }

  Map<String, dynamic> _getDefaultAnalysisData() {
    return {
      'analysisId': 'ANALYSIS_${DateTime.now().millisecondsSinceEpoch}',
      'timestamp': DateTime.now().toIso8601String(),
      'confidenceScore': 0.0,
      'detectedConditions': [
        {
          'name': 'Analiz Sonucu',
          'confidence': 0.0,
          'description': 'Analiz sonuçları yükleniyor...',
          'severity': 'Bilinmiyor',
        },
      ],
      'recommendations': {
        'lifestyle': [],
        'skincare': [],
        'timeline': 'Analiz ediliyor...',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          widget.isHairAnalysis
              ? 'Saç Analiz Sonuçları'
              : 'Cilt Analiz Sonuçları',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.share_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    print('_buildBody çağrıldı');
    if (_isLoading) {
      print('Yükleniyor gösteriliyor');
      return Container(
        color: AppColors.lightBackground,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Analiz sonuçları hazırlanıyor...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    print('Analiz verileri:');
    print(_analysisData.toString());

    return Container(
      color: AppColors.lightBackground,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.imagePath != null) _buildImageSection(),
            const SizedBox(height: 16),
            _buildAnalysisSummary(),
            const SizedBox(height: 16),
            _buildDetectedConditions(),
            const SizedBox(height: 16),
            _buildRecommendations(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.file(
              widget.imagePath != null ? File(widget.imagePath!) : File(''),
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Resim yüklenemedi',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.isHairAnalysis ? 'Saç Analizi' : 'Cilt Analizi',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisSummary() {
    print('_buildAnalysisSummary çağrıldı');
    final bool isHairAnalysis = widget.isHairAnalysis;
    print('isHairAnalysis: $isHairAnalysis');

    final hairHealthScore = isHairAnalysis
        ? (_analysisData['analysis']?['hair_health_score'] ?? 0.0) * 100
        : _analysisData['confidenceScore'] ?? 0.0;

    print('hairHealthScore: $hairHealthScore');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.lightBackground],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                child: Icon(
                  isHairAnalysis ? Icons.content_cut : Icons.face,
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
                      isHairAnalysis ? 'Saç Analiz Özeti' : 'Cilt Analiz Özeti',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Analiz Tarihi: ${_formatDate(_analysisData['timestamp'])}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Health Score Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getHealthScoreColor(hairHealthScore / 100).withOpacity(0.1),
                  _getHealthScoreColor(hairHealthScore / 100).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getHealthScoreColor(
                  hairHealthScore / 100,
                ).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sağlık Skoru',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '${hairHealthScore.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: _getHealthScoreColor(hairHealthScore / 100),
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: hairHealthScore / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getHealthScoreColor(hairHealthScore / 100),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  _getHealthScoreDescription(hairHealthScore / 100),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          if (isHairAnalysis) ...[
            const SizedBox(height: 20),
            ..._buildHairNutrientScores(),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildHairNutrientScores() {
    final nutrientScores =
        _analysisData['analysis']?['nutrient_scores'] as Map<String, dynamic>?;
    if (nutrientScores == null || nutrientScores.isEmpty) {
      return [];
    }

    return [
      Text(
        'Besin Değerleri',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      const SizedBox(height: 16),
      ...nutrientScores.entries
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getNutrientName(entry.key),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${(entry.value * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: _getHealthScoreColor(entry.value.toDouble()),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: entry.value.toDouble(),
                    backgroundColor: Colors.grey[200],
                    color: _getHealthScoreColor(entry.value.toDouble()),
                    minHeight: 6,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ];
  }

  String _getNutrientName(String key) {
    switch (key) {
      case 'protein':
        return 'Protein';
      case 'iron':
        return 'Demir';
      case 'vitamins':
        return 'Vitaminler';
      case 'hydration':
        return 'Hidrasyon';
      default:
        return key;
    }
  }

  Color _getHealthScoreColor(double score) {
    if (score >= 0.7) return Colors.green;
    if (score >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _getHealthScoreDescription(double score) {
    if (score >= 0.8) {
      return 'Mükemmel! Sağlık durumunuz çok iyi.';
    } else if (score >= 0.6) {
      return 'İyi! Küçük iyileştirmelerle daha da iyi olabilir.';
    } else if (score >= 0.4) {
      return 'Orta seviye. Önerileri dikkate alarak iyileştirebilirsiniz.';
    } else {
      return 'Dikkat! Önerileri uygulayarak sağlığınızı iyileştirin.';
    }
  }

  Widget _buildDetectedConditions() {
    List<dynamic> conditions = [];

    if (widget.isHairAnalysis) {
      // For hair analysis, create a condition from the analysis data
      final analysis = _analysisData['analysis'];
      if (analysis != null) {
        conditions = [
          {
            'name': 'Saç Sağlık Durumu',
            'confidence': (analysis['hair_health_score'] ?? 0.0) * 100,
            'description': _getHairHealthDescription(
              analysis['hair_health_score'] ?? 0.0,
            ),
            'severity': _getHairHealthSeverity(
              analysis['hair_health_score'] ?? 0.0,
            ),
          },
        ];
      }
    } else {
      // For skin analysis, use the detected conditions
      conditions = _analysisData['detectedConditions'] as List? ?? [];
    }

    if (conditions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Tespit Edilen Durumlar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...conditions.map((condition) => _buildConditionCard(condition)),
      ],
    );
  }

  Widget _buildConditionCard(Map<String, dynamic> condition) {
    final confidence = (condition['confidence'] ?? 0.0).toDouble();
    final severity = condition['severity'] ?? 'Bilinmiyor';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.3), width: 1),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getSeverityColor(severity).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getSeverityIcon(severity),
            color: _getSeverityColor(severity),
            size: 20,
          ),
        ),
        title: Text(
          condition['name'] ?? 'Bilinmeyen Durum',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    severity,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Güven: ${confidence.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightBackground.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              condition['description'] ?? 'Açıklama bulunamadı',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'çok iyi':
      case 'iyi':
        return Colors.green;
      case 'orta':
        return Colors.orange;
      case 'kötü':
      case 'iyileştirilmeli':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'çok iyi':
      case 'iyi':
        return Icons.check_circle_outline;
      case 'orta':
        return Icons.info_outline;
      case 'kötü':
      case 'iyileştirilmeli':
        return Icons.warning_amber_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getHairHealthDescription(double score) {
    if (score >= 0.8) {
      return 'Saçlarınız çok sağlıklı görünüyor. Bu durumu korumak için düzenli bakım yapmaya devam edin.';
    } else if (score >= 0.5) {
      return 'Saçlarınız orta düzeyde sağlıklı. Beslenme ve bakım rutininizi iyileştirerek daha iyi sonuçlar elde edebilirsiniz.';
    } else {
      return 'Saçlarınız daha fazla bakıma ihtiyaç duyuyor. Aşağıdaki önerileri dikkate alarak saç sağlığınızı iyileştirebilirsiniz.';
    }
  }

  String _getHairHealthSeverity(double score) {
    if (score >= 0.8) return 'Çok İyi';
    if (score >= 0.5) return 'Orta';
    return 'İyileştirilmeli';
  }

  Widget _buildRecommendations() {
    Map<String, dynamic> recommendations = {};

    if (widget.isHairAnalysis) {
      // For hair analysis, format the recommendations from analysis data
      final analysis = _analysisData['analysis'];
      if (analysis != null) {
        recommendations = {
          'lifestyle': analysis['recommendations'] ?? [],
          'skincare': [],
          'timeline':
              'Düzenli bakım ile 4-8 hafta içinde iyileşme gözlemlenebilir.',
        };
      }
    } else {
      // For skin analysis, use the recommendations as is
      recommendations = _analysisData['recommendations'] ?? {};
    }
    final lifestyle = recommendations['lifestyle'] as List? ?? [];
    final skincare = recommendations['skincare'] as List? ?? [];
    final timeline = recommendations['timeline'] as String?;

    if (lifestyle.isEmpty && skincare.isEmpty && timeline == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, AppColors.lightBackground],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Öneriler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (lifestyle.isNotEmpty)
            _buildRecommendationList(
              'Yaşam Tarzı',
              lifestyle,
              Icons.fitness_center,
            ),
          if (skincare.isNotEmpty)
            _buildRecommendationList('Cilt Bakımı', skincare, Icons.face),
          if (timeline != null) _buildTimeline(timeline),
        ],
      ),
    );
  }

  Widget _buildRecommendationList(
    String title,
    List<dynamic> items,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items
              .asMap()
              .entries
              .map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTimeline(String timeline) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.schedule, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahmini İyileşme Süresi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  timeline,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Bilinmiyor';
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }
}
