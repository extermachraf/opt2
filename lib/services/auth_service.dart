import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/supabase_service.dart';
import '../services/biometric_auth_service.dart';

class AuthService {
  static AuthService? _instance;
  static AuthService get instance => _instance ??= AuthService._();
  AuthService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Get current user session
  Session? get currentSession => _client.auth.currentSession;

  // Hash password using SHA-256 (secure hashing)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Register new user with secure password hashing - NO OTP
  Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required DateTime birthDate,
    String? genderAtBirth, // Changed from required to nullable
    String? name,
    String? surname,
    String? telephone,
    String? birthplace,
    String? codiceFiscale,
    String? comuneResidenza,
    String? regionTreatment,
    // Add DPO consent parameters
    bool acceptedTermsOfService = false,
    bool acceptedPrivacyPolicy = false,
    bool acceptedDataProcessing = false,
  }) async {
    try {
      // Input validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email e password sono obbligatori');
      }

      if (!_isValidEmail(email)) {
        throw Exception('Formato email non valido');
      }

      if (password.length < 8) {
        throw Exception('Password deve essere di almeno 8 caratteri');
      }

      // DPO consent validation - all three must be true
      if (!acceptedTermsOfService ||
          !acceptedPrivacyPolicy ||
          !acceptedDataProcessing) {
        throw Exception('È necessario accettare tutti i termini per procedere');
      }

      // Check if user already exists
      final existingUser = await _client
          .from('user_profiles')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existingUser != null) {
        throw Exception('Utente con questa email esiste già');
      }

      // Create user in auth.users table with Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name ?? '',
          'surname': surname ?? '',
          'full_name': '${name ?? ''} ${surname ?? ''}'.trim(),
        },
      );

      if (authResponse.user == null) {
        throw Exception('Errore durante la creazione dell\'account');
      }

      // Create profile in user_profiles with hashed password for backup and consent flags
      final hashedPassword = _hashPassword(password);
      final fullName = '${name ?? ''} ${surname ?? ''}'.trim();

      await _client.from('user_profiles').upsert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName.isNotEmpty ? fullName : email.split('@')[0],
        'name': name,
        'surname': surname,
        'telephone': telephone,
        'birthplace': birthplace,
        'codice_fiscale': codiceFiscale?.toUpperCase(),
        'comune_residenza': comuneResidenza,
        'region_treatment': regionTreatment,
        'date_of_birth': birthDate.toIso8601String().split('T')[0],
        'gender': genderAtBirth?.isEmpty == true
            ? null
            : genderAtBirth, // Handle empty string as null
        'email_verified': true, // No OTP verification needed
        'registration_completed': true,
        'is_active': true,
        'role': 'patient',
        'password_hash': hashedPassword, // Store hashed password for backup
        // Store DPO consent flags
        'terms_of_service_accepted': acceptedTermsOfService,
        'privacy_policy_accepted': acceptedPrivacyPolicy,
        'data_processing_accepted': acceptedDataProcessing,
        'consent_timestamp': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // Since auth.signUp already signs in the user, return success with user data
      return {
        'success': true,
        'user_id': authResponse.user!.id,
        'user': authResponse.user,
        'session': authResponse.session,
        'message':
            'Registrazione completata con successo! Benvenuto in NutriVita.',
        'user_name': fullName.isNotEmpty ? fullName : email.split('@')[0],
        'immediate_login': true,
      };
    } catch (error) {
      throw Exception('Registrazione fallita: $error');
    }
  }

  // Login with email + password validation against database
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Input validation
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email e password sono obbligatori');
      }

      // First attempt: Try Supabase authentication
      try {
        final response = await _client.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null && response.session != null) {
          // Check if user profile exists
          final userProfile = await _client
              .from('user_profiles')
              .select(
                'id, email, full_name, is_active, email_verified, registration_completed',
              )
              .eq('id', response.user!.id)
              .maybeSingle();

          String userName = 'Utente';
          String fullNameForDB = email.split('@')[0]; // Default fallback

          if (userProfile != null) {
            userName = userProfile['full_name'] ?? email.split('@')[0];
            fullNameForDB = userProfile['full_name'] ?? email.split('@')[0];

            // Check if account is active
            if (userProfile['is_active'] == false) {
              await _client.auth.signOut(); // Sign out if account is inactive
              throw Exception('Account disattivato. Contatta il supporto.');
            }

            // Ensure profile is properly set up with required full_name
            await _client.from('user_profiles').upsert({
              'id': response.user!.id,
              'email': email,
              'full_name': fullNameForDB, // CRITICAL: Always provide full_name
              'email_verified': true,
              'registration_completed': true,
              'is_active': true,
              'updated_at': DateTime.now().toIso8601String(),
            });
          } else {
            // Create missing profile for authenticated user with required full_name
            final defaultName = email.split('@')[0];
            await _client.from('user_profiles').upsert({
              'id': response.user!.id,
              'email': email,
              'full_name': defaultName, // CRITICAL: Always provide full_name
              'email_verified': true,
              'registration_completed': true,
              'is_active': true,
              'role': 'patient',
              'created_at': DateTime.now().toIso8601String(),
              'updated_at': DateTime.now().toIso8601String(),
            });
            userName = defaultName;
          }

          return {
            'success': true,
            'user': response.user,
            'session': response.session,
            'message': 'Login effettuato con successo',
            'user_name': userName,
          };
        }
      } catch (authError) {
        // If Supabase auth fails, check if it's because user doesn't exist
        if (authError.toString().contains('Invalid login credentials')) {
          // Check if user exists in our database
          final userProfile = await _client
              .from('user_profiles')
              .select('id, email, full_name, is_active')
              .eq('email', email)
              .maybeSingle();

          if (userProfile == null) {
            throw Exception(
              'Account non trovato. Verifica l\'email o registrati.',
            );
          } else {
            throw Exception('Email o password non corretti');
          }
        } else {
          throw authError;
        }
      }

      throw Exception('Login fallito - errore inaspettato');
    } catch (error) {
      // Enhanced error handling with specific constraint violation detection
      String errorMessage = error.toString().replaceAll('Exception: ', '');

      // Handle specific PostgreSQL constraint violations
      if (errorMessage.contains('null value in column "full_name"') ||
          errorMessage.contains('violates not-null constraint')) {
        throw Exception('Errore nel profilo utente. Riprova il login.');
      } else if (errorMessage.contains('Account non trovato')) {
        throw Exception('Account non trovato. Verifica l\'email o registrati.');
      } else if (errorMessage.contains('Email o password non corretti') ||
          errorMessage.contains('Invalid login credentials')) {
        throw Exception('Email o password non corretti');
      } else if (errorMessage.contains('Account disattivato')) {
        throw Exception('Account disattivato. Contatta il supporto tecnico.');
      }

      throw Exception('Login fallito: $errorMessage');
    }
  }

  // Biometric sign in - new method
  Future<Map<String, dynamic>> signInWithBiometric({
    required String reason,
  }) async {
    try {
      // Check if user is already authenticated (has valid session)
      if (!isAuthenticated) {
        throw Exception(
          'Prima effettua il login normale per attivare l\'autenticazione biometrica',
        );
      }

      // Perform biometric authentication
      final biometricResult = await BiometricAuthService.instance.authenticate(
        signInTitle: reason,
        sensitiveTransaction: true,
      );

      if (biometricResult.isSuccess) {
        // Get current user profile
        final userProfile = await getCurrentUserProfile();

        return {
          'success': true,
          'user': currentUser,
          'session': currentSession,
          'message': 'Autenticazione biometrica completata',
          'user_name': userProfile?['full_name'] ?? 'Utente',
          'biometric_auth': true,
        };
      } else {
        throw Exception(biometricResult.message);
      }
    } catch (error) {
      throw Exception('Autenticazione biometrica fallita: $error');
    }
  }

  // Get current user profile - /me endpoint equivalent
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!isAuthenticated) {
      throw Exception('Utente non autenticato');
    }

    try {
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Impossibile recuperare il profilo utente: $error');
    }
  }

  // Sign out with proper session cleanup and user data preservation
  Future<void> signOut() async {
    try {
      // Sign out from Supabase (this clears the session but preserves user data)
      await _client.auth.signOut();

      print('✅ Logout completato - dati utente preservati nel database');
    } catch (error) {
      throw Exception('Logout fallito: $error');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> updates,
  ) async {
    if (!isAuthenticated) throw Exception('Utente non autenticato');

    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Aggiornamento profilo fallito: $error');
    }
  }

  // Forgot password flow
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw Exception('Email è obbligatoria');
      }

      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'https://nutrivita.com/reset-password',
      );

      return {
        'success': true,
        'message':
            'Email per il reset della password inviata. Controlla la tua casella di posta.',
      };
    } catch (error) {
      throw Exception('Reset password fallito: $error');
    }
  }

  // Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      final session = currentSession;
      if (session == null) return false;

      // Check if session is expired
      final now = DateTime.now();
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        session.expiresAt! * 1000,
      );

      if (now.isAfter(expiresAt)) {
        // Try to refresh the session
        final response = await _client.auth.refreshSession();
        return response.session != null;
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  // Check if biometric authentication is required
  Future<bool> isBiometricAuthRequired() async {
    try {
      return await BiometricAuthService.instance.isBiometricAuthRequired();
    } catch (error) {
      return false;
    }
  }

  // Quick biometric verification for sensitive operations
  Future<bool> verifyBiometricForSensitiveOperation({
    String reason = 'Conferma per continuare',
  }) async {
    try {
      return await BiometricAuthService.instance.quickBiometricCheck(
        reason: reason,
      );
    } catch (error) {
      print('Biometric verification failed: $error');
      return false;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Initialize persistent session listener
  void initializePersistentSession() {
    authStateChanges.listen((AuthState state) {
      final event = state.event;

      if (event == AuthChangeEvent.signedOut) {
        print('🔄 Utente disconnesso - dati preservati nel database');
      } else if (event == AuthChangeEvent.tokenRefreshed) {
        print('✅ Token di sessione aggiornato');
      } else if (event == AuthChangeEvent.signedIn) {
        print('✅ Utente autenticato con successo');
      }
    });
  }

  // Email validation helper
  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Create demo user if needed (for development/testing purposes)
  Future<void> ensureDemoUserExists() async {
    try {
      const demoEmail = 'yassine00kriouet@gmail.com';
      const demoPassword = 'Test123456!';

      // Check if demo user already exists
      final existingUser = await _client
          .from('user_profiles')
          .select('email')
          .eq('email', demoEmail)
          .maybeSingle();

      if (existingUser == null) {
        // Create demo user
        await registerUser(
          email: demoEmail,
          password: demoPassword,
          birthDate: DateTime(1995, 6, 15),
          genderAtBirth: 'male',
          name: 'Yassine',
          surname: 'Kriouet',
          telephone: '+39 123 456 7890',
        );
        print('✅ Demo user created successfully');
      } else {
        print('✅ Demo user already exists');
      }
    } catch (error) {
      print('⚠️ Could not create demo user: $error');
    }
  }
}
