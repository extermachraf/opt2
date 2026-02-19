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
  bool _testNotifications = false;
  bool _notificationsEnabled = false;
  bool _isLoading = true;
  String _testStatus = '';
  String _platformInfo = '';
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

      // Check platform and notification status
      if (kIsWeb) {
        _notificationsEnabled = true; // Web has basic support
        _platformInfo = 'Web (Limited functionality)';
      } else {
        _notificationsEnabled =
            await NotificationService.instance.areNotificationsEnabled();
        _platformInfo = 'Mobile (Full functionality)';
      }

      // Load user preferences
      final prefs =
          await UserSettingsService.instance.getNotificationPreferences();

      // Get test notification status
      final testStatus =
          await NotificationService.instance.getTestNotificationStatus();

      if (mounted) {
        setState(() {
          _mealReminders = prefs?['meal_reminders'] ?? false;
          _notificationFrequency = prefs?['notification_frequency'] ??
              'two_days'; // Default: once every two days
          _testNotifications = testStatus['isRunning'] ?? false;
          _testStatus = testStatus['isRunning']
              ? 'Running (${testStatus['pendingCount']} pending)'
              : 'Stopped';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notification settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _platformInfo = 'Error loading';
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

  /// Toggle test notifications
  Future<void> _toggleTestNotifications(bool value) async {
    try {
      setState(() {
        _testNotifications = value;
        _testStatus = value ? 'Starting...' : 'Stopping...';
      });

      if (value) {
        await NotificationService.instance.startTestNotifications();
        if (mounted) {
          final message = kIsWeb
              ? '🧪 Test notifications started! You should see browser notifications every 5 minutes for the next 2 hours.'
              : '🧪 Test notifications started! You\'ll receive notifications every 5 minutes for the next 2 hours.';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), duration: Duration(seconds: 5)),
          );
        }
      } else {
        await NotificationService.instance.stopTestNotifications();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('🔕 Test notifications stopped')),
          );
        }
      }

      // Refresh status to get current state
      await _loadSettings();
    } catch (e) {
      print('Error toggling test notifications: $e');

      // Show user-friendly error message
      if (mounted) {
        final errorMessage = kIsWeb
            ? '❌ Error: Please allow notifications in your browser settings first'
            : '❌ Error: Please check notification permissions in device settings';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 4),
          ),
        );
      }

      // Revert state on error and refresh
      setState(() {
        _testNotifications = !value;
        _testStatus = 'Error';
      });

      // Reload to get actual state
      await _loadSettings();
    }
  }

  /// Send immediate test notification
  Future<void> _sendTestNotification() async {
    try {
      await NotificationService.instance.showTestNotification();
      if (mounted) {
        final message = kIsWeb
            ? '📱 Test notification sent! Check your browser notifications.'
            : '📱 Test notification sent! Check your notification panel.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('Error sending test notification: $e');
      if (mounted) {
        final errorMessage = kIsWeb
            ? '❌ Error: Please allow notifications in your browser settings'
            : '❌ Error: Check notification permissions in device settings';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red[600],
            duration: Duration(seconds: 4),
          ),
        );
      }
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
              SizedBox(height: 1.5.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.seaMid.withAlpha(15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Platform: $_platformInfo',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.seaDeep,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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

        // Test notifications setting
        _buildOceanCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentWave.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.science,
                    size: 20,
                    color: AppTheme.accentWave,
                  ),
                ),
                title: Text(
                  'Test Notifications (Every 5min)',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w500,
                    fontSize: 14.sp,
                    color: AppTheme.textDark,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kIsWeb
                          ? 'Test notification simulation for web platform'
                          : 'Ricevi una notifica ogni 5 minuti per testare il funzionamento',
                      style: GoogleFonts.inter(
                        fontSize: 11.sp,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Status: $_testStatus',
                      style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: _testNotifications
                            ? AppTheme.seaMid
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                trailing: Switch(
                  value: _testNotifications,
                  onChanged: _toggleTestNotifications,
                  activeColor: AppTheme.accentWave,
                ),
              ),

              // Test notification button
              SizedBox(height: 1.h),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentSand, AppTheme.accentWave],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _sendTestNotification,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.send, size: 16, color: Colors.white),
                            SizedBox(width: 2.w),
                            Text(
                              kIsWeb
                                  ? 'Send Test Notification (Simulated)'
                                  : 'Send Test Notification Now',
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Platform-specific help text
        if (kIsWeb)
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.seaMid.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.seaMid.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.seaMid,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Web Notification Setup',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppTheme.seaDeep,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '1. Click "Allow" when browser asks for notification permission\n'
                  '2. Test notifications will appear as browser notifications\n'
                  '3. Make sure your browser notifications are not blocked',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppTheme.seaDeep,
                  ),
                ),
              ],
            ),
          ),

        if (!kIsWeb && !_notificationsEnabled)
          Container(
            margin: EdgeInsets.symmetric(vertical: 2.h),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.accentWave.withAlpha(15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentWave.withAlpha(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.accentWave,
                      size: 20,
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Enable Notifications:',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: AppTheme.accentWave,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  '1. Go to device Settings > Apps > NutriVita\n'
                  '2. Enable "Notifications" permission\n'
                  '3. Allow "Exact alarm" permission for Android 12+',
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),

        // Debug info (only in debug mode)
        if (kDebugMode)
          Container(
            margin: EdgeInsets.symmetric(vertical: 1.h),
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.textMuted.withAlpha(15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Debug Info:',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'Platform: ${kIsWeb ? 'Web' : 'Mobile'}',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'Notifications Enabled: $_notificationsEnabled',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
                Text(
                  'Service Initialized: ${NotificationService.instance.isInitialized}',
                  style: GoogleFonts.inter(
                    fontSize: 9.sp,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
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
