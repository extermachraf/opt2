import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MacroDistributionWidget extends StatelessWidget {
  final String dateRange;
  final Map<String, dynamic> summaryData;

  const MacroDistributionWidget({
    Key? key,
    required this.dateRange,
    required this.summaryData,
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

  List<Map<String, dynamic>> get _macroData {
    // Get total values
    final totalProtein = (summaryData['total_protein'] ?? 0.0) as num;
    final totalCarbs = (summaryData['total_carbs'] ?? 0.0) as num;
    final totalFat = (summaryData['total_fat'] ?? 0.0) as num;
    final totalFiber = (summaryData['total_fiber'] ?? 0.0) as num;
    final totalCalories = (summaryData['total_calories'] ?? 0.0) as num;

    // Calculate calories from each macronutrient
    // Protein: 4 kcal/g, Carbs: 3.75 kcal/g, Fat: 9 kcal/g, Fiber: 2 kcal/g
    final proteinKcal = totalProtein * 4;
    final carbsKcal = totalCarbs * 3.75;
    final fatKcal = totalFat * 9;
    final fiberKcal = totalFiber * 2;

    // Calculate total kcal from macros
    final totalMacroKcal = proteinKcal + carbsKcal + fatKcal + fiberKcal;

    // Calculate percentages based on kcal (avoid division by zero)
    final proteinPercent = totalMacroKcal > 0 ? (proteinKcal / totalMacroKcal * 100) : 0.0;
    final carbsPercent = totalMacroKcal > 0 ? (carbsKcal / totalMacroKcal * 100) : 0.0;
    final fatPercent = totalMacroKcal > 0 ? (fatKcal / totalMacroKcal * 100) : 0.0;
    final fiberPercent = totalMacroKcal > 0 ? (fiberKcal / totalMacroKcal * 100) : 0.0;

    // Calculate average per day
    final avgCaloriesPerDay = (summaryData['avg_calories_per_day'] ?? 0.0) as num;
    final days = totalCalories > 0 && avgCaloriesPerDay > 0
        ? (totalCalories / avgCaloriesPerDay).ceil()
        : 1;

    final proteinPerDay = days > 0 ? totalProtein / days : totalProtein;
    final carbsPerDay = days > 0 ? totalCarbs / days : totalCarbs;
    final fatPerDay = days > 0 ? totalFat / days : totalFat;
    final fiberPerDay = days > 0 ? totalFiber / days : totalFiber;

    final proteinKcalPerDay = days > 0 ? proteinKcal / days : proteinKcal;
    final carbsKcalPerDay = days > 0 ? carbsKcal / days : carbsKcal;
    final fatKcalPerDay = days > 0 ? fatKcal / days : fatKcal;
    final fiberKcalPerDay = days > 0 ? fiberKcal / days : fiberKcal;

    return [
      {
        'name': 'Proteine',
        'value': proteinPercent.toDouble(),
        'color': AppTheme.seaMid,
        'grams': proteinPerDay.toDouble(),
        'kcal': proteinKcalPerDay.toDouble(),
      },
      {
        'name': 'Carboidrati',
        'value': carbsPercent.toDouble(),
        'color': const Color(0xFFF39C12),
        'grams': carbsPerDay.toDouble(),
        'kcal': carbsKcalPerDay.toDouble(),
      },
      {
        'name': 'Grassi',
        'value': fatPercent.toDouble(),
        'color': const Color(0xFF27AE60),
        'grams': fatPerDay.toDouble(),
        'kcal': fatKcalPerDay.toDouble(),
      },
      {
        'name': 'Fibre',
        'value': fiberPercent.toDouble(),
        'color': const Color(0xFF9B59B6),
        'grams': fiberPerDay.toDouble(),
        'kcal': fiberKcalPerDay.toDouble(),
      },
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
                  iconName: 'pie_chart',
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
                      'Distribuzione macronutrienti',
                      style: TextStyle(
                        color: AppTheme.seaDeep,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 0.3.h),
                    Text(
                      'Distribuzione media (${_getLocalizedDateRange()})',
                      style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.5.h),
          // Chart and Legend Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Pie Chart
              SizedBox(
                width: 32.w,
                height: 32.w,
                child: Semantics(
                  label: "Grafico a torta distribuzione macronutrienti",
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 6.w,
                      sections: _macroData.map((data) {
                        return PieChartSectionData(
                          color: data['color'] as Color,
                          value: data['value'] as double,
                          title: '${(data['value'] as double).toInt()}%',
                          radius: 10.w,
                          titleStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ) ?? TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                      pieTouchData: PieTouchData(enabled: false),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _macroData.map((data) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 1.5.h),
                      child: Row(
                        children: [
                          Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: data['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] as String,
                                  style: TextStyle(
                                    color: AppTheme.seaDeep,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  '${(data['kcal'] as double).toStringAsFixed(0)}kcal di ${data['name']}',
                                  style: TextStyle(
                                    color: data['color'] as Color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  '${(data['value'] as double).toInt()}% • ${(data['grams'] as double).toStringAsFixed(0)}g medio/giorno',
                                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                    color: AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
