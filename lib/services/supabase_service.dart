import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  late SupabaseClient _client;
  bool _initialized = false;

  // Initialize Supabase client
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get credentials from environment variables
      const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
      const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

      // Validate environment variables
      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
            'Supabase credentials not configured. Please check your env.json file.');
      }

      // Initialize Supabase
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true, // Enable debug mode for development
      );

      _client = Supabase.instance.client;
      _initialized = true;

      print('✅ Supabase initialized successfully');
    } catch (error) {
      print('❌ Supabase initialization failed: $error');
      throw Exception('Failed to initialize Supabase: $error');
    }
  }

  // Get the Supabase client
  SupabaseClient get client {
    if (!_initialized) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client;
  }

  // Check if Supabase is initialized
  bool get isInitialized => _initialized;

  // Get current user (auth state)
  User? get currentUser => _initialized ? _client.auth.currentUser : null;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges =>
      _initialized ? _client.auth.onAuthStateChange : const Stream.empty();

  // Test database connection
  Future<bool> testConnection() async {
    try {
      if (!_initialized) {
        await initialize();
      }

      // Simple query to test connection
      await _client.from('user_profiles').select('id').limit(1);
      return true;
    } catch (error) {
      print('❌ Database connection test failed: $error');
      return false;
    }
  }

  // Reset instance (useful for testing)
  static void reset() {
    _instance = null;
  }
}
