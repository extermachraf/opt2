import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';

class DataExportDialogWidget extends StatefulWidget {
  const DataExportDialogWidget({Key? key}) : super(key: key);

  @override
  State<DataExportDialogWidget> createState() => _DataExportDialogWidgetState();
}

class _DataExportDialogWidgetState extends State<DataExportDialogWidget> {
  bool _isExporting = false;
  final Map<String, bool> _exportOptions = {
    'meal_diary': true,
    'body_metrics': true,
    'recipes': false,
    'reports': true,
    'questionnaires': false,
  };

  Future<void> _exportData() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Generate comprehensive patient data
      final exportData = _generatePatientData();
      final jsonString = json.encode(exportData);

      // Create filename with timestamp
      final timestamp = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'nutrivita_patient_data_$timestamp.json';

      await _downloadFile(jsonString, filename);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Patient data exported successfully'),
            backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _downloadFile(String content, String filename) async {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename');
      await file.writeAsString(content);
    }
  }

  Map<String, dynamic> _generatePatientData() {
    final selectedData = <String, dynamic>{
      'export_info': {
        'generated_at': DateTime.now().toIso8601String(),
        'app_version': '1.0.0',
        'patient_id': 'PATIENT_001',
        'export_type': 'comprehensive_medical_data',
      },
    };

    if (_exportOptions['meal_diary'] == true) {
      selectedData['meal_diary'] = [
        {
          'date': '2025-01-20',
          'meals': [
            {
              'type': 'breakfast',
              'time': '08:30',
              'foods': ['Oatmeal with berries', 'Green tea'],
              'calories': 320,
              'protein_g': 12,
              'carbs_g': 58,
              'fat_g': 6,
            },
            {
              'type': 'lunch',
              'time': '12:45',
              'foods': ['Grilled chicken salad', 'Quinoa'],
              'calories': 450,
              'protein_g': 35,
              'carbs_g': 32,
              'fat_g': 18,
            },
          ],
        },
      ];
    }

    if (_exportOptions['body_metrics'] == true) {
      selectedData['body_metrics'] = [
        {
          'date': '2025-01-20',
          'weight_kg': 68.5,
          'height_cm': 165,
          'bmi': 25.2,
          'body_fat_percentage': 22.5,
          'muscle_mass_kg': 28.3,
        },
      ];
    }

    if (_exportOptions['recipes'] == true) {
      selectedData['saved_recipes'] = [
        {
          'name': 'Anti-inflammatory Smoothie',
          'ingredients': ['Spinach', 'Blueberries', 'Ginger', 'Coconut milk'],
          'instructions': 'Blend all ingredients until smooth',
          'nutrition_per_serving': {
            'calories': 180,
            'protein_g': 4,
            'carbs_g': 28,
            'fat_g': 8,
          },
        },
      ];
    }

    if (_exportOptions['reports'] == true) {
      selectedData['medical_reports'] = [
        {
          'report_date': '2025-01-15',
          'report_type': 'weekly_nutrition_summary',
          'average_daily_calories': 1850,
          'protein_intake_adequate': true,
          'hydration_goal_met': 85,
          'weight_trend': 'stable',
        },
      ];
    }

    if (_exportOptions['questionnaires'] == true) {
      selectedData['health_questionnaires'] = [
        {
          'questionnaire_type': 'symptom_assessment',
          'completion_date': '2025-01-18',
          'responses': {
            'fatigue_level': 3,
            'appetite_rating': 7,
            'nausea_severity': 1,
            'overall_wellbeing': 8,
          },
        },
      ];
    }

    return selectedData;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 85.w,
        constraints: BoxConstraints(maxHeight: 70.h),
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'download',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Export Patient Data',
                    style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Select data to include in your medical export:',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildExportOption(
                      'meal_diary',
                      'Meal Diary',
                      'Complete food intake records',
                      'restaurant',
                    ),
                    _buildExportOption(
                      'body_metrics',
                      'Body Metrics',
                      'Weight, BMI, and body composition',
                      'monitor_weight',
                    ),
                    _buildExportOption(
                      'recipes',
                      'Saved Recipes',
                      'Personal recipe collection',
                      'book',
                    ),
                    _buildExportOption(
                      'reports',
                      'Medical Reports',
                      'Generated health summaries',
                      'assessment',
                    ),
                    _buildExportOption(
                      'questionnaires',
                      'Health Questionnaires',
                      'Symptom assessments and surveys',
                      'quiz',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Data will be exported in medical-grade JSON format for healthcare provider review.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExporting ? null : _exportData,
                    child: _isExporting
                        ? SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text('Export Data'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
      String key, String title, String subtitle, String iconName) {
    return CheckboxListTile(
      value: _exportOptions[key],
      onChanged: (value) {
        setState(() {
          _exportOptions[key] = value ?? false;
        });
      },
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      secondary: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.primaryColor,
          size: 5.w,
        ),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}