import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback onTodayPressed;

  const DatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.onTodayPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: AppTheme.menuCardDecoration,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _navigateDate(-1),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaTop.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CustomIconWidget(
                iconName: 'chevron_left',
                color: AppTheme.seaMid,
                size: 24,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context),
              child: Text(
                _formatDate(selectedDate),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.seaDeep,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _navigateDate(1),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaTop.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CustomIconWidget(
                iconName: 'chevron_right',
                color: AppTheme.seaMid,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateDate(int days) {
    final newDate = selectedDate.add(Duration(days: days));
    onDateChanged(newDate);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Gennaio',
      'Febbraio',
      'Marzo',
      'Aprile',
      'Maggio',
      'Giugno',
      'Luglio',
      'Agosto',
      'Settembre',
      'Ottobre',
      'Novembre',
      'Dicembre'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.seaMid,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.seaDeep,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
