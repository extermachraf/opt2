import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import 'dart:typed_data';

class ProfileService {
  static ProfileService? _instance;
  static ProfileService get instance => _instance ??= ProfileService._();
  ProfileService._();

  final _client = SupabaseService.instance.client;
  final _auth = AuthService.instance;

  // Get complete user profile (user_profiles + medical_profiles)
  Future<Map<String, dynamic>?> getCompleteProfile() async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      // Get user profile
      final userProfile = await _client
          .from('user_profiles')
          .select()
          .eq('id', _auth.currentUser!.id)
          .maybeSingle();

      if (userProfile == null) return null;

      // Get medical profile
      final medicalProfile = await _client
          .from('medical_profiles')
          .select()
          .eq('user_id', _auth.currentUser!.id)
          .maybeSingle();

      return {...userProfile, 'medical_profile': medicalProfile};
    } catch (error) {
      throw Exception('Failed to get complete profile: $error');
    }
  }

  // Update user profile information
  Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      // Validate required fields
      if (profileData['full_name'] != null &&
          (profileData['full_name'] as String).trim().isEmpty) {
        throw Exception('Full name is required');
      }

      if (profileData['email'] != null &&
          !_isValidEmail(profileData['email'])) {
        throw Exception('Invalid email format');
      }

      // Remove any fields that shouldn't be updated
      final allowedFields = {
        'full_name',
        'email',
        'phone_number',
        'date_of_birth',
        'gender',
        'profile_image_url',
      };

      final cleanedData = Map<String, dynamic>.fromEntries(
        profileData.entries.where(
          (entry) => allowedFields.contains(entry.key) && entry.value != null,
        ),
      );

      if (cleanedData.isEmpty) {
        throw Exception('No valid fields to update');
      }

      final response = await _client
          .from('user_profiles')
          .update(cleanedData)
          .eq('id', _auth.currentUser!.id)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  // Update medical profile information with weight entry sync
  Future<Map<String, dynamic>> updateMedicalProfile(
    Map<String, dynamic> medicalData,
  ) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      // Store the original current_weight_kg before validation for weight entry sync
      double? newWeight;

      // Validate numerical fields
      if (medicalData['height_cm'] != null) {
        final height = double.tryParse(medicalData['height_cm'].toString());
        if (height == null || height <= 0 || height > 300) {
          throw Exception('Invalid height value');
        }
        medicalData['height_cm'] = height;
      }

      if (medicalData['current_weight_kg'] != null) {
        final weight = double.tryParse(
          medicalData['current_weight_kg'].toString(),
        );
        if (weight == null || weight <= 0 || weight > 500) {
          throw Exception('Invalid weight value');
        }
        medicalData['current_weight_kg'] = weight;
        newWeight = weight; // Store for weight entry sync
      }

      if (medicalData['target_weight_kg'] != null) {
        final targetWeight = double.tryParse(
          medicalData['target_weight_kg'].toString(),
        );
        if (targetWeight == null || targetWeight <= 0 || targetWeight > 500) {
          throw Exception('Invalid target weight value');
        }
        medicalData['target_weight_kg'] = targetWeight;
      }

      // Validate enum fields
      if (medicalData['activity_level'] != null &&
          ![
            'sedentary',
            'lightly_active',
            'moderately_active',
            'very_active',
            'extremely_active',
          ].contains(medicalData['activity_level'])) {
        throw Exception('Invalid activity level');
      }

      if (medicalData['goal_type'] != null &&
          ![
            'weight_loss',
            'weight_gain',
            'maintain_weight',
            'muscle_gain',
            'general_health',
          ].contains(medicalData['goal_type'])) {
        throw Exception('Invalid goal type');
      }

      // Set user_id for upsert
      medicalData['user_id'] = _auth.currentUser!.id;

      // Update medical profile
      final response = await _client
          .from('medical_profiles')
          .upsert(medicalData, onConflict: 'user_id')
          .select()
          .single();

      // Sync weight entry if current_weight_kg was updated
      if (newWeight != null) {
        await _syncWeightEntry(newWeight);
      }

      return response;
    } catch (error) {
      throw Exception('Failed to update medical profile: $error');
    }
  }

  // Private method to sync weight entry when current_weight_kg is updated
  Future<void> _syncWeightEntry(double weightKg) async {
    try {
      final userId = _auth.currentUser!.id;
      final now = DateTime.now();

      // Use upsert_weight_entry function if available, otherwise direct insert/update
      try {
        // Try using the upsert function first (more reliable with constraints)
        await _client.rpc('upsert_weight_entry', params: {
          'p_user_id': userId,
          'p_weight_kg': weightKg,
          'p_recorded_at': now.toIso8601String(),
          'p_notes': 'Sincronizzato dagli aggiornamenti del profilo',
        });
      } catch (functionError) {
        // Fallback to direct upsert if function fails
        await _client.from('weight_entries').upsert({
          'user_id': userId,
          'weight_kg': weightKg,
          'recorded_at': now.toIso8601String(),
          'notes': 'Sincronizzato dagli aggiornamenti del profilo',
        }, onConflict: 'user_id,recorded_at');
      }
    } catch (error) {
      // Don't throw error for weight entry sync failure
      // Log it but don't prevent medical profile update
      print('Warning: Failed to sync weight entry: $error');
    }
  }

  // Update complete profile (both user and medical data)
  Future<Map<String, dynamic>> updateCompleteProfile({
    Map<String, dynamic>? userProfileData,
    Map<String, dynamic>? medicalProfileData,
  }) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      Map<String, dynamic> results = {};

      // Update user profile if data provided
      if (userProfileData != null && userProfileData.isNotEmpty) {
        results['user_profile'] = await updateUserProfile(userProfileData);
      }

      // Update medical profile if data provided
      if (medicalProfileData != null && medicalProfileData.isNotEmpty) {
        results['medical_profile'] = await updateMedicalProfile(
          medicalProfileData,
        );
      }

      // Return complete updated profile
      final completeProfile = await getCompleteProfile();
      return completeProfile ?? {};
    } catch (error) {
      throw Exception('Failed to update complete profile: $error');
    }
  }

  // Upload profile image (if using Supabase Storage)
  Future<String?> uploadProfileImage(
    List<int> imageBytes,
    String fileName,
  ) async {
    if (!_auth.isAuthenticated) throw Exception('User not authenticated');

    try {
      final userId = _auth.currentUser!.id;
      final filePath = 'profiles/$userId/$fileName';

      print('🔵 ProfileService: Uploading to path: $filePath');
      print('🔵 ProfileService: Image size: ${imageBytes.length} bytes');

      // Upload to Supabase storage
      final response = await _client.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            Uint8List.fromList(imageBytes),
          );

      print('🔵 ProfileService: Upload response: $response');

      if (response.isNotEmpty) {
        final publicUrl =
            _client.storage.from('avatars').getPublicUrl(filePath);

        print('🔵 ProfileService: Public URL: $publicUrl');

        // Update user profile with new image URL
        await updateUserProfile({'profile_image_url': publicUrl});

        print('✅ ProfileService: Profile updated successfully');

        return publicUrl;
      }

      print('❌ ProfileService: Upload response is empty');
      return null;
    } catch (error) {
      print('❌ ProfileService: Upload error: $error');
      throw Exception('Failed to upload profile image: $error');
    }
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if email is already taken by another user
  Future<bool> isEmailAvailable(String email) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .neq('id', _auth.currentUser?.id ?? '')
          .limit(1);

      return response.isEmpty;
    } catch (error) {
      return false;
    }
  }

  // Check if user has completed screening
  Future<bool> isScreeningCompleted() async {
    if (!_auth.isAuthenticated) return false;

    try {
      final medicalProfile = await _client
          .from('medical_profiles')
          .select('screening_completed')
          .eq('user_id', _auth.currentUser!.id)
          .maybeSingle();

      return medicalProfile?['screening_completed'] == true;
    } catch (error) {
      print('Error checking screening status: $error');
      return false;
    }
  }

  // Get profile completion percentage
  Future<double> getProfileCompletionPercentage() async {
    final profile = await getCompleteProfile();
    if (profile == null) return 0.0;

    int totalFields = 0;
    int completedFields = 0;

    // Check user profile fields
    final userFields = [
      'full_name',
      'email',
      'phone_number',
      'date_of_birth',
      'gender',
    ];
    for (final field in userFields) {
      totalFields++;
      if (profile[field] != null &&
          profile[field].toString().trim().isNotEmpty) {
        completedFields++;
      }
    }

    // Check medical profile fields
    final medicalProfile = profile['medical_profile'];
    if (medicalProfile != null) {
      final medicalFields = [
        'height_cm',
        'current_weight_kg',
        'target_weight_kg',
        'activity_level',
        'goal_type',
      ];
      for (final field in medicalFields) {
        totalFields++;
        if (medicalProfile[field] != null) {
          completedFields++;
        }
      }
    } else {
      totalFields +=
          5; // Add medical fields to total even if profile doesn't exist
    }

    return totalFields > 0 ? (completedFields / totalFields) : 0.0;
  }
}
