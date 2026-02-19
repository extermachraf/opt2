import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MealFrequencyWidget extends StatelessWidget {
  final String dateRange;
  final Map<String, dynamic> statisticsData;

  const MealFrequencyWidget({
    Key? key,
    required this.dateRange,
    required this.statisticsData,
  }) : super(key: key);

  String _getLocalizedDateRange() {
    switch (dateRange) {
      case 'Daily':
        return 'Giornaliera';
      case 'Weekly':
      case 'Custom Weekly':
        return 'Settimanale';
      case 'Monthly':
      case 'Custom Monthly':
        return 'Mensile';
      case 'Treatment Cycle':
        return 'Ciclo di trattamento';
      case 'Yearly':
        return 'Annuale';
      case 'Custom Range':
        return 'Personalizzato';
      default:
        return dateRange;
    }
  }

  List<Map<String, dynamic>> get _mealFrequencyData {
    // FIXED: Calculate real percentages from actual meal counts
    final mealDistribution = statisticsData['meal_type_distribution'] as Map<String, dynamic>? ?? {};
    
    final breakfastCount = (mealDistribution['breakfast'] ?? 0) as num;
    final lunchCount = (mealDistribution['lunch'] ?? 0) as num;
    final dinnerCount = (mealDistribution['dinner'] ?? 0) as num;
    final snackCount = (mealDistribution['snack'] ?? 0) as num;
    
    final totalMeals = breakfastCount + lunchCount + dinnerCount + snackCount;
    
    // Calculate percentages (avoid division by zero)
    final breakfastPercent = totalMeals > 0 ? (breakfastCount / totalMeals * 100) : 0.0;
    final lunchPercent = totalMeals > 0 ? (lunchCount / totalMeals * 100) : 0.0;
    final dinnerPercent = totalMeals > 0 ? (dinnerCount / totalMeals * 100) : 0.0;
    final snackPercent = totalMeals > 0 ? (snackCount / totalMeals * 100) : 0.0;

    return [
      {'meal': 'Colazione', 'frequency': breakfastPercent.round(), 'color': const Color(0xFF2E7D6A)},
      {'meal': 'Pranzo', 'frequency': lunchPercent.round(), 'color': const Color(0xFFF28C38)},
      {'meal': 'Cena', 'frequency': dinnerPercent.round(), 'color': const Color(0xFF27AE60)},
      {'meal': 'Spuntini', 'frequency': snackPercent.round(), 'color': const Color(0xFFF39C12)},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
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
          // Header
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
                  iconName: 'restaurant',
                  color: Colors.white,
                  size: 22,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analisi frequenza pasti',
                      style: TextStyle(
                        color: AppTheme.seaDeep,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Consistenza registrazione pasti (${_getLocalizedDateRange()})',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          // Chart
          Container(
            width: double.infinity,
            height: 22.h,
            padding: EdgeInsets.only(right: 2.w),
            child: Semantics(
              label: "Grafico a barre analisi frequenza pasti",
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.white,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final mealData = _mealFrequencyData[group.x.toInt()];
                        return BarTooltipItem(
                          '${mealData['meal']}\n${rod.toY.toInt()}%',
                          AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                            color: AppTheme.seaDeep,
                            fontWeight: FontWeight.w500,
                          ) ?? TextStyle(
                            color: AppTheme.seaDeep,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < _mealFrequencyData.length) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Padding(
                                padding: EdgeInsets.only(top: 0.8.h),
                                child: Text(
                                  _mealFrequencyData[index]['meal'] as String,
                                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              '${value.toInt()}%',
                              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          );
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: _mealFrequencyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: (data['frequency'] as int).toDouble(),
                          color: data['color'] as Color,
                          width: 7.w,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 100,
                            color: AppTheme.seaMid.withValues(alpha: 0.08),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.seaMid.withValues(alpha: 0.12),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
