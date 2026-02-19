import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import './user_settings_service.dart';

// Platform-specific imports with proper conditional compilation
import 'dart:io' if (dart.library.io) 'dart:io';

// Web-only import for browser APIs
import 'package:universal_html/html.dart' as html;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static NotificationService get instance => _instance;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _testNotificationsRunning = false;
  SharedPreferences? _prefs;
  bool _webNotificationsPermissionGranted = false;

  bool get isInitialized => _isInitialized;
  bool get testNotificationsRunning => _testNotificationsRunning;

  /// Initialize the notification service with cross-platform support
  Future<void> initialize() async {
    try {
      // Initialize SharedPreferences for fallback storage
      _prefs = await SharedPreferences.getInstance();

      // Load test notification state from storage
      _testNotificationsRunning =
          _prefs?.getBool('test_notifications_running') ?? false;

      if (kIsWeb) {
        // Initialize web notifications with safer browser API approach
        await _initializeWebNotifications();
        _isInitialized = true;
        print(
          '✅ NotificationService initialized for web with browser API support',
        );
        return;
      }

      // Initialize timezone data for mobile platforms
      tz.initializeTimeZones();

      // Initialize notification settings for mobile platforms only
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      final darwinSettings = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      final initializationSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Request permissions for mobile platforms
      await _requestMobilePermissions();

      _isInitialized = true;
      print('✅ NotificationService initialized successfully for mobile');
    } catch (e) {
      print('❌ Error initializing NotificationService: $e');
      _isInitialized = false;
    }
  }

  /// Initialize web notifications using safer browser API approach
  Future<void> _initializeWebNotifications() async {
    if (!kIsWeb) return;

    try {
      // Check if the browser supports notifications - Web only using safer approach
      if (_hasNotificationSupportSafe()) {
        final permission = _getNotificationPermissionSafe();

        if (permission == 'granted') {
          _webNotificationsPermissionGranted = true;
        } else if (permission == 'default') {
          // Request permission with new async approach
          final result = await _requestNotificationPermissionSafe();
          _webNotificationsPermissionGranted = result == 'granted';
        }
      }
    } catch (e) {
      print('⚠️ Web notification initialization failed: $e');
      _webNotificationsPermissionGranted = false;
    }
  }

  /// Check if browser supports notifications - Safe Web-only implementation
  bool _hasNotificationSupportSafe() {
    if (!kIsWeb) return false;
    try {
      // Use dart:html for web-specific APIs
      return html.Notification.supported;
    } catch (e) {
      return false;
    }
  }

  /// Get current notification permission - Safe Web-only implementation
  String? _getNotificationPermissionSafe() {
    if (!kIsWeb) return null;
    try {
      return html.Notification.permission;
    } catch (e) {
      return null;
    }
  }

  /// Request notification permission - Fixed async implementation for web
  Future<String?> _requestNotificationPermissionSafe() async {
    if (!kIsWeb) return null;

    try {
      final permission = await html.Notification.requestPermission();
      return permission;
    } catch (e) {
      print('❌ Error requesting web notification permission: $e');
      return null;
    }
  }

  /// Create web notification - Safe Web-only implementation
  void _createWebNotificationSafe(String title, String body, String tag) {
    if (!kIsWeb) return;

    try {
      final notification = html.Notification(
        title,
        body: body,
        tag: tag,
        icon: '/icons/Icon-192.png',
      );

      // Auto-close notification after 5 seconds
      Timer(Duration(seconds: 5), () {
        notification.close();
      });
    } catch (e) {
      print('❌ Error creating web notification: $e');
    }
  }

  /// Request mobile permissions
  Future<void> _requestMobilePermissions() async {
    if (kIsWeb) return;

    try {
      // Android specific permissions
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        // Request notification permission for Android 13+
        await androidImplementation?.requestNotificationsPermission();

        // Request exact alarm permission
        await androidImplementation?.requestExactAlarmsPermission();
      }

      // iOS specific permissions
      if (!kIsWeb && Platform.isIOS) {
        await _requestIOSPermissions();
      }
    } catch (e) {
      print('❌ Error requesting mobile permissions: $e');
    }
  }

  /// Request iOS permissions
  Future<void> _requestIOSPermissions() async {
    if (kIsWeb) return;

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// Handle notification response when user taps notification
  void _onNotificationResponse(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    if (response.payload == 'meal_reminder') {
      // Navigate to meal diary or add meal screen
    } else if (response.payload?.contains('test_notification') == true) {
      print('🧪 Test notification tapped');
    }
  }

  /// Start test notifications with cross-platform support
  Future<void> startTestNotifications() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      // Update state first
      _testNotificationsRunning = true;
      await _prefs?.setBool('test_notifications_running', true);

      if (kIsWeb) {
        // Web platform: Use safer browser notifications approach
        await _startWebTestNotifications();
      } else {
        // Mobile platform: Use flutter_local_notifications
        await _startMobileTestNotifications();
      }

      print('🔔 Test notifications started for ${kIsWeb ? 'web' : 'mobile'}');
    } catch (e) {
      print('❌ Error starting test notifications: $e');
      _testNotificationsRunning = false;
      await _prefs?.setBool('test_notifications_running', false);
      rethrow; // Rethrow to let UI handle the error
    }
  }

  /// Start test notifications for web platform using safer browser API approach
  Future<void> _startWebTestNotifications() async {
    if (!kIsWeb) return;

    if (!_webNotificationsPermissionGranted) {
      // Try to request permission again
      await _initializeWebNotifications();

      if (!_webNotificationsPermissionGranted) {
        throw Exception(
          'Web notifications permission not granted. Please allow notifications in your browser settings.',
        );
      }
    }

    // Store the start time for status tracking
    await _prefs?.setString(
      'test_notifications_start_time',
      DateTime.now().toIso8601String(),
    );

    // Start a timer to show notifications every 5 minutes for 2 hours (24 notifications)
    _scheduleWebTestNotifications();

    print('🌐 Web test notifications started with safer browser API');
  }

  /// Schedule web test notifications using safer browser API approach
  void _scheduleWebTestNotifications() {
    if (!kIsWeb || !_webNotificationsPermissionGranted) return;

    int notificationCount = 0;
    const maxNotifications = 24; // 2 hours worth

    // Show first notification immediately
    _showWebNotification(++notificationCount);

    // Schedule remaining notifications every 5 minutes
    Timer.periodic(Duration(minutes: 5), (timer) {
      if (notificationCount >= maxNotifications || !_testNotificationsRunning) {
        timer.cancel();
        if (notificationCount >= maxNotifications) {
          _testNotificationsRunning = false;
          _prefs?.setBool('test_notifications_running', false);
        }
        return;
      }

      _showWebNotification(++notificationCount);
    });
  }

  /// Show a web notification using safer browser API approach
  void _showWebNotification(int notificationNumber) async {
    if (!kIsWeb || !_webNotificationsPermissionGranted) return;

    try {
      final title = 'Test Notification #$notificationNumber 🧪';
      final body =
          'This is test notification $notificationNumber sent at ${DateTime.now().toString().substring(11, 19)}. Web browser notification!';

      // Use safer web-specific API
      _createWebNotificationSafe(
        title,
        body,
        'test-notification-$notificationNumber',
      );

      print('🌐 Web notification #$notificationNumber shown');
    } catch (e) {
      print('❌ Error showing web notification: $e');
    }
  }

  /// Start test notifications for mobile platforms
  Future<void> _startMobileTestNotifications() async {
    if (kIsWeb) return;

    // Cancel any existing test notifications first
    await _stopTestNotificationsInternal();

    // Schedule 24 notifications (2 hours worth, every 5 minutes)
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 1; i <= 24; i++) {
      final scheduledTime = now.add(Duration(minutes: 5 * i));
      await _scheduleTestNotification(
        id: 2000 + i,
        scheduledTime: scheduledTime,
        notificationNumber: i,
      );
    }

    print(
      '🔔 Mobile test notifications scheduled: 24 notifications over 2 hours',
    );
  }

  /// Schedule a single test notification
  Future<void> _scheduleTestNotification({
    required int id,
    required tz.TZDateTime scheduledTime,
    required int notificationNumber,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'test_notifications',
      'Test Notifications',
      channelDescription: 'Test notifications every 5 minutes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.active,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    final title = 'Test Notification #$notificationNumber 🧪';
    final body =
        'This is test notification $notificationNumber sent at ${scheduledTime.hour.toString().padLeft(2, '0')}:${scheduledTime.minute.toString().padLeft(2, '0')}. Tap to interact!';

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: 'test_notification_$notificationNumber',
    );
  }

  /// Stop test notifications
  Future<void> stopTestNotifications() async {
    _testNotificationsRunning = false;
    await _stopTestNotificationsInternal();
    print('🔕 All test notifications cancelled');
  }

  /// Internal method to stop test notifications without updating public state
  Future<void> _stopTestNotificationsInternal() async {
    try {
      await _prefs?.setBool('test_notifications_running', false);
      await _prefs?.remove('test_notifications_start_time');

      if (!kIsWeb) {
        // Cancel all test notification IDs (2001-2024)
        for (int i = 1; i <= 24; i++) {
          await _notificationsPlugin.cancel(2000 + i);
        }
      }
    } catch (e) {
      print('❌ Error stopping test notifications: $e');
    }
  }

  /// Show immediate notification for testing with cross-platform support
  Future<void> showTestNotification() async {
    if (!_isInitialized) {
      throw Exception('NotificationService not initialized');
    }

    try {
      if (kIsWeb) {
        await _showImmediateWebNotification();
      } else {
        await _showImmediateMobileNotification();
      }

      print(
        '📱 Immediate test notification sent for ${kIsWeb ? 'web' : 'mobile'}',
      );
    } catch (e) {
      print('❌ Error sending test notification: $e');
      rethrow; // Rethrow to let UI handle the error
    }
  }

  /// Show immediate web notification
  Future<void> _showImmediateWebNotification() async {
    if (!kIsWeb) return;

    if (!_webNotificationsPermissionGranted) {
      // Try to request permission
      await _initializeWebNotifications();

      if (!_webNotificationsPermissionGranted) {
        throw Exception(
          'Web notifications permission required. Please allow notifications in your browser settings.',
        );
      }
    }

    try {
      final title = 'Immediate Test Notification 🧪';
      final body =
          'This is an immediate test notification. System time: ${DateTime.now().toString().substring(11, 19)}';

      _createWebNotificationSafe(title, body, 'test-notification-immediate');
    } catch (e) {
      throw Exception('Failed to show web notification: $e');
    }
  }

  /// Show immediate mobile notification
  Future<void> _showImmediateMobileNotification() async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'test_notifications',
      'Test Notifications',
      channelDescription: 'Immediate test notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      enableVibration: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Immediate Test Notification 🧪',
      'This is an immediate test notification. System time: ${DateTime.now().toString().substring(11, 19)}',
      notificationDetails,
      payload: 'test_notification_immediate',
    );
  }

  /// Schedule daily meal reminder with cross-platform support
  Future<void> scheduleDailyMealReminder() async {
    if (!_isInitialized) {
      print('⚠️ NotificationService not initialized');
      return;
    }

    try {
      if (kIsWeb) {
        // For web, store reminder preference only
        await _prefs?.setBool('meal_reminders_enabled', true);
        print('🌐 Meal reminder preference saved for web');
        return;
      }

      // Check if user has meal reminders enabled
      final notificationPrefs =
          await UserSettingsService.instance.getNotificationPreferences();
      if (notificationPrefs?['meal_reminders'] != true) {
        print('📵 Meal reminders disabled for user');
        return;
      }

      // Cancel existing meal reminder
      await _notificationsPlugin.cancel(1001);

      // Calculate next 3PM
      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        15,
        0,
      );

      // If it's already past 3PM today, schedule for tomorrow
      if (now.isAfter(scheduledTime)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        'meal_reminders',
        'Promemoria Pasti',
        channelDescription: 'Promemoria giornalieri per registrare i pasti',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        1001,
        'Promemoria Pasto 🍽️',
        'È ora di registrare il tuo pasto! Non dimenticare di tenere traccia della tua alimentazione.',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'meal_reminder',
      );

      print('🔔 Daily meal reminder scheduled for ${scheduledTime.toString()}');
    } catch (e) {
      print('❌ Error scheduling meal reminder: $e');
    }
  }

  /// Get test notifications status with cross-platform support
  Future<Map<String, dynamic>> getTestNotificationStatus() async {
    // Always get the most current state from storage
    final isRunning = _prefs?.getBool('test_notifications_running') ?? false;
    _testNotificationsRunning = isRunning; // Sync internal state

    if (kIsWeb) {
      final startTimeStr = _prefs?.getString('test_notifications_start_time');
      int pendingCount = 0;

      if (startTimeStr != null && isRunning) {
        final startTime = DateTime.parse(startTimeStr);
        final elapsed = DateTime.now().difference(startTime).inMinutes;
        pendingCount = (120 - elapsed / 5)
            .clamp(0, 24)
            .round(); // 24 notifications over 2 hours
      }

      return {
        'isRunning': isRunning,
        'pendingCount': pendingCount,
        'nextNotification':
            isRunning ? 'Web browser notifications active' : null,
        'permissionGranted': _webNotificationsPermissionGranted,
      };
    } else {
      try {
        final pendingNotifications = await getPendingNotifications();
        final testNotifications = pendingNotifications
            .where(
              (notification) =>
                  notification.id >= 2001 && notification.id <= 2024,
            )
            .toList();

        return {
          'isRunning': isRunning,
          'pendingCount': testNotifications.length,
          'nextNotification': testNotifications.isNotEmpty
              ? testNotifications.first.title
              : null,
        };
      } catch (e) {
        return {
          'isRunning': isRunning,
          'pendingCount': 0,
          'nextNotification': null,
        };
      }
    }
  }

  /// Cancel meal reminder
  Future<void> cancelMealReminder() async {
    if (kIsWeb) {
      await _prefs?.setBool('meal_reminders_enabled', false);
      print('🌐 Meal reminder preference disabled for web');
      return;
    }

    await _notificationsPlugin.cancel(1001);
    print('🔕 Meal reminder cancelled');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    _testNotificationsRunning = false;
    await _prefs?.setBool('test_notifications_running', false);
    await _prefs?.remove('test_notifications_start_time');

    if (!kIsWeb) {
      await _notificationsPlugin.cancelAll();
    }

    print('🔕 All notifications cancelled');
  }

  /// Update meal reminder based on user preferences
  Future<void> updateMealReminderPreference(bool enabled) async {
    if (enabled) {
      await scheduleDailyMealReminder();
    } else {
      await cancelMealReminder();
    }
  }

  /// Check if notifications are enabled with cross-platform support
  Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) {
      return _webNotificationsPermissionGranted;
    }

    try {
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      } else if (!kIsWeb && Platform.isIOS) {
        final iosImplementation =
            _notificationsPlugin.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final settings = await iosImplementation?.checkPermissions();
        return settings?.isEnabled ?? false;
      }
    } catch (e) {
      print('❌ Error checking notification permissions: $e');
    }

    return false;
  }

  /// Get pending notifications (mobile only)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (kIsWeb) return [];

    try {
      return await _notificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }
}
