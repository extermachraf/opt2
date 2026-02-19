import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/meal_diary_service.dart';
import '../dashboard/widgets/quick_action_sheet_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/macro_distribution_widget.dart';
import './widgets/meal_frequency_widget.dart';
import './widgets/nutritional_summary_widget.dart';
import './widgets/report_header_widget.dart';
import './widgets/weight_trend_widget.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  String _selectedDateRange = 'Weekly';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _isLoading = false;
  Map<String, dynamic> _nutritionalSummary = {};
  Map<String, dynamic> _mealStatistics = {};
  bool _hasUserData = false;



  @override
  void initState() {
    super.initState();
    _loadReportData();
  }



  Future<void> _loadReportData() async {
    if (!AuthService.instance.isAuthenticated) {
      setState(() {
        _hasUserData = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      // Handle custom date range
      if (_selectedDateRange == 'Custom Range' &&
          _customStartDate != null &&
          _customEndDate != null) {
        startDate = _customStartDate!;
        endDate = _customEndDate!;
      } else {
        // Calculate date range based on selection
        switch (_selectedDateRange) {
          case 'Daily':
            startDate = DateTime(now.year, now.month, now.day);
            endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
            break;
          case 'Weekly':
            startDate = now.subtract(Duration(days: 7));
            break;
          case 'Monthly':
            startDate = DateTime(now.year, now.month - 1, now.day);
            break;
          case 'Treatment Cycle':
            // Treatment cycle typically spans 2-3 months based on medical context
            startDate = DateTime(now.year, now.month - 3, now.day);
            break;
          case 'Yearly':
            startDate = DateTime(now.year - 1, now.month, now.day);
            break;
          default:
            startDate = now.subtract(Duration(days: 7));
        }
      }

      final summary = await MealDiaryService.instance.getNutritionalSummary(
        startDate: startDate,
        endDate: endDate,
      );

      final statistics = await MealDiaryService.instance.getMealStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      final hasData = await MealDiaryService.instance.hasUserMeals();

      setState(() {
        _nutritionalSummary = summary;
        _mealStatistics = statistics;
        _hasUserData = hasData;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading report data: $error');
      setState(() {
        _nutritionalSummary = {};
        _mealStatistics = {};
        _hasUserData = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.seaTop,
              AppTheme.seaMid,
              AppTheme.seaDeep,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              ReportHeaderWidget(
                onDateRangeChanged: _handleDateRangeChanged,
                onGeneratePDF: _showExportOptions,
              ),
              Expanded(child: _buildReportContent()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildReportContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (!AuthService.instance.isAuthenticated) {
      return _buildAuthRequiredState();
    }

    if (!_hasUserData) {
      return _buildEmptyDataState();
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),

          // Add current date range display
          if (_selectedDateRange == 'Custom Range' &&
              _customStartDate != null &&
              _customEndDate != null)
            Container(
              margin: EdgeInsets.symmetric(vertical: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.seaTop, AppTheme.seaMid],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomIconWidget(
                      iconName: 'analytics',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report personalizzato',
                          style: TextStyle(
                            color: AppTheme.seaDeep,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Dal ${_formatCustomDate(_customStartDate!)} al ${_formatCustomDate(_customEndDate!)}',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          NutritionalSummaryWidget(
            dateRange: _getDisplayDateRange(),
            summaryData: _nutritionalSummary,
          ),
          MacroDistributionWidget(
            dateRange: _getDisplayDateRange(),
            summaryData: _nutritionalSummary,
          ),
          MealFrequencyWidget(
            dateRange: _getDisplayDateRange(),
            statisticsData: _mealStatistics,
          ),
          WeightTrendWidget(dateRange: _getDisplayDateRange()),
          _buildTreatmentCorrelationCard(),
          _buildSyncStatusCard(),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }



  Widget _buildAuthRequiredState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'login',
            size: 15.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 3.h),
          Text(
            'Accedi per visualizzare i tuoi report',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'I tuoi report nutrizionali personalizzati ti aiutano a monitorare i progressi',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed:
                () => Navigator.pushNamed(context, AppRoutes.loginScreen),
            child: Text('Accedi'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDataState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'analytics',
              size: 20.w,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            SizedBox(height: 4.h),
            Text(
              'Nessun dato disponibile per i report',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Inizia a registrare i tuoi pasti nel Diario Pasti per generare report nutrizionali dettagliati e monitorare i tuoi progressi.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.seaTop, AppTheme.seaMid],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.seaMid.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.mealDiary),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'restaurant_menu',
                          color: Colors.white,
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Vai al Diario Pasti',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.addMeal),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'add',
                          color: Colors.white,
                          size: 6.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Aggiungi primo pasto',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 2.h),
          Text(
            'Caricamento dati report...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreatmentCorrelationCard() {
    // Only show if user has data
    if (!_hasUserData) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.seaTop, AppTheme.seaMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CustomIconWidget(
                  iconName: 'healing',
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Correlazioni con il trattamento',
                  style: TextStyle(
                    color: AppTheme.seaDeep,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildInsightItem(
            'Progressi nutrizionali',
            _buildProgressText(),
            const Color(0xFF27AE60),
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            'Calorie giornaliere medie',
            '${(_nutritionalSummary['avg_calories_per_day'] ?? 0.0).toStringAsFixed(0)} kcal',
            const Color(0xFFF39C12),
          ),
          SizedBox(height: 1.h),
          _buildInsightItem(
            'Pasti registrati',
            '${_mealStatistics['total_meals'] ?? 0} in totale',
            AppTheme.seaMid,
          ),
        ],
      ),
    );
  }

  String _buildProgressText() {
    final totalCalories = _nutritionalSummary['total_calories'] ?? 0.0;
    final totalMeals = _mealStatistics['total_meals'] ?? 0;

    if (totalMeals == 0) {
      return 'Inizia a registrare i pasti per vedere i progressi';
    }

    return 'Buon monitoraggio alimentare con $totalMeals pasti registrati';
  }

  Widget _buildInsightItem(String title, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.seaDeep,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                description,
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSyncStatusCard() {
    if (!_hasUserData) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'sync',
              color: const Color(0xFF27AE60),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stato sincronizzazione dati',
                  style: TextStyle(
                    color: AppTheme.seaDeep,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'Tutti i dati sincronizzati • Ultimo aggiornamento: ora',
                  style: TextStyle(
                    color: const Color(0xFF27AE60),
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: AppTheme.bottomNavDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavIcon('home', 0),
              _buildNavIcon('calendar_today', 1),
              SizedBox(width: 15.w), // Space for FAB
              _buildNavIcon('trending_up', 3),
              _buildNavIcon('person', 4),
            ],
          ),
          // Centered FAB
          Positioned(
            top: -35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showQuickActions,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: AppTheme.fabGradientDecoration,
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String iconName, int index) {
    // Reports page is index 3
    final isActive = index == 3;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: isActive ? AppTheme.seaMid : const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealDiary);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.addMeal);
        break;
      case 3:
        // Reports - already on this page
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionSheetWidget(
        onLogMeal: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.addMeal);
        },
        onAddRecipe: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.recipeManagement);
        },
        onTakePhoto: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.addMeal,
            arguments: {'autoOpenCamera': true},
          );
        },
      ),
    );
  }

  void _handleDateRangeChanged(
    String newRange, {
    DateTime? customStartDate,
    DateTime? customEndDate,
  }) {
    setState(() {
      _selectedDateRange = newRange;
      if (newRange == 'Custom Range') {
        _customStartDate = customStartDate;
        _customEndDate = customEndDate;
      } else {
        _customStartDate = null;
        _customEndDate = null;
      }
    });
    _loadReportData();
  }

  String _getDisplayDateRange() {
    if (_selectedDateRange == 'Custom Range' &&
        _customStartDate != null &&
        _customEndDate != null) {
      final days = _customEndDate!.difference(_customStartDate!).inDays;
      if (days <= 7) return 'Custom Weekly';
      if (days <= 31) return 'Custom Monthly';
      return 'Custom Range';
    }
    return _selectedDateRange;
  }

  String _formatCustomDate(DateTime date) {
    final months = [
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showExportOptions() {
    if (!_hasUserData) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nessun dato da esportare. Registra alcuni pasti prima.',
          ),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            constraints: BoxConstraints(maxHeight: 80.h),
            child: ExportOptionsWidget(
              dateRange: _getDisplayDateRange(),
              onClose: () => Navigator.pop(context),
            ),
          ),
    );
  }
}
