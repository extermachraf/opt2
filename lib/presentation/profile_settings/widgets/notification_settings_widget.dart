import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../services/notification_service.dart';
import '../../../services/user_settings_service.dart';
import '../../../theme/app_theme.dart';

class NotificationSettingsWidget extends StatefulWidget {
  const NotificationSettingsWidget({super.key});

  @override
  State<NotificationSettingsWidget> createState() =>
      _NotificationSettingsWidgetState();
}

class _NotificationSettingsWidgetState
    extends State<NotificationSettingsWidget> {
  bool _mealReminders = false;
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  String _notificationFrequency =
      'two_days'; // Default frequency: once every two days

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load notification settings and status with cross-platform support
  Future<void> _loadSettings() async {
    try {
      // Initialize services
      await UserSettingsService.instance.initialize();

      // Check notification status
      if (kIsWeb) {
        _notificationsEnabled = true; // Web has basic support
      } else {
        _notificationsEnabled =
            await NotificationService.instance.areNotificationsEnabled();
      }

      // Load user preferences
      final prefs =
          await UserSettingsService.instance.getNotificationPreferences();

      if (mounted) {
        setState(() {
          _mealReminders = prefs?['meal_reminders'] ?? false;
          _notificationFrequency = prefs?['notification_frequency'] ??
              'two_days'; // Default: once every two days
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Update notification frequency
  Future<void> _updateNotificationFrequency(String frequency) async {
    try {
      setState(() {
        _notificationFrequency = frequency;
      });

      // Update preferences
      await UserSettingsService.instance.updateNotificationPreferences({
        'notification_frequency': frequency,
      });

      if (mounted) {
        final frequencyName = _getFrequencyDisplayName(frequency);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Frequenza impostata su: $frequencyName')),
        );
      }
    } catch (e) {
      print('Error updating notification frequency: $e');
      // Revert state on error
      setState(() {
        _notificationFrequency = 'two_days';
      });
    }
  }

  /// Get display name for frequency
  String _getFrequencyDisplayName(String frequency) {
    switch (frequency) {
      case 'daily':
        return 'Ogni giorno';
      case 'two_days':
        return 'Ogni due giorni';
      case 'weekly':
        return 'Settimanale';
      case 'never':
        return 'Mai';
      default:
        return 'Ogni due giorni';
    }
  }

  /// Update meal reminder settings
  Future<void> _updateMealReminder(bool value) async {
    try {
      setState(() {
        _mealReminders = value;
      });

      // Update preferences
      await UserSettingsService.instance.updateNotificationPreferences({
        'meal_reminders': value,
      });

      // Schedule or cancel meal reminder
      await NotificationService.instance.updateMealReminderPreference(value);

      if (mounted) {
        final message = value
            ? (kIsWeb
                ? 'Promemoria pasti attivati (limitato su web)'
                : 'Promemoria pasti attivati alle 15:00')
            : 'Promemoria pasti disattivati';

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      print('Error updating meal reminder: $e');
      // Revert state on error
      setState(() {
        _mealReminders = !value;
      });
    }
  }

  /// Show frequency selection dialog
  void _showFrequencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleziona Frequenza Notifiche'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'daily',
            'two_days',
            'weekly',
            'never',
          ]
              .map(
                (frequency) => RadioListTile<String>(
                  title: Text(_getFrequencyDisplayName(frequency)),
                  value: frequency,
                  groupValue: _notificationFrequency,
                  onChanged: (value) {
                    if (value != null) {
                      Navigator.pop(context);
                      _updateNotificationFrequency(value);
                    }
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.seaMid),
      );
    }

    return Column(
      children: [
        // System notification status with platform info
        _buildOceanCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _notificationsEnabled
                          ? AppTheme.seaMid.withAlpha(20)
                          : AppTheme.errorLight.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _notificationsEnabled
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: _notificationsEnabled
                          ? AppTheme.seaMid
                          : AppTheme.errorLight,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stato Notifiche Sistema',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          _notificationsEnabled ? 'Attivate' : 'Disattivate',
                          style: GoogleFonts.inter(
                            color: _notificationsEnabled
                                ? AppTheme.seaMid
                                : AppTheme.errorLight,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
        ),

        // Notification frequency setting
        _buildOceanCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaMid.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule,
                size: 20,
                color: AppTheme.seaMid,
              ),
            ),
            title: Text(
              'Frequenza Notifiche',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppTheme.textDark,
              ),
            ),
            subtitle: Text(
              'Frequenza attuale: ${_getFrequencyDisplayName(_notificationFrequency)}',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppTheme.textMuted,
              ),
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textMuted,
            ),
            onTap: () => _showFrequencyDialog(),
          ),
        ),

        // Meal reminders setting
        _buildOceanCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaMid.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.restaurant,
                size: 20,
                color: AppTheme.seaMid,
              ),
            ),
            title: Text(
              'Promemoria Pasti (19:00)',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
                color: AppTheme.textDark,
              ),
            ),
            subtitle: Text(
              kIsWeb
                  ? 'Preferenza promemoria pasti (funzionalità limitata su web)'
                  : 'Ricevi un promemoria giornaliero alle 15:00 per registrare i tuoi pasti',
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: AppTheme.textMuted,
              ),
            ),
            trailing: Switch(
              value: _mealReminders,
              onChanged: _updateMealReminder,
              activeColor: AppTheme.seaMid,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOceanCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.seaMid.withAlpha(30)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowSea.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
