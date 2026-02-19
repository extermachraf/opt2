import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class QuizService {
  static final SupabaseClient _supabase = SupabaseService.instance.client;

  // Get quiz templates by category
  static Future<List<Map<String, dynamic>>> getQuizTemplatesByCategory(
    String category,
  ) async {
    try {
      final response = await _supabase
          .from('quiz_templates')
          .select('*')
          .eq('category', category)
          .eq('is_active', true)
          .order('created_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz templates: $e');
      return [];
    }
  }

  // Get quiz templates by topic - NEW METHOD FOR TOPIC-BASED QUERIES
  static Future<List<Map<String, dynamic>>> getQuizTemplatesByTopic(
    String topic,
  ) async {
    try {
      final response = await _supabase
          .from('quiz_templates')
          .select('*')
          .eq('category', 'topic_based')
          .eq('topic', topic)
          .eq('is_active', true)
          .order('created_at');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz templates by topic: $e');
      return [];
    }
  }

  // Enhanced method that can handle both category and topic queries
  static Future<List<Map<String, dynamic>>> getQuizTemplatesByCategoryOrTopic(
    String identifier,
  ) async {
    try {
      // Check if the identifier is a valid quiz_category enum value
      const validCategories = ['false_myths', 'topic_based'];
      const validTopics = [
        'alimenti_nutrienti_supplementi',
        'nutrizione_terapie_oncologiche',
        'cosa_fare_prima_terapia',
        'mangiare_sano_salute',
      ];

      List<Map<String, dynamic>> response = [];

      if (validCategories.contains(identifier)) {
        // Query by category
        response = await _supabase
            .from('quiz_templates')
            .select('*')
            .eq('category', identifier)
            .eq('is_active', true)
            .order('created_at');
      } else if (validTopics.contains(identifier)) {
        // Query by topic (set category to 'topic_based')
        response = await _supabase
            .from('quiz_templates')
            .select('*')
            .eq('category', 'topic_based')
            .eq('topic', identifier)
            .eq('is_active', true)
            .order('created_at');
      }

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz templates by category or topic: $e');
      return [];
    }
  }

  // Get all quiz templates
  static Future<List<Map<String, dynamic>>> getAllQuizTemplates() async {
    try {
      final response = await _supabase
          .from('quiz_templates')
          .select('*')
          .eq('is_active', true)
          .order('title');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all quiz templates: $e');
      return [];
    }
  }

  // Get questions for a specific template
  static Future<List<Map<String, dynamic>>> getQuizQuestions(
    String templateId,
  ) async {
    try {
      final response = await _supabase
          .from('quiz_questions')
          .select('*')
          .eq('template_id', templateId)
          .order('order_index');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching quiz questions: $e');
      return [];
    }
  }

  // Get questions by category (for backward compatibility)
  static Future<List<Map<String, dynamic>>> getQuestionsByCategory(
    String category,
  ) async {
    try {
      final templateResponse =
          await _supabase
              .from('quiz_templates')
              .select('id')
              .eq('category', category)
              .eq('is_active', true)
              .single();

      final templateId = templateResponse['id'];

      final response = await _supabase
          .from('quiz_questions')
          .select('*')
          .eq('template_id', templateId)
          .order('order_index');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching questions by category: $e');
      return [];
    }
  }

  // Save user quiz attempt
  static Future<bool> saveQuizAttempt({
    required String userId,
    required String templateId,
    required int score,
    required int totalQuestions,
    required Map<String, dynamic> answers,
  }) async {
    try {
      final percentage =
          totalQuestions > 0 ? ((score / totalQuestions) * 100).round() : 0;

      await _supabase.from('quiz_attempts').insert({
        'user_id': userId,
        'template_id': templateId,
        'score': score,
        'total_questions': totalQuestions,
        'percentage': percentage,
        'answers': answers,
        'completed_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error saving quiz attempt: $e');
      return false;
    }
  }

  // Get user quiz history
  static Future<List<Map<String, dynamic>>> getUserQuizHistory(
    String userId,
  ) async {
    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select('''
            *,
            quiz_templates!inner(
              title,
              category,
              topic
            )
          ''')
          .eq('user_id', userId)
          .order('completed_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user quiz history: $e');
      return [];
    }
  }

  // Get user's best score for a template
  static Future<Map<String, dynamic>?> getUserBestScore(
    String userId,
    String templateId,
  ) async {
    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select('*')
          .eq('user_id', userId)
          .eq('template_id', templateId)
          .order('percentage', ascending: false)
          .limit(1);

      if (response.isNotEmpty) {
        return response.first;
      }
      return null;
    } catch (e) {
      print('Error fetching user best score: $e');
      return null;
    }
  }

  // Get quiz statistics for a user
  static Future<Map<String, dynamic>> getUserQuizStats(String userId) async {
    try {
      final response = await _supabase
          .from('quiz_attempts')
          .select('score, total_questions, percentage, template_id')
          .eq('user_id', userId);

      final attempts = List<Map<String, dynamic>>.from(response);

      if (attempts.isEmpty) {
        return {
          'total_attempts': 0,
          'average_percentage': 0,
          'best_percentage': 0,
          'completed_templates': 0,
        };
      }

      final totalAttempts = attempts.length;
      final averagePercentage =
          attempts.map((a) => a['percentage'] as int).reduce((a, b) => a + b) ~/
          totalAttempts;
      final bestPercentage = attempts
          .map((a) => a['percentage'] as int)
          .reduce((a, b) => a > b ? a : b);
      final completedTemplates =
          attempts.map((a) => a['template_id']).toSet().length;

      return {
        'total_attempts': totalAttempts,
        'average_percentage': averagePercentage,
        'best_percentage': bestPercentage,
        'completed_templates': completedTemplates,
      };
    } catch (e) {
      print('Error fetching user quiz stats: $e');
      return {
        'total_attempts': 0,
        'average_percentage': 0,
        'best_percentage': 0,
        'completed_templates': 0,
      };
    }
  }
}
