import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final String selectedFilter;
  final DateTimeRange? selectedDateRange;
  final Function(String) onFilterChanged;
  final Function(DateTimeRange?) onDateRangeChanged;

  const FilterBottomSheetWidget({
    Key? key,
    required this.selectedFilter,
    required this.selectedDateRange,
    required this.onFilterChanged,
    required this.onDateRangeChanged,
  }) : super(key: key);

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late String _selectedFilter;
  late DateTimeRange? _selectedDateRange;

  final List<String> _filterOptions = [
    'Tümü',
    'Akne',
    'Egzama',
    'Kızarıklık',
    'Saç Dökülmesi',
    'Kepek',
    'Melanom Riski',
    'Sağlıklı',
  ];

  final List<String> _bodyAreaOptions = [
    'Tümü',
    'Yüz',
    'Saç Derisi',
    'Kol',
    'Bacak',
    'Gövde',
  ];

  final List<String> _severityOptions = [
    'Tümü',
    'Normal',
    'Hafif',
    'Orta',
    'Yüksek',
    'Kritik',
  ];

  String _selectedBodyArea = 'Tümü';
  String _selectedSeverity = 'Tümü';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.selectedFilter;
    _selectedDateRange = widget.selectedDateRange;
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: AppTheme.lightTheme.colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  void _applyFilters() {
    widget.onFilterChanged(_selectedFilter);
    widget.onDateRangeChanged(_selectedDateRange);
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = 'Tümü';
      _selectedDateRange = null;
      _selectedBodyArea = 'Tümü';
      _selectedSeverity = 'Tümü';
    });
  }

  String _formatDateRange(DateTimeRange range) {
    final start = '${range.start.day}/${range.start.month}/${range.start.year}';
    final end = '${range.end.day}/${range.end.month}/${range.end.year}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtreler',
                  style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Temizle',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter
                  _buildSectionTitle('Tarih Aralığı'),
                  SizedBox(height: 2.h),
                  GestureDetector(
                    onTap: _selectDateRange,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'date_range',
                            color: AppTheme.lightTheme.colorScheme.primary,
                            size: 20,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              _selectedDateRange != null
                                  ? _formatDateRange(_selectedDateRange!)
                                  : 'Tarih aralığı seçin',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: _selectedDateRange != null
                                        ? AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurface
                                        : AppTheme
                                              .lightTheme
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                  ),
                            ),
                          ),
                          if (_selectedDateRange != null)
                            GestureDetector(
                              onTap: _clearDateRange,
                              child: CustomIconWidget(
                                iconName: 'clear',
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Condition Filter
                  _buildSectionTitle('Durum'),
                  SizedBox(height: 2.h),
                  _buildFilterChips(_filterOptions, _selectedFilter, (value) {
                    setState(() {
                      _selectedFilter = value;
                    });
                  }),
                  SizedBox(height: 3.h),

                  // Body Area Filter
                  _buildSectionTitle('Vücut Bölgesi'),
                  SizedBox(height: 2.h),
                  _buildFilterChips(_bodyAreaOptions, _selectedBodyArea, (
                    value,
                  ) {
                    setState(() {
                      _selectedBodyArea = value;
                    });
                  }),
                  SizedBox(height: 3.h),

                  // Severity Filter
                  _buildSectionTitle('Şiddet'),
                  SizedBox(height: 2.h),
                  _buildFilterChips(_severityOptions, _selectedSeverity, (
                    value,
                  ) {
                    setState(() {
                      _selectedSeverity = value;
                    });
                  }),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('İptal'),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Uygula'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFilterChips(
    List<String> options,
    String selectedValue,
    Function(String) onSelected,
  ) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = option == selectedValue;
        return GestureDetector(
          onTap: () => onSelected(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface,
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              option,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
