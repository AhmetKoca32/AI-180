import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AnalysisSummaryCardWidget extends StatelessWidget {
  final List<Map<String, dynamic>> analyses;
  final Function(Map<String, dynamic>) onTap;

  const AnalysisSummaryCardWidget({
    super.key,
    required this.analyses,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'iyi':
        return AppTheme.successLight;
      case 'orta':
        return AppTheme.warningLight;
      case 'kötü':
        return AppTheme.errorLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (analyses.isEmpty) {
      return Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Henüz analiz yok',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'İlk cilt analizinizi yapmak için kamera butonuna dokunun',
              style: AppTheme.lightTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 2.w, bottom: 2.h),
            child: Text(
              'Son Analizler',
              style: AppTheme.lightTheme.textTheme.titleLarge,
            ),
          ),
          SizedBox(
            height: 20.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: analyses.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                final analysis = analyses[index];
                return GestureDetector(
                  onTap: () => onTap(analysis),
                  onLongPress: () => _showContextMenu(context, analysis),
                  child: Container(
                    width: 70.w,
                    margin: EdgeInsets.only(right: 4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 90, // Görsel yüksekliği, gerekirse ayarla
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: CustomImageWidget(
                              imageUrl: analysis["thumbnail"] as String,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: 80, // İçerik yüksekliği artırıldı
                          width: double.infinity,
                          padding: EdgeInsets.all(2.w), // padding azaltıldı
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      analysis["type"] as String,
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .titleSmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        analysis["status"] as String,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      analysis["status"] as String,
                                      style: AppTheme
                                          .lightTheme
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: _getStatusColor(
                                              analysis["status"] as String,
                                            ),
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                analysis["insights"] as String,
                                style: AppTheme.lightTheme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    analysis["date"] as String,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall,
                                  ),
                                  Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName: 'star',
                                        color: AppTheme.warningLight,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(
                                        '${analysis["score"]}',
                                        style: AppTheme
                                            .lightTheme
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ],
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
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context, Map<String, dynamic> analysis) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'visibility',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Detayları Görüntüle'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analysis details
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              title: const Text('Paylaş'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'delete',
                color: AppTheme.errorLight,
                size: 24,
              ),
              title: const Text('Sil'),
              onTap: () {
                Navigator.pop(context);
                // Delete functionality
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
