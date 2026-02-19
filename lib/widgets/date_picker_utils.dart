import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../theme/app_theme.dart';
import './custom_icon_widget.dart';

class DatePickerUtils {
  // Robust date picker with fallback mechanism
  static Future<DateTime?> showRobustDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) async {
    try {
      // Show loading indicator first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Caricamento calendario...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Small delay to show loading indicator
      await Future.delayed(Duration(milliseconds: 300));

      // Dismiss loading
      Navigator.of(context).pop();

      // Try to show native date picker
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate ?? DateTime.now().subtract(Duration(days: 365)),
        lastDate: lastDate ?? DateTime.now().add(Duration(days: 7)),
        locale: const Locale('it', 'IT'),
        builder: (context, child) {
          return Theme(
            data: AppTheme.lightTheme.copyWith(
              colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
                primary: AppTheme.lightTheme.colorScheme.primary,
                onPrimary: Colors.white,
                surface: AppTheme.lightTheme.colorScheme.surface,
                onSurface: AppTheme.lightTheme.colorScheme.onSurface,
              ),
              dialogTheme: DialogTheme(
                backgroundColor: AppTheme.lightTheme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            child: child!,
          );
        },
        helpText: helpText ?? 'Seleziona data',
        cancelText: cancelText ?? 'Annulla',
        confirmText: confirmText ?? 'Conferma',
        errorFormatText: 'Data non valida',
        errorInvalidText: 'Data fuori intervallo',
        fieldLabelText: 'Data',
        fieldHintText: 'gg/mm/aaaa',
      );

      return pickedDate;
    } catch (error) {
      // Dismiss any existing dialogs
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show fallback date picker
      return await showFallbackDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: helpText,
      );
    }
  }

  // Fallback date picker with manual selection
  static Future<DateTime?> showFallbackDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
  }) async {
    DateTime? selectedDate;

    await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime tempDate = initialDate;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.lightTheme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 24,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Impossibile caricare il calendario',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    helpText ?? 'Seleziona una data alternativa:',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Quick date selection buttons
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: [
                      _buildQuickDateButton(
                        context,
                        'Oggi',
                        DateTime.now(),
                        (date) => setState(() => tempDate = date),
                        tempDate,
                      ),
                      _buildQuickDateButton(
                        context,
                        'Ieri',
                        DateTime.now().subtract(Duration(days: 1)),
                        (date) => setState(() => tempDate = date),
                        tempDate,
                      ),
                      _buildQuickDateButton(
                        context,
                        '2 giorni fa',
                        DateTime.now().subtract(Duration(days: 2)),
                        (date) => setState(() => tempDate = date),
                        tempDate,
                      ),
                      _buildQuickDateButton(
                        context,
                        '1 settimana fa',
                        DateTime.now().subtract(Duration(days: 7)),
                        (date) => setState(() => tempDate = date),
                        tempDate,
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'event',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 16,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Selezionata: ${formatDate(tempDate)}',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    selectedDate = null;
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Annulla',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.outline,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    selectedDate = tempDate;
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Conferma'),
                ),
              ],
            );
          },
        );
      },
    );

    return selectedDate;
  }

  static Widget _buildQuickDateButton(
    BuildContext context,
    String label,
    DateTime date,
    Function(DateTime) onSelected,
    DateTime currentSelected,
  ) {
    final isSelected = isSameDay(date, currentSelected);

    return GestureDetector(
      onTap: () => onSelected(date),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.primary
                : AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Utility methods
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    if (isSameDay(date, now)) {
      return 'Oggi';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (isSameDay(date, yesterday)) {
      return 'Ieri';
    }

    final weekdays = ['', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final months = [
      '',
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

    return '${weekdays[date.weekday]} ${date.day} ${months[date.month]}';
  }

  // Show success message helper
  static void showDateSelectionSuccess(
    BuildContext context,
    DateTime selectedDate,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Data selezionata: ${formatDate(selectedDate)}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show error message helper
  static void showDateSelectionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                'Impossibile caricare il calendario',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.all(4.w),
        duration: Duration(seconds: 3),
      ),
    );
  }
}
