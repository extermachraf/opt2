import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';

class CustomDatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final String title;
  final Function(DateTime) onDateSelected;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showPastIndicator;
  final String? helpText;

  // Ocean Blue colors
  static const Color _seaMid = Color(0xFF00ACC1);
  static const Color _seaDeep = Color(0xFF006064);
  static const Color _textMuted = Color(0xFF78909C);
  static const Color _textDark = Color(0xFF006064);
  static const Color _accentLight = Color(0xFFE0F7FA);
  static const Color _inputBg = Color(0xFFF0F8FF);
  static const Color _accentSand = Color(0xFFFFB74D);

  const CustomDatePickerWidget({
    Key? key,
    required this.selectedDate,
    required this.title,
    required this.onDateSelected,
    this.firstDate,
    this.lastDate,
    this.showPastIndicator = true,
    this.helpText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(selectedDate);
    final isPast = _isPast(selectedDate) && !isToday;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _seaDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          title,
          style: TextStyle(
            fontSize: 14.sp, // Increased from 12.sp for better readability
            fontWeight: FontWeight.w500,
            color: _textMuted,
            letterSpacing: 0.5,
          ),
        ),
          SizedBox(height: 1.5.h),
          GestureDetector(
            onTap: () => _showCustomDatePicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _inputBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('📅', style: TextStyle(fontSize: 16.sp)),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      _formatDate(selectedDate),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: _textDark,
                      ),
                    ),
                  ),
                  if (isPast && showPastIndicator) ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: _accentSand.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Passato',
                        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: _accentSand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                  ],
                  CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: _textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCustomDatePicker(BuildContext context) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return DatePickerDialog(
          currentDate: selectedDate,
          firstDate: firstDate ?? DateTime.now().subtract(Duration(days: 365)),
          lastDate: lastDate ?? DateTime.now().add(Duration(days: 7)),
          onDateSelected: (DateTime newDate) {
            Navigator.of(dialogContext).pop();
            onDateSelected(newDate);

            // Show success feedback
            if (context.mounted) {
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
                          'Data selezionata: ${_formatDate(newDate)}',
                          style: AppTheme.lightTheme.textTheme.bodyMedium
                              ?.copyWith(
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
          },
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Oggi';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (_isSameDay(date, yesterday)) {
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
}

// Custom date picker dialog to avoid GlobalKey conflicts
class DatePickerDialog extends StatefulWidget {
  final DateTime currentDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateSelected;

  const DatePickerDialog({
    Key? key,
    required this.currentDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<DatePickerDialog> {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentDate;
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 85.w,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 2.h),
            _buildQuickDateButtons(),
            SizedBox(height: 2.h),
            _buildCalendar(),
            SizedBox(height: 2.h),
            _buildSelectedDateInfo(),
            SizedBox(height: 2.h),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Seleziona data',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            padding: EdgeInsets.all(1.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: CustomIconWidget(
              iconName: 'close',
              color: AppTheme.lightTheme.colorScheme.outline,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDateButtons() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: [
        _buildQuickDateButton('Oggi', DateTime.now()),
        _buildQuickDateButton(
            'Ieri', DateTime.now().subtract(Duration(days: 1))),
        _buildQuickDateButton(
            '2 giorni fa', DateTime.now().subtract(Duration(days: 2))),
        _buildQuickDateButton(
            '1 settimana fa', DateTime.now().subtract(Duration(days: 7))),
      ],
    );
  }

  Widget _buildQuickDateButton(String label, DateTime date) {
    final isSelected = _isSameDay(date, _selectedDate);
    final isInRange =
        date.isAfter(widget.firstDate.subtract(Duration(days: 1))) &&
            date.isBefore(widget.lastDate.add(Duration(days: 1)));

    return GestureDetector(
      onTap: isInRange
          ? () {
              setState(() {
                _selectedDate = date;
                _displayedMonth = DateTime(date.year, date.month, 1);
              });
            }
          : null,
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
                : isInRange
                    ? AppTheme.lightTheme.colorScheme.outline.withAlpha(77)
                    : AppTheme.lightTheme.colorScheme.outline.withAlpha(26),
          ),
        ),
        child: Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Colors.white
                : isInRange
                    ? AppTheme.lightTheme.colorScheme.onSurface
                    : AppTheme.lightTheme.colorScheme.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          _buildMonthNavigation(),
          SizedBox(height: 2.h),
          _buildWeekdayHeaders(),
          SizedBox(height: 1.h),
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    final monthNames = [
      '',
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _displayedMonth =
                  DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
            });
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'chevron_left',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        Text(
          '${monthNames[_displayedMonth.month]} ${_displayedMonth.year}',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _displayedMonth =
                  DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
            });
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'chevron_right',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays
          .map(
            (day) => SizedBox(
              width: 8.w,
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color:
                      AppTheme.lightTheme.colorScheme.onSurface.withAlpha(153),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDaysGrid() {
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday; // Monday = 1, Sunday = 7

    final weeks = <Widget>[];
    var currentWeek = <Widget>[];

    // Add empty cells for days before the first day of month
    for (int i = 1; i < startingWeekday; i++) {
      currentWeek.add(SizedBox(width: 8.w, height: 8.w));
    }

    // Add days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      final isSelected = _isSameDay(date, _selectedDate);
      final isToday = _isSameDay(date, DateTime.now());
      final isInRange =
          date.isAfter(widget.firstDate.subtract(Duration(days: 1))) &&
              date.isBefore(widget.lastDate.add(Duration(days: 1)));

      currentWeek.add(
        GestureDetector(
          onTap: isInRange
              ? () {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              : null,
          child: Container(
            width: 8.w,
            height: 8.w,
            margin: EdgeInsets.all(0.5.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : isToday
                      ? AppTheme.lightTheme.colorScheme.primary.withAlpha(51)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: isToday && !isSelected
                  ? Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      width: 1,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? Colors.white
                      : isInRange
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.outline
                              .withAlpha(77),
                  fontWeight:
                      isSelected || isToday ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      );

      // Start a new week on Sunday (weekday 7)
      if ((startingWeekday + day - 1) % 7 == 0) {
        weeks.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: currentWeek,
        ));
        currentWeek = <Widget>[];
      }
    }

    // Add the last week if it has any days
    if (currentWeek.isNotEmpty) {
      // Fill remaining cells with empty space
      while (currentWeek.length < 7) {
        currentWeek.add(SizedBox(width: 8.w, height: 8.w));
      }
      weeks.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: currentWeek,
      ));
    }

    return Column(children: weeks);
  }

  Widget _buildSelectedDateInfo() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withAlpha(26),
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
            'Selezionata: ${_formatDate(_selectedDate)}',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
            widget.onDateSelected(_selectedDate);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Conferma'),
        ),
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (_isSameDay(date, now)) {
      return 'Oggi';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (_isSameDay(date, yesterday)) {
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
}
