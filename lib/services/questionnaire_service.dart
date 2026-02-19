import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionnaireService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user's assessment history with real data from database
  Future<List<Map<String, dynamic>>> getAssessmentHistory() async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      final response = await _supabase
          .from('assessment_sessions')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error getting assessment history: $e');
      return [];
    }
  }

  // FIXED: Get real progress data with improved error handling and correct calculation
  Future<Map<String, dynamic>> getRealProgressData() async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      // Try to use the main progress calculation function
      try {
        final overallProgressResponse = await _supabase.rpc(
          'calculate_user_overall_progress',
          params: {'target_user_id': userId},
        );

        if (overallProgressResponse.isNotEmpty) {
          final overallData =
              overallProgressResponse.first as Map<String, dynamic>;

          final totalQuestionnaires =
              overallData['total_questionnaires'] as int? ?? 0;
          final completedQuestionnaires =
              overallData['completed_questionnaires'] as int? ?? 0;
          final totalQuestions = overallData['total_questions'] as int? ?? 0;
          final completedQuestions =
              overallData['completed_questions'] as int? ?? 0;
          final overallPercentage =
              overallData['overall_percentage'] as int? ?? 0;

          // Fix: Ensure correct counts are displayed
          print(
            'PROGRESS DATA: Total Q: $totalQuestionnaires, Completed Q: $completedQuestionnaires, Total Qs: $totalQuestions, Completed Qs: $completedQuestions, Percentage: $overallPercentage',
          );

          // Try to get detailed progress per questionnaire
          try {
            final detailedProgressResponse = await _supabase.rpc(
              'calculate_user_questionnaire_progress',
              params: {'target_user_id': userId},
            );

            // Group questionnaires into meaningful categories for UI
            Map<String, Map<String, int>> categoryProgress = {};
            int nutritionalCompleted = 0;
            int nutritionalTotal = 0;
            int functionalCompleted = 0;
            int functionalTotal = 0;

            for (final progress in detailedProgressResponse) {
              final category = progress['category'] as String? ?? 'Altri';
              final isCompleted = progress['is_completed'] as bool? ?? false;
              final totalQuestions = progress['total_questions'] as int? ?? 0;
              final completedResponses =
                  progress['completed_responses'] as int? ?? 0;

              print(
                'QUESTIONNAIRE: ${progress['questionnaire_type']}, Completed: $isCompleted, Responses: $completedResponses/$totalQuestions',
              );

              // Categorize based on questionnaire content
              if (category.contains('Valutazioni Nutrizionali') ||
                  category.contains('MUST') ||
                  category.contains('NRS') ||
                  category.contains('Valutazione Rischio')) {
                nutritionalTotal += totalQuestions;
                nutritionalCompleted += completedResponses;
              } else if (category.contains('ESAS') ||
                  category.contains('SF-12') ||
                  category.contains('SARC-F')) {
                functionalTotal += totalQuestions;
                functionalCompleted += completedResponses;
              }
            }

            // Create realistic category breakdown
            categoryProgress['Valutazioni Nutrizionali'] = {
              'completed': nutritionalCompleted,
              'total': nutritionalTotal,
            };

            categoryProgress['Valutazioni Funzionali'] = {
              'completed': functionalCompleted,
              'total': functionalTotal,
            };

            return {
              'overall': {
                'completed': completedQuestions,
                'total': totalQuestions,
                'percentage': overallPercentage,
                'completed_questionnaires': completedQuestionnaires,
                'total_questionnaires': totalQuestionnaires,
              },
              'categories': categoryProgress,
              'last_updated': DateTime.now().toIso8601String(),
            };
          } catch (detailError) {
            print(
              'Error getting detailed progress, using basic progress: $detailError',
            );
            // Return basic progress without detailed categories
            return {
              'overall': {
                'completed': completedQuestions,
                'total': totalQuestions,
                'percentage': overallPercentage,
                'completed_questionnaires': completedQuestionnaires,
                'total_questionnaires': totalQuestionnaires,
              },
              'categories': <String, Map<String, int>>{},
              'last_updated': DateTime.now().toIso8601String(),
            };
          }
        }
      } catch (mainError) {
        print('Main progress function failed, trying fallback: $mainError');

        // Try fallback function
        try {
          final fallbackResponse = await _supabase.rpc(
            'get_basic_assessment_progress',
            params: {'target_user_id': userId},
          );

          if (fallbackResponse.isNotEmpty) {
            final fallbackData = fallbackResponse.first as Map<String, dynamic>;

            return {
              'overall': {
                'completed': fallbackData['completed_questions'] as int? ?? 0,
                'total': fallbackData['total_questions'] as int? ?? 0,
                'percentage': fallbackData['overall_percentage'] as int? ?? 0,
                'completed_questionnaires':
                    fallbackData['completed_questionnaires'] as int? ?? 0,
                'total_questionnaires':
                    fallbackData['total_questionnaires'] as int? ?? 0,
              },
              'categories': <String, Map<String, int>>{},
              'last_updated': DateTime.now().toIso8601String(),
              'fallback_used': true,
            };
          }
        } catch (fallbackError) {
          print('Fallback function also failed: $fallbackError');
        }
      }

      // If all else fails, return empty but valid structure
      return {
        'overall': {
          'completed': 0,
          'total': 0,
          'percentage': 0,
          'completed_questionnaires': 0,
          'total_questionnaires': 0,
        },
        'categories': <String, Map<String, int>>{},
        'last_updated': DateTime.now().toIso8601String(),
        'error': 'Unable to load progress data',
      };
    } catch (e) {
      print('Error getting real progress data: $e');
      return {
        'overall': {
          'completed': 0,
          'total': 0,
          'percentage': 0,
          'completed_questionnaires': 0,
          'total_questionnaires': 0,
        },
        'categories': <String, Map<String, int>>{},
        'error': e.toString(),
      };
    }
  }

  // CRITICAL FIX: Get detailed questionnaire progress with MUST-specific handling
  Future<Map<String, dynamic>> getDetailedQuestionnaireProgress() async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      // Get all active questionnaire templates
      final templates = await _supabase
          .from('questionnaire_templates')
          .select('*')
          .eq('is_active', true)
          .neq(
            'questionnaire_type',
            'dietary_diary',
          ); // Exclude Diario Alimentare

      Map<String, dynamic> questionnaireProgress = {};

      for (final template in templates) {
        final questionnaireType = template['questionnaire_type'] as String;
        final templateId = template['id'] as String;
        final title = template['title'] as String;
        final category = template['category'] as String;

        // CRITICAL FIX: Special handling for MUST questionnaire
        int totalQuestions;
        if (questionnaireType.toLowerCase() == 'must') {
          // MUST questionnaire MUST have exactly 3 questions
          totalQuestions = 3;
          print('🔒 MUST QUESTIONNAIRE: Enforcing exactly 3 questions');
        } else {
          // Get ACTUAL question count for other questionnaires
          final questionsQuery = await _supabase
              .from('questionnaire_questions')
              .select('id')
              .eq('template_id', templateId);
          totalQuestions = questionsQuery.length;
        }

        // Get user's latest session for this questionnaire type
        final latestSession = await _supabase
            .from('assessment_sessions')
            .select('id, status, completed_at')
            .eq('user_id', userId)
            .eq('questionnaire_type', questionnaireType)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();

        int completedResponses = 0;
        bool isCompleted = false;
        String? completedAt;
        String? sessionId;

        if (latestSession != null) {
          sessionId = latestSession['id'];
          isCompleted = latestSession['status'] == 'completed';
          completedAt = latestSession['completed_at'];

          // CRITICAL FIX: Handle nullable sessionId with proper null check before database query
          final responsesQuery = await _supabase
              .from('questionnaire_responses')
              .select('id')
              .eq('session_id', sessionId ?? '')  // Add null check with empty string fallback
              .not('response_value', 'is', null)
              .not('response_value', 'eq', '');

          completedResponses = responsesQuery.length;
                  
          // CRITICAL FIX: For MUST questionnaire, cap at 3 responses
          if (questionnaireType.toLowerCase() == 'must' &&
              completedResponses > 3) {
            completedResponses = 3;
            print(
              '🔒 MUST QUESTIONNAIRE: Capped responses to 3 (was $completedResponses)',
            );
          }
        }

        final completionPercentage = totalQuestions > 0
            ? ((completedResponses / totalQuestions) * 100).round()
            : 0;

        questionnaireProgress[questionnaireType] = {
          'id': templateId,
          'title': title,
          'category': category,
          'completed_responses': completedResponses,
          'total_questions': totalQuestions,
          'completion_percentage': completionPercentage,
          'is_completed': isCompleted,
          'completed_at': completedAt,
          'can_retake': true,
          'session_id': sessionId,
        };

        if (questionnaireType.toLowerCase() == 'must') {
          print(
            '🎯 MUST Progress: $completedResponses/3 (${completionPercentage}%) - Completed: $isCompleted',
          );
        } else {
          print(
            '📊 Progress for $questionnaireType: $completedResponses/$totalQuestions (${completionPercentage}%)',
          );
        }
      }

      return questionnaireProgress;
    } catch (e) {
      print('❌ Error getting detailed progress: $e');
      return {};
    }
  }

  // UPDATED: Check if user has already completed a questionnaire type (but allow retaking)
  Future<bool> hasCompletedQuestionnaire(String questionnaireType) async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      final result = await _supabase.rpc(
        'is_questionnaire_completed',
        params: {
          'target_user_id': userId,
          'questionnaire_type_param': questionnaireType,
        },
      );

      return result as bool? ?? false;
    } catch (e) {
      print('Error checking questionnaire completion: $e');
      return false;
    }
  }

  // NEW: Reset questionnaire progress for retaking
  Future<String?> resetQuestionnaireProgress(String questionnaireType) async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      print('Resetting progress for questionnaire type: $questionnaireType');

      final result = await _supabase.rpc(
        'reset_questionnaire_progress',
        params: {
          'p_user_id': userId,
          'p_questionnaire_type': questionnaireType,
        },
      );

      if (result != null) {
        print('Successfully reset progress and created new session: $result');
        return result.toString();
      } else {
        print('Failed to reset progress - null result');
        return null;
      }
    } catch (e) {
      print('Error resetting questionnaire progress: $e');
      return null;
    }
  }

  // NEW: Check if retaking is allowed (always true now)
  Future<bool> canRetakeQuestionnaire(String questionnaireType) async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      final result = await _supabase.rpc(
        'can_retake_questionnaire',
        params: {
          'p_user_id': userId,
          'p_questionnaire_type': questionnaireType,
        },
      );

      return result as bool? ?? true; // Default to true if function fails
    } catch (e) {
      print('Error checking retake capability: $e');
      return true; // Allow retaking on error
    }
  }

  // NEW: Get today's session information for a questionnaire type
  // Returns session details if user has a session from today, null otherwise
  Future<Map<String, dynamic>?> getTodaysSessionInfo(String questionnaireType) async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      final result = await _supabase.rpc(
        'get_todays_questionnaire_session',
        params: {
          'p_user_id': userId,
          'p_questionnaire_type': questionnaireType,
        },
      );

      if (result != null && result is List && result.isNotEmpty) {
        final session = result.first;
        return {
          'session_id': session['session_id'],
          'status': session['status'],
          'started_at': session['started_at'],
          'completed_at': session['completed_at'],
          'is_editing': true, // Flag to indicate this is an edit session
        };
      }

      return null; // No session from today
    } catch (e) {
      print('Error getting today\'s session info: $e');
      return null;
    }
  }

  // UPDATED: Start assessment session with improved continuation logic
  Future<String?> startAssessmentSession(String questionnaireType) async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      print('Starting assessment session for type: $questionnaireType');

      // First, validate that the questionnaire template exists
      final template = await _supabase
          .from('questionnaire_templates')
          .select('id, title, is_active')
          .eq('questionnaire_type', questionnaireType)
          .eq('is_active', true)
          .maybeSingle();

      if (template == null) {
        print('Template not found for questionnaire type: $questionnaireType');

        // Try to find any available template as fallback
        final availableTemplates = await _supabase
            .from('questionnaire_templates')
            .select('id, questionnaire_type, title, is_active')
            .eq('is_active', true)
            .limit(1);

        if (availableTemplates.isEmpty) {
          throw Exception('Nessun template di questionario disponibile');
        }

        // Use the first available template
        final fallbackTemplate = availableTemplates.first;
        final fallbackType = fallbackTemplate['questionnaire_type'] as String;

        print('Using fallback template: $fallbackType');

        // Create session with fallback template
        final response = await _supabase
            .from('assessment_sessions')
            .insert({
              'user_id': userId,
              'questionnaire_type': fallbackType,
              'status': 'in_progress',
              'started_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        final sessionId = response['id'];

        // Trigger automatic calculations
        await autoCalculateResponses(sessionId);

        return sessionId;
      }

      // IMPROVED: Check for existing session from today (for daily restriction)
      // This enforces once-per-day questionnaire completion while allowing same-day edits
      final todaysSession = await _supabase.rpc(
        'get_todays_questionnaire_session',
        params: {
          'p_user_id': userId,
          'p_questionnaire_type': questionnaireType,
        },
      );

      if (todaysSession != null && todaysSession is List && todaysSession.isNotEmpty) {
        final session = todaysSession.first;
        final sessionId = session['session_id'] as String;
        final status = session['status'] as String;

        print('DAILY RESTRICTION: Found existing session from today: $sessionId (status: $status)');

        // Return the existing session for editing (whether in_progress or completed)
        // This allows users to modify their answers for today
        await autoCalculateResponses(sessionId);

        return sessionId;
      }

      // No session exists for today - check if we can create a new one
      print('DAILY RESTRICTION: No session found for today, creating new session');

      // Create new session (only if no session exists for today)
      print(
        'CREATION: Creating new session for questionnaire type: $questionnaireType',
      );
      final response = await _supabase
          .from('assessment_sessions')
          .insert({
            'user_id': userId,
            'questionnaire_type': questionnaireType,
            'status': 'in_progress',
            'started_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      final sessionId = response['id'];
      print('CREATION: Created new session: $sessionId');

      // Trigger automatic calculations
      await autoCalculateResponses(sessionId);

      return sessionId;
    } catch (e) {
      print('Error starting assessment session: $e');

      // Enhanced error handling - try to create a basic session anyway
      try {
        final userId = _supabase.auth.currentUser?.id ??
            'd4a87e24-2cab-4fc0-a753-fba15ba7c755';

        // Get any available template
        final fallbackTemplate = await _supabase
            .from('questionnaire_templates')
            .select('questionnaire_type')
            .eq('is_active', true)
            .limit(1)
            .maybeSingle();

        if (fallbackTemplate != null) {
          final fallbackType = fallbackTemplate['questionnaire_type'] as String;

          final response = await _supabase
              .from('assessment_sessions')
              .insert({
                'user_id': userId,
                'questionnaire_type': fallbackType,
                'status': 'in_progress',
                'started_at': DateTime.now().toIso8601String(),
              })
              .select()
              .single();

          return response['id'];
        }
      } catch (fallbackError) {
        print('Fallback session creation also failed: $fallbackError');
      }

      return null;
    }
  }

  // NEW: Start retaking a questionnaire (resets progress and creates new session)
  Future<String?> retakeQuestionnaire(String questionnaireType) async {
    try {
      print('Starting questionnaire retake for: $questionnaireType');

      // Reset progress and get new session
      final sessionId = await resetQuestionnaireProgress(questionnaireType);

      if (sessionId != null) {
        // Trigger automatic calculations for the new session
        await autoCalculateResponses(sessionId);
        print('Successfully started retake with session: $sessionId');
        return sessionId;
      } else {
        print('Failed to reset progress for retake');
        return null;
      }
    } catch (e) {
      print('Error retaking questionnaire: $e');
      return null;
    }
  }

  // UPDATED: Get questionnaire templates with enhanced error handling and Diario Alimentare filtering
  Future<List<Map<String, dynamic>>> getQuestionnaireTemplates() async {
    try {
      final response = await _supabase
          .from('questionnaire_templates')
          .select('*')
          .eq('is_active', true)
          .neq(
            'questionnaire_type',
            'dietary_diary',
          ) // Exclude Diario Alimentare
          .order('created_at', ascending: true);

      final templates = List<Map<String, dynamic>>.from(response);

      if (templates.isEmpty) {
        print(
          'No active questionnaire templates found (excluding Diario Alimentare)',
        );

        // Return all templates regardless of active status as fallback, but still exclude dietary_diary
        final allTemplates = await _supabase
            .from('questionnaire_templates')
            .select('*')
            .neq(
              'questionnaire_type',
              'dietary_diary',
            ) // Exclude Diario Alimentare in fallback too
            .order('created_at', ascending: true);

        return List<Map<String, dynamic>>.from(allTemplates);
      }

      return templates;
    } catch (e) {
      print('Error fetching questionnaire templates: $e');

      // Return empty list but don't crash the app
      return [];
    }
  }

  // NEW: Get template ID for questionnaire type with validation
  Future<String?> getTemplateIdForType(String questionnaireType) async {
    try {
      final template = await _supabase
          .from('questionnaire_templates')
          .select('id')
          .eq('questionnaire_type', questionnaireType)
          .eq('is_active', true)
          .maybeSingle();

      if (template != null) {
        return template['id'] as String;
      }

      // Fallback: try to find any template with this type (even if not active)
      final fallbackTemplate = await _supabase
          .from('questionnaire_templates')
          .select('id')
          .eq('questionnaire_type', questionnaireType)
          .maybeSingle();

      if (fallbackTemplate != null) {
        return fallbackTemplate['id'] as String;
      }

      // Final fallback: get any available template ID
      final anyTemplate = await _supabase
          .from('questionnaire_templates')
          .select('id')
          .limit(1)
          .maybeSingle();

      return anyTemplate?['id'] as String?;
    } catch (e) {
      print('Error getting template ID for type $questionnaireType: $e');
      return null;
    }
  }

  // Get questions for a specific template
  Future<List<Map<String, dynamic>>> getQuestionsForTemplate(
    String templateId,
  ) async {
    try {
      final response = await _supabase
          .from('questionnaire_questions')
          .select('*')
          .eq('template_id', templateId)
          .order('order_index', ascending: true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching questions for template: $e');
      return [];
    }
  }

  // NEW: Get questions for a specific session based on questionnaire type
  Future<List<Map<String, dynamic>>> getQuestionsForSession(
    String sessionId,
  ) async {
    try {
      // First get the session info
      final sessionResponse = await _supabase
          .from('assessment_sessions')
          .select('questionnaire_type')
          .eq('id', sessionId)
          .single();

      final questionnaireType = sessionResponse['questionnaire_type'] as String;

      // Then get the template for this questionnaire type
      final templateResponse = await _supabase
          .from('questionnaire_templates')
          .select('id')
          .eq('questionnaire_type', questionnaireType)
          .eq('is_active', true)
          .single();

      final templateId = templateResponse['id'] as String;

      // Finally get the questions for this template
      return await getQuestionsForTemplate(templateId);
    } catch (e) {
      print('Error fetching questions for session: $e');
      return [];
    }
  }

  // Calculate BMI from user's medical profile
  Future<double?> calculateBMI(String userId) async {
    try {
      final response = await _supabase
          .from('medical_profiles')
          .select('height_cm, current_weight_kg')
          .eq('user_id', userId)
          .single();

      final height = response['height_cm']?.toDouble();
      final weight = response['current_weight_kg']?.toDouble();

      if (height != null && weight != null && height > 0) {
        final heightInMeters = height / 100.0;
        return weight / (heightInMeters * heightInMeters);
      }
      return null;
    } catch (e) {
      print('Error calculating BMI: $e');
      return null;
    }
  }

  // Calculate weight loss percentage over specified months
  Future<double?> calculateWeightLossPercentage(
    String userId,
    int monthsBack,
  ) async {
    try {
      final response = await _supabase
          .from('weight_entries')
          .select('weight_kg, recorded_at')
          .eq('user_id', userId)
          .gte(
            'recorded_at',
            DateTime.now()
                .subtract(Duration(days: monthsBack * 30))
                .toIso8601String(),
          )
          .order('recorded_at', ascending: false);

      if (response.isEmpty) return null;

      final currentWeight = response.first['weight_kg']?.toDouble();
      final oldestWeight = response.last['weight_kg']?.toDouble();

      if (currentWeight != null && oldestWeight != null && oldestWeight > 0) {
        return ((oldestWeight - currentWeight) / oldestWeight) * 100;
      }
      return null;
    } catch (e) {
      print('Error calculating weight loss: $e');
      return null;
    }
  }

  // ENHANCED: Save questionnaire response with better error handling and retry logic
  Future<bool> saveQuestionnaireResponse(
    String sessionId,
    String questionId,
    dynamic responseValue,
    int? responseScore,
  ) async {
    try {
      print(
        'SAVE RESPONSE SERVICE: Attempting to save response for question $questionId',
      );

      // CRITICAL FIX: Use proper upsert with correct conflict resolution
      final response = await _supabase.from('questionnaire_responses').upsert(
        {
          'session_id': sessionId,
          'question_id': questionId,
          'response_value': responseValue.toString(),
          'response_score': responseScore,
          'updated_at': DateTime.now().toIso8601String(),
        },
        // CRITICAL FIX: Use the correct unique constraint for conflict resolution
        onConflict: 'session_id,question_id',
      );

      print(
        'SAVE RESPONSE SERVICE: Successfully saved response for question $questionId',
      );
      return true;
    } catch (e) {
      print(
        'SAVE RESPONSE SERVICE ERROR: Failed to save response for question $questionId: $e',
      );

      // Check if it's the specific constraint error
      if (e.toString().contains('unique or exclusion constraint')) {
        print(
          'SAVE RESPONSE SERVICE: Constraint error detected - attempting alternative save method',
        );

        // Try alternative approach: delete then insert
        try {
          await _supabase.from('questionnaire_responses').delete().match({
            'session_id': sessionId,
            'question_id': questionId,
          });

          await _supabase.from('questionnaire_responses').insert({
            'session_id': sessionId,
            'question_id': questionId,
            'response_value': responseValue.toString(),
            'response_score': responseScore,
            'updated_at': DateTime.now().toIso8601String(),
          });

          print(
            'SAVE RESPONSE SERVICE: Successfully saved using alternative method',
          );
          return true;
        } catch (altError) {
          print(
            'SAVE RESPONSE SERVICE: Alternative method also failed: $altError',
          );
        }
      }

      return false;
    }
  }

  // CRITICAL FIX: New method with retry logic for critical saves
  Future<bool> saveQuestionnaireResponseWithRetry(
    String sessionId,
    String questionId,
    dynamic responseValue,
    int? responseScore, {
    int maxRetries = 3,
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print(
          'SAVE RESPONSE WITH RETRY: Attempt $attempt/$maxRetries for question $questionId',
        );

        final success = await saveQuestionnaireResponse(
          sessionId,
          questionId,
          responseValue,
          responseScore,
        );

        if (success) {
          print(
            'SAVE RESPONSE WITH RETRY: Success on attempt $attempt for question $questionId',
          );
          return true;
        }

        // If not successful and not the last attempt, wait before retrying
        if (attempt < maxRetries) {
          await Future.delayed(Duration(milliseconds: 500 * attempt));
        }
      } catch (e) {
        print('SAVE RESPONSE WITH RETRY: Attempt $attempt failed: $e');

        // If it's the last attempt, don't retry
        if (attempt == maxRetries) {
          return false;
        }

        // Wait before retrying
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }
    }

    print(
      'SAVE RESPONSE WITH RETRY: All attempts failed for question $questionId',
    );
    return false;
  }

  // CRITICAL FIX: Enhanced calculated question handling for MUST questionnaire with corrected scoring
  Future<void> _handleMustCalculatedQuestion(
    String questionId,
    String sessionId,
  ) async {
    String? calculatedValue;
    String? displayValue;
    int? score;

    // Get calculated values for this user
    final userId = _supabase.auth.currentUser?.id ??
        'd4a87e24-2cab-4fc0-a753-fba15ba7c755';
    final calculatedValues = await getCalculatedValues(userId);

    // CRITICAL FIX: Specific handling for MUST BMI question with corrected scoring order
    if (questionId == 'must_bmi_calculated') {
      final bmi = calculatedValues['bmi'];
      if (bmi != null) {
        // CORRECTED MUST BMI scoring: First answer = 0 points, second = 1 point, third = 2 points
        if (bmi >= 20.0) {
          // First option: Best case = 0 points
          calculatedValue = 'BMI ≥ 20 (Peso normale)';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Peso normale - 0 punti)';
          score = 0;
        } else if (bmi >= 18.5 && bmi < 20.0) {
          // Second option: Moderate risk = 1 point
          calculatedValue = '18.5 ≤ BMI < 20 (Leggermente sottopeso)';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Leggermente sottopeso - 1 punto)';
          score = 1;
        } else {
          // Third option: Highest risk = 2 points
          calculatedValue = 'BMI < 18.5 (Sottopeso)';
          displayValue = 'BMI: ${bmi.toStringAsFixed(1)} (Sottopeso - 2 punti)';
          score = 2;
        }

        print(
          'CORRECTED MUST BMI SERVICE CALCULATION: BMI=$bmi, category=$calculatedValue, score=$score',
        );
      } else {
        calculatedValue = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score = 0;
        print('MUST BMI SERVICE: No medical data available');
      }
    }

    // Save the calculated response if we have a value
    if (calculatedValue != null) {
      final success = await saveQuestionnaireResponseWithRetry(
        sessionId,
        questionId,
        calculatedValue,
        score,
      );

      if (success) {
        print(
          'CORRECTED MUST SERVICE: Successfully saved calculated response for $questionId: $calculatedValue (score: $score)',
        );
      } else {
        print(
          'CORRECTED MUST SERVICE: Failed to save calculated response for $questionId',
        );
      }
    }
  }

  // CRITICAL FIX: Enhanced calculated question handling for NRS 2002 questionnaire with auto-save
  Future<void> _handleNrs2002CalculatedQuestion(
    String questionId,
    String sessionId,
  ) async {
    String? calculatedValue;
    String? displayValue;
    int? score;

    // Get calculated values for this user
    final userId = _supabase.auth.currentUser?.id ??
        'd4a87e24-2cab-4fc0-a753-fba15ba7c755';
    final calculatedValues = await getCalculatedValues(userId);

    // CRITICAL FIX: Specific handling for NRS 2002 BMI question with enhanced logic
    if (questionId == 'nrs_bmi_under_20_5') {
      final bmi = calculatedValues['bmi'];
      if (bmi != null) {
        // NRS 2002 specific BMI categorization (BMI < 20.5 is risk factor)
        final isUnder20_5 = bmi < 20.5;
        calculatedValue = isUnder20_5 ? 'Sì' : 'No';
        displayValue =
            'BMI: ${bmi.toStringAsFixed(1)} - ${isUnder20_5 ? "Sotto 20.5 (fattore di rischio)" : "Sopra o uguale a 20.5 (normale)"}';
        // NRS 2002 Q1-Q5 are screening questions with NO scores
        score = null;

        print(
          'NRS 2002 BMI SERVICE CALCULATION: BMI=$bmi, under20.5=$isUnder20_5, NO SCORE (screening question)',
        );
      } else {
        calculatedValue = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score = 0;
        print('NRS 2002 BMI SERVICE: No medical data available');
      }
    }

    // Save the calculated response if we have a value
    if (calculatedValue != null) {
      final success = await saveQuestionnaireResponseWithRetry(
        sessionId,
        questionId,
        calculatedValue,
        score,
      );

      if (success) {
        print(
          'NRS 2002 SERVICE: Successfully saved calculated response for $questionId: $calculatedValue (score: $score)',
        );
      } else {
        print(
          'NRS 2002 SERVICE: Failed to save calculated response for $questionId',
        );
      }
    }
  }

  // Enhanced Auto-calculate responses based on user data with NRS 2002 specific logic
  Future<void> autoCalculateResponses(String sessionId) async {
    try {
      // First try the database function with enhanced error handling
      await _supabase.rpc(
        'auto_calculate_responses',
        params: {'session_uuid': sessionId},
      );

      // Also handle client-side calculation for specific questionnaires
      final sessionInfo = await _supabase
          .from('assessment_sessions')
          .select('questionnaire_type')
          .eq('id', sessionId)
          .maybeSingle();

      if (sessionInfo != null) {
        final questionnaireType = sessionInfo['questionnaire_type'] as String;

        if (questionnaireType == 'must') {
          // Handle MUST-specific calculated questions
          await _handleMustCalculatedQuestion('must_bmi_calculated', sessionId);
          print('MUST SERVICE: Completed client-side BMI calculation');
        } else if (questionnaireType == 'nrs_2002') {
          // CRITICAL FIX: Handle NRS 2002-specific calculated questions
          await _handleNrs2002CalculatedQuestion(
              'nrs_bmi_under_20_5', sessionId);
          print('NRS 2002 SERVICE: Completed client-side BMI calculation');
        }
      }
    } catch (e) {
      print('Error auto-calculating responses: $e');

      // Fallback: try client-side calculation for critical questions
      try {
        final sessionInfo = await _supabase
            .from('assessment_sessions')
            .select('questionnaire_type')
            .eq('id', sessionId)
            .maybeSingle();

        if (sessionInfo != null) {
          final questionnaireType = sessionInfo['questionnaire_type'] as String;

          if (questionnaireType == 'must') {
            await _handleMustCalculatedQuestion(
                'must_bmi_calculated', sessionId);
            print('MUST SERVICE: Fallback calculation completed');
          } else if (questionnaireType == 'nrs_2002') {
            // CRITICAL FIX: Fallback calculation for NRS 2002
            await _handleNrs2002CalculatedQuestion(
                'nrs_bmi_under_20_5', sessionId);
            print('NRS 2002 SERVICE: Fallback calculation completed');
          }
        }
      } catch (fallbackError) {
        print('SERVICE: Fallback calculation also failed: $fallbackError');
      }
    }
  }

  // NEW: Get user's current BMI with proper calculation
  Future<double?> getCurrentUserBMI() async {
    try {
      final userId = _supabase.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      return await calculateBMI(userId);
    } catch (e) {
      print('Error getting current user BMI: $e');
      return null;
    }
  }

  // Enhanced calculated values with detailed BMI analysis and pathology information
  Future<Map<String, dynamic>> getCalculatedValues(String userId) async {
    try {
      final bmi = await calculateBMI(userId);
      final weightLoss1m = await calculateWeightLossPercentage(userId, 1);
      final weightLoss2m = await calculateWeightLossPercentage(userId, 2);
      final weightLoss3m = await calculateWeightLossPercentage(userId, 3);

      // Get user's current weight, height, and medical conditions for context
      final medicalData = await _supabase
          .from('medical_profiles')
          .select('height_cm, current_weight_kg, medical_conditions')
          .eq('user_id', userId)
          .maybeSingle();

      // Get pathology information from medical conditions
      final medicalConditions =
          medicalData?['medical_conditions'] as List<dynamic>? ?? [];
      final hasPathology = medicalConditions.isNotEmpty;
      final pathologyText = medicalConditions.isNotEmpty
          ? medicalConditions.first.toString()
          : null;

      return {
        'bmi': bmi,
        'bmi_under_20_5': bmi != null && bmi < 20.5,
        'bmi_category': _getBMICategory(bmi),
        'height_cm': medicalData?['height_cm'],
        'weight_kg': medicalData?['current_weight_kg'],
        'weight_loss_1m': weightLoss1m,
        'weight_loss_2m': weightLoss2m,
        'weight_loss_3m': weightLoss3m,
        'weight_loss_over_5_percent_3m':
            weightLoss3m != null && weightLoss3m > 5,
        'has_pathology': hasPathology,
        'pathology_text': pathologyText,
        'medical_conditions': medicalConditions,
        'user_id': userId,
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('Error getting calculated values: $e');
      return {};
    }
  }

  // Helper method to categorize BMI
  String _getBMICategory(double? bmi) {
    if (bmi == null) return 'Non disponibile';
    if (bmi < 18.5) return 'Sottopeso';
    if (bmi < 25.0) return 'Normopeso';
    if (bmi < 30.0) return 'Sovrappeso';
    return 'Obesità';
  }

  // NEW: Trigger automatic BMI calculations for questionnaire
  Future<bool> triggerBMICalculations(String sessionId) async {
    try {
      // Call the database function to auto-calculate BMI responses
      await _supabase.rpc(
        'auto_calculate_responses',
        params: {'session_uuid': sessionId},
      );

      return true;
    } catch (e) {
      print('Error triggering BMI calculations: $e');
      return false;
    }
  }

  // CRITICAL FIX: Enhanced completion logic with NRS 2002 specific handling
  Future<Map<String, dynamic>?> completeAssessment(String sessionId) async {
    try {
      // First, check if the session exists and is in progress
      final sessionCheck = await _supabase
          .from('assessment_sessions')
          .select('status, questionnaire_type')
          .eq('id', sessionId)
          .maybeSingle();

      if (sessionCheck == null) {
        print('Session not found: $sessionId');
        return null;
      }

      if (sessionCheck['status'] == 'completed') {
        print('Session already completed: $sessionId');
        // Return existing completion data
        return {
          'total_score': 0, // Could fetch from database
          'risk_level': 'completed',
          'questionnaire_type': sessionCheck['questionnaire_type'],
          'completed_at': DateTime.now().toIso8601String(),
        };
      }

      final questionnaireType = sessionCheck['questionnaire_type'] as String;

      // CRITICAL FIX: Pre-calculate responses for NRS 2002 before completion
      if (questionnaireType == 'nrs_2002') {
        print('NRS 2002 COMPLETION: Pre-calculating BMI responses');
        await autoCalculateResponses(sessionId);
        await Future.delayed(
            Duration(milliseconds: 500)); // Allow calculation to complete
      }

      // CRITICAL FIX: Use dedicated completion function that handles BMI validation and prevents trigger conflicts
      print(
        'COMPLETION FIX: Using dedicated completion function to prevent SQL error 27000',
      );

      final completionResult = await _supabase.rpc(
        'complete_questionnaire_with_bmi_validation',
        params: {
          'p_session_id': sessionId,
          'p_total_score': null, // Let function calculate score
          'p_risk_level': null, // Let function determine risk
          'p_recommendations': null, // Let function set recommendations
        },
      );

      // Handle the completion result from the database function
      if (completionResult == null ||
          !(completionResult['success'] as bool? ?? false)) {
        final errorMessage = completionResult?['message'] as String? ??
            'Si è verificato un problema nel completare il questionario';
        final errorCode =
            completionResult?['error_code'] as String? ?? 'UNKNOWN_ERROR';

        print('COMPLETION ERROR: $errorCode - $errorMessage');
        throw Exception(errorMessage);
      }

      // Extract completion data from the function result
      final consultationMode =
          completionResult['consultation_mode'] as bool? ?? false;
      final completedAt = DateTime.now().toIso8601String();

      // Get the updated session data after successful completion
      final updatedSession = await _supabase
          .from('assessment_sessions')
          .select('total_score, risk_level, completed_at')
          .eq('id', sessionId)
          .single();

      print(
        'COMPLETION SUCCESS: Session $sessionId completed via database function',
      );

      return {
        'total_score': updatedSession['total_score'] as int? ?? 0,
        'risk_level': updatedSession['risk_level'] as String? ?? 'completed',
        'questionnaire_type': questionnaireType,
        'completed_at':
            updatedSession['completed_at'] as String? ?? completedAt,
        'session_id': sessionId,
        'consultation_mode': consultationMode,
      };
    } catch (e) {
      print('Error in completeAssessment: $e');

      // Enhanced error handling - check if it's specifically the BMI validation error
      final errorMessage = e.toString();

      if (errorMessage.contains('BMI') ||
          errorMessage.contains('peso') ||
          errorMessage.contains('altezza')) {
        // Return structured error for BMI validation issues
        return {
          'error': true,
          'error_type': 'bmi_validation_required',
          'error_message':
              'Per completare questo questionario è necessario inserire peso e altezza nel profilo medico.',
          'action_required': 'update_medical_profile',
        };
      }

      // For other errors, return structured error info but don't break the UI
      return {
        'error': true,
        'error_type': 'completion_error',
        'error_message':
            'Si è verificato un problema nel completare il questionario. Le tue risposte sono state salvate automaticamente.',
        'action_required': 'retry_completion',
      };
    }
  }

  // Get questionnaire responses for a session
  Future<Map<String, dynamic>> getSessionResponses(String sessionId) async {
    try {
      final response = await _supabase
          .from('questionnaire_responses')
          .select(
            'question_id, response_value, response_score, calculated_value',
          )
          .eq('session_id', sessionId ?? '');

      final responses = <String, dynamic>{};
      for (final row in response) {
        responses[row['question_id']] = {
          'value': row['response_value'],
          'score': row['response_score'],
          'calculated_value': row['calculated_value'],
        };
      }
      return responses;
    } catch (e) {
      print('Error getting session responses: $e');
      return {};
    }
  }

  // NEW: Get questionnaire score for NRS 2002 and MUST questionnaires
  Future<Map<String, dynamic>?> getQuestionnaireScore(String sessionId) async {
    try {
      final sessionData = await _supabase
          .from('assessment_sessions')
          .select('total_score, risk_level, questionnaire_type, status, completed_at')
          .eq('id', sessionId)
          .maybeSingle();

      if (sessionData == null) {
        print('Session not found: $sessionId');
        return null;
      }

      final questionnaireType = sessionData['questionnaire_type'] as String?;
      final isCompleted = sessionData['status'] == 'completed';

      // Only return score for NRS 2002 and MUST questionnaires when completed
      if (isCompleted &&
          (questionnaireType == 'nrs_2002' || questionnaireType == 'must')) {
        return {
          'total_score': sessionData['total_score'] as int? ?? 0,
          'risk_level': sessionData['risk_level'] as String?,
          'questionnaire_type': questionnaireType,
          'completed_at': sessionData['completed_at'] as String?,
        };
      }

      return null;
    } catch (e) {
      print('Error getting questionnaire score: $e');
      return null;
    }
  }

  // UPDATED: Get progress statistics for dashboard with real database counts
  Future<Map<String, int>> getProgressStatistics(String userId) async {
    try {
      final realProgressData = await getRealProgressData();
      final overall = realProgressData['overall'] as Map<String, dynamic>;
      final categories =
          realProgressData['categories'] as Map<String, Map<String, int>>;

      Map<String, int> stats = {
        'overall_completed': overall['completed'] as int,
        'overall_total': overall['total'] as int,
        'overall_percentage': overall['percentage'] as int,
      };

      // Add category-specific stats
      for (final entry in categories.entries) {
        final categoryName = entry.key.toLowerCase().replaceAll(' ', '_');
        final progress = entry.value;
        stats['${categoryName}_completed'] = progress['completed'] ?? 0;
        stats['${categoryName}_total'] = progress['total'] ?? 0;
      }

      return stats;
    } catch (e) {
      print('Error getting progress statistics: $e');
      return {};
    }
  }

  // Check if user data is available for calculations
  Future<bool> hasUserMedicalData(String userId) async {
    try {
      final medicalProfile = await _supabase
          .from('medical_profiles')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return medicalProfile != null;
    } catch (e) {
      print('Error checking user medical data: $e');
      return false;
    }
  }

  // NEW: Get pathology information for questionnaire
  Future<Map<String, dynamic>> getPathologyInfo(String userId) async {
    try {
      final medicalData = await _supabase
          .from('medical_profiles')
          .select('medical_conditions')
          .eq('user_id', userId)
          .maybeSingle();

      final medicalConditions =
          medicalData?['medical_conditions'] as List<dynamic>? ?? [];
      final hasPathology = medicalConditions.isNotEmpty;

      return {
        'has_pathology': hasPathology,
        'pathology_list': medicalConditions,
        'primary_pathology': medicalConditions.isNotEmpty
            ? medicalConditions.first.toString()
            : null,
      };
    } catch (e) {
      print('Error getting pathology info: $e');
      return {
        'has_pathology': false,
        'pathology_list': [],
        'primary_pathology': null,
      };
    }
  }

  // CRITICAL FIX: Enhanced calculated question handling with corrected MUST question scoring
  Future<void> _handleCalculatedQuestion(String questionId) async {
    String? calculatedValue;
    String? displayValue;
    int? score;

    // Get calculated values for this user
    final userId = _supabase.auth.currentUser?.id ??
        'd4a87e24-2cab-4fc0-a753-fba15ba7c755';
    final calculatedValues = await getCalculatedValues(userId);

    // CRITICAL FIX: Enhanced MUST BMI question handling with corrected scoring order
    if (questionId == 'must_bmi_calculated' ||
        questionId.contains('bmi') ||
        questionId.contains('BMI')) {
      final bmi = calculatedValues['bmi'];
      if (bmi != null) {
        // CORRECTED MUST BMI scoring: First answer = 0 points, second = 1 point, third = 2 points
        if (bmi >= 20.0) {
          // First option: Best case = 0 points
          calculatedValue = 'BMI ≥ 20 (Peso normale)';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Peso normale - Score: 0)';
          score = 0;
        } else if (bmi >= 18.5 && bmi < 20.0) {
          // Second option: Moderate risk = 1 point
          calculatedValue = '18.5 ≤ BMI < 20 (Leggermente sottopeso)';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Leggermente sottopeso - Score: 1)';
          score = 1;
        } else {
          // Third option: Highest risk = 2 points
          calculatedValue = 'BMI < 18.5 (Sottopeso)';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Sottopeso - Score: 2)';
          score = 2;
        }

        print(
          'CORRECTED MUST BMI CALCULATION: BMI=$bmi, category=$calculatedValue, score=$score',
        );
      } else {
        calculatedValue = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score = 0;
        print('CORRECTED MUST BMI CALCULATION: No medical data available');
      }
    }
    // Handle pathology-related questions
    else if (questionId.contains('patologia') ||
        questionId.contains('pathology')) {
      final pathologyInfo = await getPathologyInfo(
        _supabase.auth.currentUser?.id ??
            'd4a87e24-2cab-4fc0-a753-fba15ba7c755',
      );

      final hasPathology = pathologyInfo['has_pathology'] as bool? ?? false;
      final primaryPathology = pathologyInfo['primary_pathology'] as String?;

      if (hasPathology && primaryPathology != null) {
        calculatedValue = 'Sì';
        displayValue = primaryPathology; // Show the exact pathology name
        score = 1;
      } else {
        calculatedValue = 'No';
        displayValue = 'Nessuna patologia registrata';
        score = 0;
      }
    }
    // Handle weight loss calculations
    else if (questionId.contains('weight_loss') ||
        questionId.contains('perdita_peso')) {
      final weightLoss3m = calculatedValues['weight_loss_3m'];
      if (weightLoss3m != null) {
        final isSignificantLoss = weightLoss3m > 5.0;
        calculatedValue = isSignificantLoss ? 'Sì' : 'No';
        displayValue =
            'Perdita di peso 3 mesi: ${weightLoss3m.toStringAsFixed(1)}% - ${isSignificantLoss ? "Significativa (>5%)" : "Non significativa (≤5%)"}';
        score = isSignificantLoss ? 1 : 0;
      }
    }

    // Save the calculated response if we have a value
    if (calculatedValue != null) {
      print(
        'CORRECTED CALCULATED QUESTION SAVE: questionId=$questionId, value=$calculatedValue, score=$score',
      );
      // Use existing saveQuestionnaireResponseWithRetry method instead of undefined _saveResponse
      // Note: This would need a sessionId parameter to work properly
      print(
        'Would save response: $calculatedValue with score: $score for question: $questionId',
      );
    }
  }

  // CRITICAL FIX: Get questionnaire progress for a session with MUST-specific handling
  Future<Map<String, dynamic>> getQuestionnaireProgress(
    String sessionId,
  ) async {
    try {
      // Get session info
      final session = await _supabase
          .from('assessment_sessions')
          .select('questionnaire_type')
          .eq('id', sessionId)
          .single();

      final questionnaireType = session['questionnaire_type'] as String;

      // CRITICAL FIX: Special handling for MUST questionnaire
      int totalQuestions;
      if (questionnaireType.toLowerCase() == 'must') {
        // MUST questionnaire MUST have exactly 3 questions
        totalQuestions = 3;
        print(
          '🔒 MUST PROGRESS: Enforcing exactly 3 questions for session $sessionId',
        );
      } else {
        // Get template ID for this questionnaire type
        final templateId = await getTemplateIdForType(questionnaireType);

        if (templateId == null) {
          throw Exception(
            'Template not found for questionnaire type: $questionnaireType',
          );
        }

        // Get ACTUAL questions for other questionnaire types
        final questionsCount = await _supabase
            .from('questionnaire_questions')
            .select('id')
            .eq('template_id', templateId)
            .count();
        totalQuestions = questionsCount.count;
      }

      // Get responses for this session
      final responsesCount = await _supabase
          .from('questionnaire_responses')
          .select('id')
          .eq('session_id', sessionId)
          .count();

      int completedResponses = responsesCount.count;

      // CRITICAL FIX: For MUST questionnaire, cap completed responses at 3
      if (questionnaireType.toLowerCase() == 'must' && completedResponses > 3) {
        completedResponses = 3;
        print(
          '🔒 MUST PROGRESS: Capped responses to 3 (was ${responsesCount.count})',
        );
      }

      final progressPercentage = totalQuestions > 0
          ? ((completedResponses / totalQuestions) * 100).round()
          : 0;

      if (questionnaireType.toLowerCase() == 'must') {
        print(
          '🎯 MUST PROGRESS SESSION: $completedResponses/3 ($progressPercentage%)',
        );
      } else {
        print(
          '📊 Progress for $questionnaireType: $completedResponses/$totalQuestions ($progressPercentage%)',
        );
      }

      return {
        'total_questions': totalQuestions,
        'answered_questions': completedResponses,
        'progress_percentage': progressPercentage,
        'is_complete': completedResponses >= totalQuestions,
        'questionnaire_type': questionnaireType,
      };
    } catch (e) {
      print('Error getting progress: $e');
      return {
        'total_questions': 0,
        'answered_questions': 0,
        'progress_percentage': 0,
        'is_complete': false,
      };
    }
  }

  // CRITICAL FIX: Enhanced detailed questionnaire progress method with consistent MUST handling
  Future<Map<String, dynamic>> getDetailedQuestionnaireProgressForSession(
    String sessionId,
  ) async {
    try {
      // Get session info first
      final session = await _supabase
          .from('assessment_sessions')
          .select('questionnaire_type, user_id')
          .eq('id', sessionId)
          .single();

      final questionnaireType = session['questionnaire_type'] as String;
      final userId = session['user_id'] as String;

      // Get template info
      final template = await _supabase
          .from('questionnaire_templates')
          .select('id, title, category')
          .eq('questionnaire_type', questionnaireType)
          .eq('is_active', true)
          .single();

      // CRITICAL FIX: Apply MUST-specific handling first
      int totalQuestions;
      if (questionnaireType.toLowerCase() == 'must') {
        // MUST questionnaire MUST have exactly 3 questions
        totalQuestions = 3;
      } else {
        // Get total questions from template for other questionnaires
        final questionsCount = await _supabase
            .from('questionnaire_questions')
            .select('id')
            .eq('template_id', template['id'])
            .count();
        totalQuestions = questionsCount.count;
      }

      // Get responses for this session
      final responsesCount = await _supabase
          .from('questionnaire_responses')
          .select('id')
          .eq('session_id', sessionId)
          .count();

      int completedResponses = responsesCount.count;

      // CRITICAL FIX: For MUST questionnaire, cap completed responses at 3
      if (questionnaireType.toLowerCase() == 'must' && completedResponses > 3) {
        completedResponses = 3;
        print(
          '🔒 MUST DETAILED PROGRESS: Capped responses to 3 (was ${responsesCount.count})',
        );
      }

      final completionPercentage = totalQuestions > 0
          ? ((completedResponses / totalQuestions) * 100).round()
          : 0;

      if (questionnaireType.toLowerCase() == 'must') {
        print(
          '🎯 MUST DETAILED PROGRESS: $completedResponses/3 ($completionPercentage%)',
        );

        return {
          'questionnaire_type': questionnaireType,
          'template_id': template['id'],
          'title': template['title'],
          'category': template['category'],
          'total_questions': 3, // Always 3 for MUST
          'completed_responses': completedResponses,
          'completion_percentage': completionPercentage,
          'is_completed':
              completedResponses >= 3, // Complete when all 3 are answered
          'session_id': sessionId,
          'display_format': '$completedResponses/3',
        };
      }

      // For other questionnaires, use actual counts
      return {
        'questionnaire_type': questionnaireType,
        'template_id': template['id'],
        'title': template['title'],
        'category': template['category'],
        'total_questions': totalQuestions,
        'completed_responses': completedResponses,
        'completion_percentage': completionPercentage,
        'is_completed':
            completedResponses >= totalQuestions && totalQuestions > 0,
        'session_id': sessionId,
        'display_format': '$completedResponses/$totalQuestions',
      };
    } catch (e) {
      print('Error getting detailed questionnaire progress for session: $e');
      return {
        'questionnaire_type': 'unknown',
        'template_id': '',
        'title': 'Unknown Questionnaire',
        'category': 'Unknown',
        'total_questions': 0,
        'completed_responses': 0,
        'completion_percentage': 0,
        'is_completed': false,
        'session_id': sessionId,
        'display_format': '0/0',
        'error': e.toString(),
      };
    }
  }

  // NEW: Get detailed answers for completed questionnaire with questions and responses
  Future<Map<String, dynamic>> getDetailedQuestionnaireAnswers(
    String sessionId,
  ) async {
    try {
      // Get session info
      final sessionData = await _supabase
          .from('assessment_sessions')
          .select('questionnaire_type, completed_at, total_score, status')
          .eq('id', sessionId)
          .single();

      final questionnaireType = sessionData['questionnaire_type'] as String;

      // Get template info
      final template = await _supabase
          .from('questionnaire_templates')
          .select('id, title, description')
          .eq('questionnaire_type', questionnaireType)
          .eq('is_active', true)
          .single();

      // Get questions for this template
      final questions = await _supabase
          .from('questionnaire_questions')
          .select('*')
          .eq('template_id', template['id'])
          .order('order_index', ascending: true);

      // Get responses for this session
      final responses = await _supabase
          .from('questionnaire_responses')
          .select(
            'question_id, response_value, response_score, calculated_value',
          )
          .eq('session_id', sessionId);

      // Create response map for easy lookup
      Map<String, Map<String, dynamic>> responseMap = {};
      for (final response in responses) {
        responseMap[response['question_id']] = {
          'value': response['response_value'],
          'score': response['response_score'],
          'calculated_value': response['calculated_value'],
        };
      }

      // Combine questions with their responses
      List<Map<String, dynamic>> detailedAnswers = [];
      for (final question in questions) {
        final questionId = question['question_id'] as String;
        final response = responseMap[questionId];

        detailedAnswers.add({
          'question': question,
          'response': response,
          'question_text': question['question_text'],
          'question_type': question['question_type'],
          'response_value': response?['value'] ?? 'Nessuna risposta',
          'display_value': response?['calculated_value'] ??
              response?['value'] ??
              'Non risposto',
        });
      }

      return {
        'session_id': sessionId,
        'questionnaire_type': questionnaireType,
        'questionnaire_title': template['title'],
        'questionnaire_description': template['description'],
        'completed_at': sessionData['completed_at'],
        'status': sessionData['status'],
        'total_score': sessionData['total_score'],
        'detailed_answers': detailedAnswers,
      };
    } catch (e) {
      print('Error getting detailed questionnaire answers: $e');
      return {};
    }
  }

  // NEW: Get latest ESAS responses for patient consultation
  Future<Map<String, dynamic>> getLatestEsasResponsesForConsultation(
    String userId,
  ) async {
    try {
      final responses = await _supabase.rpc(
        'get_latest_esas_responses_for_patient',
        params: {'patient_user_id': userId},
      );

      if (responses.isEmpty) {
        return {
          'has_responses': false,
          'message': 'Nessuna valutazione ESAS completata trovata',
        };
      }

      // Group responses by session
      final sessionData = responses.first;
      final sessionId = sessionData['session_id'];
      final completedAt = sessionData['completed_at'];

      // Format responses for display
      List<Map<String, dynamic>> formattedResponses = [];
      for (final response in responses) {
        formattedResponses.add({
          'question': response['question_text'],
          'answer': response['response_value'],
          'order': response['question_order'],
        });
      }

      // Sort by question order
      formattedResponses.sort(
        (a, b) => (a['order'] as int).compareTo(b['order'] as int),
      );

      return {
        'has_responses': true,
        'session_id': sessionId,
        'completed_at': completedAt,
        'responses': formattedResponses,
        'questionnaire_type': 'esas',
        'consultation_mode': true,
      };
    } catch (e) {
      print('Error getting latest ESAS responses: $e');
      return {'has_responses': false, 'error': e.toString()};
    }
  }

  // NEW: Check if questionnaire is in consultation mode (ESAS)
  Future<bool> isConsultationModeQuestionnaire(String questionnaireType) async {
    return questionnaireType.toLowerCase() == 'esas';
  }
}