import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class RecommendationsWidget extends StatefulWidget {
  final Map<String, dynamic> recommendations;
  final String conditionName;

  const RecommendationsWidget({
    Key? key,
    required this.recommendations,
    required this.conditionName,
  })
    : super(key: key);

  @override
  State<RecommendationsWidget> createState() => _RecommendationsWidgetState();
}

class _RecommendationsWidgetState extends State<RecommendationsWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Her kategori için LLM öneri state'i
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> skincareRecommendations =
        (widget.recommendations["skincare"] as List<dynamic>?)
            ?.cast<Map<String, dynamic>>() ??
        [];
    final List<String> lifestyleRecommendations =
        (widget.recommendations["lifestyle"] as List<dynamic>?)
            ?.cast<String>() ??
        [];
    final String timeline = widget.recommendations["timeline"] as String? ?? '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(5.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'recommend',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Kişiselleştirilmiş Öneriler',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Tab Bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: AppTheme.lightTheme.colorScheme.onPrimary,
              unselectedLabelColor: AppTheme.lightTheme.colorScheme.primary,
              labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
              tabs: const [
                Tab(text: 'Cilt Bakımı'),
                Tab(text: 'Yaşam Tarzı'),
                Tab(text: 'Zaman Çizelgesi'),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Tab Bar View
          SizedBox(
            height: 40.h,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Skincare Tab
                _buildSkincareTab(skincareRecommendations),

                // Lifestyle Tab
                _buildLifestyleTab(lifestyleRecommendations),

                // Timeline Tab
                _buildTimelineTab(timeline),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkincareTab(List<Map<String, dynamic>> recommendations) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: recommendations.map((recommendation) {
          return Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.2,
                  ),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: CustomIconWidget(
                          iconName: _getCategoryIcon(
                            recommendation["category"] as String,
                          ),
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        recommendation["category"] as String,
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                      ),
                    ],
                  ),

                  SizedBox(height: 2.h),

                  // Products
                  Text(
                    'Önerilen Ürünler:',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  ...(recommendation["products"] as List<String>).map((
                    product,
                  ) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 0.5.h),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              product,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 2.h),

                  // Usage Info
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'schedule',
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Kullanım Sıklığı: ${recommendation["frequency"]}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'timer',
                              color: AppTheme.lightTheme.colorScheme.tertiary,
                              size: 16,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              'Süre: ${recommendation["duration"]}',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurface,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLifestyleTab(List<String> recommendations) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: recommendations.map((recommendation) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.3,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: _getLifestyleIcon(recommendation),
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTimelineTab(String timeline) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.tertiaryContainer.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
              alpha: 0.3,
            ),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'timeline',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Text(
                  'Beklenen Zaman Çizelgesi',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            Text(
              timeline,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                height: 1.5,
              ),
            ),

            SizedBox(height: 3.h),

            // Timeline milestones
            _buildTimelineMilestone(
              '1-2 Hafta',
              'İlk değişiklikler gözlemlenmeye başlar',
              'visibility',
            ),
            _buildTimelineMilestone(
              '2-4 Hafta',
              'Belirgin iyileşme görülür',
              'trending_up',
            ),
            _buildTimelineMilestone(
              '6-8 Hafta',
              'Önemli gelişmeler kaydedilir',
              'star',
            ),
            _buildTimelineMilestone(
              '8-12 Hafta',
              'Tam sonuçlar elde edilir',
              'check_circle',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineMilestone(
    String period,
    String description,
    String iconName,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 16,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  period,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'temizlik':
        return 'cleaning_services';
      case 'tedavi':
        return 'medical_services';
      case 'nemlendirme':
        return 'water_drop';
      default:
        return 'category';
    }
  }

  String _getLifestyleIcon(String recommendation) {
    if (recommendation.contains('güneş') || recommendation.contains('SPF')) {
      return 'wb_sunny';
    } else if (recommendation.contains('uyku')) {
      return 'bedtime';
    } else if (recommendation.contains('stres')) {
      return 'self_improvement';
    } else if (recommendation.contains('beslenme')) {
      return 'restaurant';
    } else {
      return 'health_and_safety';
    }
  }
}
