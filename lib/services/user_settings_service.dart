import 'package:shared_preferences/shared_preferences.dart';
import './supabase_service.dart';
import './notification_service.dart';

class UserSettingsService {
  static final UserSettingsService _instance = UserSettingsService._internal();
  factory UserSettingsService() => _instance;
  UserSettingsService._internal();

  static UserSettingsService get instance => _instance;

  final SupabaseService _supabaseService = SupabaseService.instance;
  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Gets user settings with fallback to local storage
  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      // Try Supabase first if available
      final client = _supabaseService.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId != null) {
        final response =
            await client
                .from('user_settings')
                .select()
                .eq('user_id', currentUserId)
                .maybeSingle();

        if (response != null) return response;
      }
    } catch (error) {
      print('❌ Supabase settings error: $error');
    }

    // Fallback to local storage
    await initialize();
    return {
      'biometric_enabled': _prefs?.getBool('biometric_enabled') ?? false,
      'theme_mode': _prefs?.getString('theme_mode') ?? 'system',
      'sync_frequency': _prefs?.getString('sync_frequency') ?? 'realtime',
      'high_contrast_enabled':
          _prefs?.getBool('high_contrast_enabled') ?? false,
      'large_text_enabled': _prefs?.getBool('large_text_enabled') ?? false,
      'reduced_animation_enabled':
          _prefs?.getBool('reduced_animation_enabled') ?? false,
      'text_scale_factor': _prefs?.getDouble('text_scale_factor') ?? 1.0,
    };
  }

  /// Updates user settings with dual storage
  Future<void> updateUserSettings(Map<String, dynamic> updates) async {
    try {
      // Try Supabase first
      final client = _supabaseService.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId != null) {
        final existing =
            await client
                .from('user_settings')
                .select('id')
                .eq('user_id', currentUserId)
                .maybeSingle();

        if (existing != null) {
          await client
              .from('user_settings')
              .update(updates)
              .eq('user_id', currentUserId);
        } else {
          final settingsData = {'user_id': currentUserId, ...updates};
          await client.from('user_settings').insert(settingsData);
        }
      }
    } catch (error) {
      print('❌ Supabase settings update error: $error');
    }

    // Always save to local storage as backup
    await initialize();
    for (final entry in updates.entries) {
      switch (entry.value.runtimeType) {
        case bool:
          await _prefs?.setBool(entry.key, entry.value as bool);
          break;
        case String:
          await _prefs?.setString(entry.key, entry.value as String);
          break;
        case double:
          await _prefs?.setDouble(entry.key, entry.value as double);
          break;
        case int:
          await _prefs?.setInt(entry.key, entry.value as int);
          break;
      }
    }
  }

  /// Gets accessibility settings with local fallback
  Future<Map<String, dynamic>?> getAccessibilitySettings() async {
    try {
      final settings = await getUserSettings();
      if (settings == null) return null;

      return {
        'high_contrast_enabled': settings['high_contrast_enabled'] ?? false,
        'large_text_enabled': settings['large_text_enabled'] ?? false,
        'reduced_animation_enabled':
            settings['reduced_animation_enabled'] ?? false,
        'text_scale_factor': settings['text_scale_factor'] ?? 1.0,
      };
    } catch (error) {
      print('❌ Accessibility settings error: $error');
      return null;
    }
  }

  /// Updates accessibility settings
  Future<void> updateAccessibilitySettings(
    Map<String, dynamic> accessibilityUpdates,
  ) async {
    try {
      final validatedUpdates = <String, dynamic>{};

      if (accessibilityUpdates.containsKey('high_contrast_enabled')) {
        validatedUpdates['high_contrast_enabled'] =
            accessibilityUpdates['high_contrast_enabled'] as bool;
      }

      if (accessibilityUpdates.containsKey('large_text_enabled')) {
        validatedUpdates['large_text_enabled'] =
            accessibilityUpdates['large_text_enabled'] as bool;
      }

      if (accessibilityUpdates.containsKey('reduced_animation_enabled')) {
        validatedUpdates['reduced_animation_enabled'] =
            accessibilityUpdates['reduced_animation_enabled'] as bool;
      }

      if (accessibilityUpdates.containsKey('text_scale_factor')) {
        final scaleFactor = accessibilityUpdates['text_scale_factor'] as double;
        validatedUpdates['text_scale_factor'] = scaleFactor.clamp(0.5, 2.0);
      }

      await updateUserSettings(validatedUpdates);
    } catch (error) {
      throw Exception(
        'Errore nell\'aggiornamento impostazioni accessibilità: $error',
      );
    }
  }

  /// Gets notification preferences with local fallback
  Future<Map<String, dynamic>?> getNotificationPreferences() async {
    try {
      // Try Supabase first
      final client = _supabaseService.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId != null) {
        final response =
            await client
                .from('user_notification_preferences')
                .select()
                .eq('user_id', currentUserId)
                .maybeSingle();

        if (response != null) return response;
      }
    } catch (error) {
      print('❌ Supabase notification preferences error: $error');
    }

    // Fallback to local storage
    await initialize();
    return {
      'meal_reminders': _prefs?.getBool('meal_reminders') ?? true,
      'medication_alerts': _prefs?.getBool('medication_alerts') ?? true,
      'progress_celebrations': _prefs?.getBool('progress_celebrations') ?? true,
      'healthcare_provider_messages':
          _prefs?.getBool('healthcare_provider_messages') ?? true,
      'weekly_reports': _prefs?.getBool('weekly_reports') ?? true,
    };
  }

  /// Updates notification preferences with dual storage
  Future<void> updateNotificationPreferences(
    Map<String, dynamic> updates,
  ) async {
    try {
      // Try Supabase first
      final client = _supabaseService.client;
      final currentUserId = client.auth.currentUser?.id;

      if (currentUserId != null) {
        final existing =
            await client
                .from('user_notification_preferences')
                .select('id')
                .eq('user_id', currentUserId)
                .maybeSingle();

        if (existing != null) {
          await client
              .from('user_notification_preferences')
              .update(updates)
              .eq('user_id', currentUserId);
        } else {
          final preferencesData = {'user_id': currentUserId, ...updates};
          await client
              .from('user_notification_preferences')
              .insert(preferencesData);
        }
      }
    } catch (error) {
      print('❌ Supabase notification preferences update error: $error');
    }

    // Always save to local storage
    await initialize();
    for (final entry in updates.entries) {
      if (entry.value is bool) {
        await _prefs?.setBool(entry.key, entry.value as bool);
      }
    }

    // Handle meal reminders specifically
    if (updates.containsKey('meal_reminders')) {
      final mealRemindersEnabled = updates['meal_reminders'] as bool;
      await NotificationService.instance.updateMealReminderPreference(
        mealRemindersEnabled,
      );
    }
  }

  /// Gets complete user preferences with fallback
  Future<Map<String, dynamic>> getCompleteUserPreferences() async {
    try {
      final settings = await getUserSettings();
      final notifications = await getNotificationPreferences();
      final accessibility = await getAccessibilitySettings();

      return {
        'settings': settings ?? {},
        'notifications': notifications ?? {},
        'accessibility': accessibility ?? {},
      };
    } catch (error) {
      print('❌ Complete preferences error: $error');
      return {'settings': {}, 'notifications': {}, 'accessibility': {}};
    }
  }

  /// Creates default settings for a user
  Future<void> createDefaultUserSettings(String userId) async {
    try {
      final client = _supabaseService.client;

      await client.from('user_settings').insert({
        'user_id': userId,
        'biometric_enabled': false,
        'theme_mode': 'system',
        'sync_frequency': 'realtime',
        'high_contrast_enabled': false,
        'large_text_enabled': false,
        'reduced_animation_enabled': false,
        'text_scale_factor': 1.0,
      });

      await client.from('user_notification_preferences').insert({
        'user_id': userId,
        'meal_reminders': true,
        'medication_alerts': true,
        'progress_celebrations': true,
        'healthcare_provider_messages': true,
        'weekly_reports': true,
      });
    } catch (error) {
      print('❌ Error creating default settings: $error');
      // Set local defaults if Supabase fails
      await initialize();
      await _prefs?.setBool('meal_reminders', true);
      await _prefs?.setBool('medication_alerts', true);
      await _prefs?.setString('theme_mode', 'system');
    }
  }

  /// Reset accessibility settings to defaults
  Future<void> resetAccessibilitySettings() async {
    try {
      await updateAccessibilitySettings({
        'high_contrast_enabled': false,
        'large_text_enabled': false,
        'reduced_animation_enabled': false,
        'text_scale_factor': 1.0,
      });
    } catch (error) {
      throw Exception(
        'Errore nel ripristino impostazioni accessibilità: $error',
      );
    }
  }
}
