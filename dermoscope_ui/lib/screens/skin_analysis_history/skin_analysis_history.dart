import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/analysis_history_card_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/timeline_section_header_widget.dart';

class SkinAnalysisHistory extends StatefulWidget {
  const SkinAnalysisHistory({Key? key}) : super(key: key);

  @override
  State<SkinAnalysisHistory> createState() => _SkinAnalysisHistoryState();
}

class _SkinAnalysisHistoryState extends State<SkinAnalysisHistory>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = false;
  bool _isMultiSelectMode = false;
  List<String> _selectedAnalyses = [];
  String _searchQuery = '';
  String _selectedFilter = 'Tümü';
  DateTimeRange? _selectedDateRange;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> _analysisHistory = [
    {
      "id": "analysis_001",
      "date": DateTime(2025, 7, 15, 14, 30),
      "thumbnail":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop",
      "bodyArea": "Yüz",
      "detectedConditions": ["Akne", "Kızarıklık"],
      "confidenceScore": 0.87,
      "analysisType": "Cilt Analizi",
      "severity": "Orta",
      "recommendations": 3,
      "month": "Temmuz 2025",
    },
    {
      "id": "analysis_002",
      "date": DateTime(2025, 7, 12, 10, 15),
      "thumbnail":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop",
      "bodyArea": "Saç Derisi",
      "detectedConditions": ["Saç Dökülmesi", "Kepek"],
      "confidenceScore": 0.92,
      "analysisType": "Saç Analizi",
      "severity": "Hafif",
      "recommendations": 5,
      "month": "Temmuz 2025",
    },
    {
      "id": "analysis_003",
      "date": DateTime(2025, 7, 8, 16, 45),
      "thumbnail":
          "https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&h=300&fit=crop",
      "bodyArea": "Kol",
      "detectedConditions": ["Egzama", "Kuruluk"],
      "confidenceScore": 0.78,
      "analysisType": "Cilt Analizi",
      "severity": "Yüksek",
      "recommendations": 4,
      "month": "Temmuz 2025",
    },
    {
      "id": "analysis_004",
      "date": DateTime(2025, 6, 28, 9, 20),
      "thumbnail":
          "https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=400&h=300&fit=crop",
      "bodyArea": "Yüz",
      "detectedConditions": ["Melanom Riski"],
      "confidenceScore": 0.65,
      "analysisType": "Risk Değerlendirmesi",
      "severity": "Kritik",
      "recommendations": 1,
      "month": "Haziran 2025",
    },
    {
      "id": "analysis_005",
      "date": DateTime(2025, 6, 25, 13, 10),
      "thumbnail":
          "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop",
      "bodyArea": "Saç Derisi",
      "detectedConditions": ["Sağlıklı"],
      "confidenceScore": 0.95,
      "analysisType": "Rutin Kontrol",
      "severity": "Normal",
      "recommendations": 2,
      "month": "Haziran 2025",
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredAnalyses {
    List<Map<String, dynamic>> filtered = _analysisHistory;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((analysis) {
        final conditions = (analysis['detectedConditions'] as List)
            .join(' ')
            .toLowerCase();
        final bodyArea = (analysis['bodyArea'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return conditions.contains(query) || bodyArea.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'Tümü') {
      filtered = filtered.where((analysis) {
        return (analysis['detectedConditions'] as List).any(
          (condition) => condition.toString().contains(_selectedFilter),
        );
      }).toList();
    }

    if (_selectedDateRange != null) {
      filtered = filtered.where((analysis) {
        final date = analysis['date'] as DateTime;
        return date.isAfter(
              _selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  Map<String, List<Map<String, dynamic>>> get _groupedAnalyses {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final analysis in _filteredAnalyses) {
      final month = analysis['month'] as String;
      if (!grouped.containsKey(month)) {
        grouped[month] = [];
      }
      grouped[month]!.add(analysis);
    }
    return grouped;
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedAnalyses.clear();
      }
    });
  }

  void _toggleAnalysisSelection(String analysisId) {
    setState(() {
      if (_selectedAnalyses.contains(analysisId)) {
        _selectedAnalyses.remove(analysisId);
      } else {
        _selectedAnalyses.add(analysisId);
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedFilter: _selectedFilter,
        selectedDateRange: _selectedDateRange,
        onFilterChanged: (filter) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        onDateRangeChanged: (dateRange) {
          setState(() {
            _selectedDateRange = dateRange;
          });
        },
      ),
    );
  }

  void _deleteSelectedAnalyses() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Analizleri Sil',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          '${_selectedAnalyses.length} analizi silmek istediğinizden emin misiniz?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _analysisHistory.removeWhere(
                  (analysis) => _selectedAnalyses.contains(analysis['id']),
                );
                _selectedAnalyses.clear();
                _isMultiSelectMode = false;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Analizler silindi')),
              );
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  void _exportAnalyses() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_selectedAnalyses.length} analiz PDF olarak dışa aktarılıyor...',
        ),
        action: SnackBarAction(label: 'Görüntüle', onPressed: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        title: _isMultiSelectMode
            ? Text(
                '${_selectedAnalyses.length} seçildi',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              )
            : Text(
                'Analiz Geçmişi',
                style: AppTheme.lightTheme.textTheme.titleLarge,
              ),
        actions: [
          if (_isMultiSelectMode) ...[
            IconButton(
              onPressed: _selectedAnalyses.isNotEmpty ? _exportAnalyses : null,
              icon: CustomIconWidget(
                iconName: 'share',
                color: _selectedAnalyses.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                size: 24,
              ),
            ),
            IconButton(
              onPressed: _selectedAnalyses.isNotEmpty
                  ? _deleteSelectedAnalyses
                  : null,
              icon: CustomIconWidget(
                iconName: 'delete',
                color: _selectedAnalyses.isNotEmpty
                    ? AppTheme.lightTheme.colorScheme.error
                    : AppTheme.lightTheme.colorScheme.onSurface.withValues(
                        alpha: 0.5,
                      ),
                size: 24,
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                setState(() {
                  _isGridView = !_isGridView;
                });
              },
              icon: CustomIconWidget(
                iconName: _isGridView ? 'view_list' : 'grid_view',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
            IconButton(
              onPressed: _showFilterBottomSheet,
              icon: CustomIconWidget(
                iconName: 'filter_list',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            ),
          ],
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Search Bar
            if (!_isMultiSelectMode)
              Container(
                margin: EdgeInsets.all(4.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Analiz ara...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: AppTheme.lightTheme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),

            // Content
            Expanded(
              child: _filteredAnalyses.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(seconds: 1));
                        setState(() {});
                      },
                      child: _isGridView ? _buildGridView() : _buildListView(),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? FloatingActionButton(
              onPressed: _toggleMultiSelectMode,
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => Navigator.pushNamed(context, '/camera-capture'),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.3,
            ),
            size: 80,
          ),
          SizedBox(height: 3.h),
          Text(
            'Henüz analiz yok',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'İlk cilt analizinizi yapmak için\nkamera butonuna dokunun',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/camera-capture'),
            icon: CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              size: 20,
            ),
            label: const Text('Analiz Başlat'),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      itemCount: _groupedAnalyses.length,
      itemBuilder: (context, index) {
        final monthKey = _groupedAnalyses.keys.elementAt(index);
        final monthAnalyses = _groupedAnalyses[monthKey]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TimelineSectionHeaderWidget(
              month: monthKey,
              analysisCount: monthAnalyses.length,
            ),
            SizedBox(height: 2.h),
            ...monthAnalyses
                .map(
                  (analysis) => Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: AnalysisHistoryCardWidget(
                      analysis: analysis,
                      isSelected: _selectedAnalyses.contains(analysis['id']),
                      isMultiSelectMode: _isMultiSelectMode,
                      onTap: () {
                        if (_isMultiSelectMode) {
                          _toggleAnalysisSelection(analysis['id']);
                        } else {
                          print('Navigating to analysis-results...');
                          Navigator.pushNamed(context, '/analysis-results');
                        }
                      },
                      onLongPress: () {
                        if (!_isMultiSelectMode) {
                          _toggleMultiSelectMode();
                          _toggleAnalysisSelection(analysis['id']);
                        }
                      },
                      onDelete: () {
                        setState(() {
                          _analysisHistory.removeWhere(
                            (item) => item['id'] == analysis['id'],
                          );
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Analiz silindi')),
                        );
                      },
                      onShare: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Analiz paylaşılıyor...'),
                          ),
                        );
                      },
                    ),
                  ),
                )
                .toList(),
            SizedBox(height: 2.h),
          ],
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: EdgeInsets.all(4.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.65, // was 0.7, now even more vertical space
      ),
      itemCount: _filteredAnalyses.length,
      itemBuilder: (context, index) {
        final analysis = _filteredAnalyses[index];
        return AnalysisHistoryCardWidget(
          analysis: analysis,
          isSelected: _selectedAnalyses.contains(analysis['id']),
          isMultiSelectMode: _isMultiSelectMode,
          isGridView: true,
          onTap: () {
            if (_isMultiSelectMode) {
              _toggleAnalysisSelection(analysis['id']);
            } else {
              print('Navigating to analysis-results from grid...');
              Navigator.pushNamed(context, '/analysis-results');
            }
          },
          onLongPress: () {
            if (!_isMultiSelectMode) {
              _toggleMultiSelectMode();
              _toggleAnalysisSelection(analysis['id']);
            }
          },
          onDelete: () {
            setState(() {
              _analysisHistory.removeWhere(
                (item) => item['id'] == analysis['id'],
              );
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Analiz silindi')));
          },
          onShare: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Analiz paylaşılıyor...')),
            );
          },
        );
      },
    );
  }
}
