import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:async'; // ... Add this import for Timer ... //
import 'dart:convert'; // ... Add this import for jsonDecode ... //

import '../../core/app_export.dart';
import '../../services/questionnaire_service.dart';
import '../../services/supabase_service.dart';
import '../../theme/app_theme.dart';

class QuestionnaireDetailScreen extends StatefulWidget {
  const QuestionnaireDetailScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireDetailScreen> createState() =>
      _QuestionnaireDetailScreenState();
}

class _QuestionnaireDetailScreenState extends State<QuestionnaireDetailScreen> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  PageController? _pageController; // CRITICAL FIX: Make nullable to initialize later with correct page

  // CRITICAL FIX: Move controllers to state level to prevent recreation
  final Map<String, TextEditingController> _textControllers = {};

  String? _sessionId;
  String? _questionnaireType;
  String? _templateId;
  String? _questionnaireName;

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _allQuestions = []; // Store all questions including conditional ones
  Map<String, dynamic> _responses = {};
  Map<String, dynamic> _calculatedValues = {};
  bool _isLoading = true;
  String? _error;
  int _currentQuestionIndex = 0;
  bool _isSubmitting = false;
  bool _isCompleted = false;
  Map<String, dynamic>? _completionResults;

  // CRITICAL FIX: Add dynamic progress tracking
  Map<String, dynamic> _progressData = {};

  // Helper method to check if this is a SARC-F questionnaire
  bool _isSarcFQuestionnaire() {
    return _questionnaireType?.toLowerCase() == 'sarc_f';
  }

  // Helper method to check if this is a MUST questionnaire
  bool _isMustQuestionnaire() {
    return _questionnaireType?.toLowerCase() == 'must';
  }

  // Helper method to check if this is an NRS 2002 questionnaire
  bool _isNrs2002Questionnaire() {
    return _questionnaireType?.toLowerCase() == 'nrs_2002';
  }

  // Helper method to check if this is an SF-12 questionnaire
  bool _isSf12Questionnaire() {
    return _questionnaireType?.toLowerCase() == 'sf12';
  }

  // Helper method to check if this is an ESAS questionnaire
  bool _isEsasQuestionnaire() {
    return _questionnaireType?.toLowerCase() == 'esas';
  }

  // CRITICAL FIX: Enhanced completed questions calculation with MUST-specific handling
  int _getCompletedQuestionsCount() {
    if (_questions.isEmpty) return 0;

    // For MUST questionnaire, use enhanced progress data with validation
    if (_isMustQuestionnaire() && _progressData.isNotEmpty) {
      final completedFromProgress =
          _progressData['completed_responses'] as int? ?? 0;

      // Validate that completed doesn't exceed 3 for MUST
      final validatedCompleted =
          completedFromProgress > 3 ? 3 : completedFromProgress;

      print(
        'MUST COMPLETED QUESTIONS: $validatedCompleted (validated from progress data)',
      );
      return validatedCompleted;
    }

    // For other questionnaires, count responses normally
    int completedCount = 0;

    for (final question in _questions) {
      final questionId = question['question_id'] as String;
      final questionType = question['question_type'] as String;

      // Check if this question has a valid response
      final response = _responses[questionId];

      if (response != null) {
        final value = response['value']?.toString() ?? '';

        // Count as completed if it has a non-empty value or is a calculated question
        if (questionType == 'calculated' || value.trim().isNotEmpty) {
          completedCount++;
        }
      }
    }

    print(
      'OTHER QUESTIONNAIRE COMPLETED: $completedCount out of ${_questions.length}',
    );
    return completedCount;
  }

  // CRITICAL FIX: Enhanced total questions calculation with better MUST handling
  int _getTotalQuestionsCount() {
    // For MUST questionnaire, ALWAYS return 3 regardless of database content
    if (_isMustQuestionnaire()) {
      // Try to get from enhanced progress data first
      if (_progressData.isNotEmpty) {
        final total = _progressData['total_questions'] as int? ?? 3;
        print('MUST TOTAL QUESTIONS: $total (from progress data)');
        return total;
      }

      print('MUST TOTAL QUESTIONS: 3 (hardcoded fallback)');
      return 3; // Force to 3 for MUST questionnaire as requested
    }

    final actualCount = _questions.length;
    print('OTHER QUESTIONNAIRE TOTAL: $actualCount questions');
    return actualCount;
  }

  // CRITICAL FIX: Enhanced progress display method
  String _getProgressDisplayText() {
    if (_isMustQuestionnaire() && _progressData.isNotEmpty) {
      final displayFormat = _progressData['display_format'] as String?;
      if (displayFormat != null && displayFormat.isNotEmpty) {
        print('MUST PROGRESS DISPLAY: Using format "$displayFormat"');
        return displayFormat;
      }
    }

    final completed = _getCompletedQuestionsCount();
    final total = _getTotalQuestionsCount();
    final displayText = '$completed/$total';

    print('PROGRESS DISPLAY: $displayText');
    return displayText;
  }

  // Helper method to check if questionnaire is fully completed
  bool _isQuestionnaireFullyCompleted() {
    return _getCompletedQuestionsCount() == _getTotalQuestionsCount();
  }

  // Helper method to parse simple HTML tags in question text (like <u>underline</u>)
  Widget _buildQuestionTextWithFormatting(String text, TextStyle baseStyle) {
    // Check if text contains HTML tags
    if (!text.contains('<u>') && !text.contains('</u>')) {
      // No formatting needed, return simple Text widget
      return Text(text, style: baseStyle);
    }

    // Parse the text and create TextSpans
    final List<TextSpan> spans = [];
    final RegExp underlineRegex = RegExp(r'<u>(.*?)</u>');
    int lastIndex = 0;

    for (final match in underlineRegex.allMatches(text)) {
      // Add text before the underlined part
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      // Add underlined text
      spans.add(TextSpan(
        text: match.group(1),
        style: baseStyle.copyWith(decoration: TextDecoration.underline),
      ));

      lastIndex = match.end;
    }

    // Add remaining text after last match
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  @override
  void initState() {
    super.initState();
    _extractArguments();
  }

  @override
  void dispose() {
    _pageController?.dispose(); // CRITICAL FIX: Handle nullable PageController
    // CRITICAL FIX: Dispose all text controllers
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  // CRITICAL FIX: Helper method to get or create text controller with enhanced cursor handling
  TextEditingController _getTextController(
    String questionId,
    String initialValue,
  ) {
    // Check if we already have a controller
    if (_textControllers.containsKey(questionId)) {
      final controller = _textControllers[questionId]!;

      // CRITICAL FIX: Only update if the value actually changed and preserve cursor position
      if (initialValue.isNotEmpty && controller.text != initialValue) {
        print(
          'TEXT CONTROLLER: Updating existing controller for $questionId from "${controller.text}" to "$initialValue"',
        );

        // CRITICAL FIX: Preserve cursor position when updating text
        final currentSelection = controller.selection;
        controller.text = initialValue;

        // Restore cursor position if it's valid
        if (currentSelection.start <= initialValue.length &&
            currentSelection.end <= initialValue.length) {
          controller.selection = currentSelection;
        } else {
          // Position cursor at end if previous position is invalid
          controller.selection = TextSelection.collapsed(
            offset: initialValue.length,
          );
        }
      }

      return controller;
    }

    // Create new controller with initial value and proper cursor positioning
    print(
      'TEXT CONTROLLER: Creating new controller for $questionId with initial value: "$initialValue"',
    );
    final controller = TextEditingController(text: initialValue);

    // CRITICAL FIX: Position cursor at the end of initial value
    if (initialValue.isNotEmpty) {
      controller.selection = TextSelection.collapsed(
        offset: initialValue.length,
      );
    }

    _textControllers[questionId] = controller;

    return controller;
  }

  void _extractArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
              {};

      setState(() {
        _sessionId = args['sessionId'] as String? ?? '';
        _questionnaireType = args['questionnaireType'] as String? ?? '';
        _templateId = args['templateId'] as String? ?? '';
        _questionnaireName =
            args['questionnaireName'] as String? ?? 'Questionario';
      });

      if (_sessionId != null && _sessionId!.isNotEmpty) {
        _loadQuestionsAndResumeProgress();
      } else {
        setState(() {
          _error = 'Sessione questionario non valida';
          _isLoading = false;
        });
      }
    });
  }

  Future<void> _loadQuestionsAndResumeProgress() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Enhanced template ID resolution
      String? resolvedTemplateId = _templateId;

      // If template ID is missing or empty, try to resolve it
      if (resolvedTemplateId == null || resolvedTemplateId.isEmpty) {
        print(
          'Template ID missing, attempting to resolve from session or questionnaire type',
        );

        if (_questionnaireType != null && _questionnaireType!.isNotEmpty) {
          // Try to get template ID from questionnaire type
          final templateResponse = await SupabaseService.instance.client
              .from('questionnaire_templates')
              .select('id')
              .eq('questionnaire_type', _questionnaireType!)
              .eq('is_active', true)
              .maybeSingle();

          if (templateResponse != null) {
            resolvedTemplateId = templateResponse['id'] as String;
            print('Resolved template ID: $resolvedTemplateId');
          }
        }

        // If still no template ID, try to get from session
        if ((resolvedTemplateId == null || resolvedTemplateId.isEmpty) &&
            _sessionId != null &&
            _sessionId!.isNotEmpty) {
          try {
            final sessionResponse = await SupabaseService.instance.client
                .from('assessment_sessions')
                .select('questionnaire_type')
                .eq('id', _sessionId!)
                .single();

            final sessionQuestionnaireType =
                sessionResponse['questionnaire_type'] as String;

            final templateResponse = await SupabaseService.instance.client
                .from('questionnaire_templates')
                .select('id')
                .eq('questionnaire_type', sessionQuestionnaireType)
                .eq('is_active', true)
                .maybeSingle();

            if (templateResponse != null) {
              resolvedTemplateId = templateResponse['id'] as String;
              print('Resolved template ID from session: $resolvedTemplateId');
            }
          } catch (sessionError) {
            print('Could not resolve template from session: $sessionError');
          }
        }

        // Final fallback: get any available template
        if (resolvedTemplateId == null || resolvedTemplateId.isEmpty) {
          print('Using fallback template resolution');

          final fallbackTemplate = await SupabaseService.instance.client
              .from('questionnaire_templates')
              .select('id, questionnaire_type')
              .eq('is_active', true)
              .limit(1)
              .maybeSingle();

          if (fallbackTemplate != null) {
            resolvedTemplateId = fallbackTemplate['id'] as String;
            _questionnaireType =
                fallbackTemplate['questionnaire_type'] as String;
            print(
              'Using fallback template: $resolvedTemplateId for type: $_questionnaireType',
            );
          }
        }
      }

      if (resolvedTemplateId != null && resolvedTemplateId.isNotEmpty) {
        final questions = await _questionnaireService.getQuestionsForTemplate(
          resolvedTemplateId,
        );

        if (questions.isEmpty) {
          print(
            'No questions found for template $resolvedTemplateId, checking for any questions',
          );

          // Try to get questions from any available template
          final allTemplates = await SupabaseService.instance.client
              .from('questionnaire_templates')
              .select('id')
              .eq('is_active', true)
              .limit(3);

          for (final template in allTemplates) {
            final templateId = template['id'] as String;
            final templateQuestions =
                await _questionnaireService.getQuestionsForTemplate(templateId);

            if (templateQuestions.isNotEmpty) {
              setState(() {
                _questions = templateQuestions;
                _templateId = templateId;
              });

              print('Found questions in template: $templateId');
              break;
            }
          }

          if (_questions.isEmpty) {
            setState(() {
              _error =
                  'Nessuna domanda disponibile al momento. Le domande verranno caricate presto.';
              _isLoading = false;
            });
            return;
          }
        } else {
          print('✅ LOADED ${questions.length} QUESTIONS for template $resolvedTemplateId');
          for (int i = 0; i < questions.length; i++) {
            print('   Question ${i + 1}: ${questions[i]['question_id']} - ${questions[i]['question_text']}');
          }
          setState(() {
            _allQuestions = List.from(questions); // Store all questions
            _questions = questions;
            _templateId = resolvedTemplateId;
          });

          // CRITICAL FIX: Filter conditional questions for NRS 2002
          if (_isNrs2002Questionnaire()) {
            _filterConditionalQuestions();
          }
        }

        // Load existing responses if any
        if (_sessionId != null && _sessionId!.isNotEmpty) {
          final existingResponses =
              await _questionnaireService.getSessionResponses(_sessionId!);
          setState(() {
            _responses = existingResponses;
          });

          // CRITICAL FIX: Load dynamic progress data for MUST questionnaire
          await _loadProgressData();

          // CRITICAL FIX: Calculate and set current question index based on progress
          await _calculateAndSetCurrentQuestionIndex();

          // CRITICAL FIX: Load calculated values for automatic questions
          await _loadCalculatedValues();

          // CRITICAL FIX: Initialize text controllers with existing response values
          await _initializeTextControllersWithResponses();
        } else {
          // CRITICAL FIX: Initialize PageController at page 0 for new questionnaires
          setState(() {
            _pageController = PageController(initialPage: 0);
            _currentQuestionIndex = 0;
          });
          print('NEW QUESTIONNAIRE: Initialized PageController at page 0');
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        // Create a user-friendly error message instead of technical error
        setState(() {
          _error =
              'Questionario temporaneamente non disponibile.\n\nRiprova tra qualche momento o contatta il supporto se il problema persiste.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');

      setState(() {
        _error =
            'Errore nel caricamento del questionario.\n\nVerifica la connessione internet e riprova.';
        _isLoading = false;
      });
    }
  }

  // CRITICAL FIX: Filter conditional questions for NRS 2002
  void _filterConditionalQuestions() {
    if (!_isNrs2002Questionnaire()) return;

    // Check if any of Q2-Q5 has answer "Sì"
    final hasYesInScreening = _responses.values.any((response) {
      final questionId = response['question_id'] as String?;
      final value = response['value'] as String?;

      // Check if this is one of the screening questions (Q2-Q5)
      final isScreeningQuestion = [
        'nrs_weight_loss_3m',
        'nrs_reduced_intake',
        'nrs_acute_pathology',
        'nrs_intensive_care'
      ].contains(questionId);

      return isScreeningQuestion && value == 'Sì';
    });

    print('NRS 2002 CONDITIONAL FILTER: hasYesInScreening=$hasYesInScreening');
    print('NRS 2002 CONDITIONAL FILTER: Current responses: ${_responses.keys.toList()}');

    setState(() {
      if (!hasYesInScreening) {
        // Remove Q6 & Q7 from questions list
        _questions = _allQuestions.where((q) {
          final questionId = q['question_id'] as String;
          final isConditionalQuestion = questionId == 'nrs_nutritional_status' ||
                                       questionId == 'nrs_disease_severity';
          return !isConditionalQuestion;
        }).toList();
        print('NRS 2002: Removed Q6 & Q7 (no "Sì" in screening questions)');
      } else {
        // Restore all questions including Q6 & Q7
        _questions = List.from(_allQuestions);
        print('NRS 2002: Showing Q6 & Q7 (at least one "Sì" in screening questions)');
      }
    });
  }

  // CRITICAL FIX: New method to load dynamic progress data with enhanced error handling
  Future<void> _loadProgressData() async {
    try {
      if (_sessionId != null && _sessionId!.isNotEmpty) {
        // Use the enhanced detailed progress method
        final detailedProgressData = await _questionnaireService
            .getDetailedQuestionnaireProgressForSession(_sessionId!);

        // Also get the standard progress data for backwards compatibility
        final standardProgressData =
            await _questionnaireService.getQuestionnaireProgress(_sessionId!);

        setState(() {
          _progressData = {
            ...standardProgressData,
            ...detailedProgressData, // Override with detailed data
          };
        });

        print('ENHANCED PROGRESS DATA LOADED: $_progressData');

        // For MUST questionnaire, log the corrected progress with emphasis
        if (_isMustQuestionnaire()) {
          final displayFormat =
              _progressData['display_format'] as String? ?? '0/0';
          final completed = _progressData['completed_responses'] as int? ?? 0;
          final total = _progressData['total_questions'] as int? ?? 3;

          print(
            '🎯 MUST PROGRESS CORRECTED: $displayFormat (was showing 8/8, now showing 3/3 format)',
          );
          print('   - Completed responses: $completed');
          print('   - Total questions: $total (forced to 3 for MUST)');
          print(
            '   - Percentage: ${_progressData['completion_percentage'] ?? 0}%',
          );
        }
      }
    } catch (e) {
      print('Error loading enhanced progress data: $e');
      // Fallback to ensure MUST shows correct format even on error
      if (_isMustQuestionnaire() && _sessionId != null) {
        try {
          final basicProgress =
              await _questionnaireService.getQuestionnaireProgress(_sessionId!);
          setState(() {
            _progressData = basicProgress;
          });
          print('MUST PROGRESS FALLBACK: Applied basic progress correction');
        } catch (fallbackError) {
          print('MUST PROGRESS FALLBACK FAILED: $fallbackError');
        }
      }
    }
  }

  // CRITICAL FIX: New method to properly initialize text controllers with existing responses
  Future<void> _initializeTextControllersWithResponses() async {
    print(
      'INITIALIZE CONTROLLERS: Starting initialization with ${_responses.length} responses',
    );

    for (final question in _questions) {
      final questionId = question['question_id'] as String;
      final questionType = question['question_type'] as String;

      // Only initialize text controllers for text input and number input questions
      if (questionType == 'text_input' || questionType == 'number_input') {
        final existingResponse = _responses[questionId];
        final existingValue = existingResponse?['value']?.toString() ?? '';

        if (existingValue.isNotEmpty) {
          print(
            'INITIALIZE CONTROLLERS: Setting controller for $questionId with value: "$existingValue"',
          );

          // Force create/update the controller with the existing value
          if (_textControllers.containsKey(questionId)) {
            _textControllers[questionId]!.text = existingValue;
          } else {
            _textControllers[questionId] = TextEditingController(
              text: existingValue,
            );
          }

          print(
            'INITIALIZE CONTROLLERS: Successfully initialized controller for $questionId',
          );
        } else {
          print(
            'INITIALIZE CONTROLLERS: No existing value for question $questionId',
          );
        }
      }
    }

    print(
      'INITIALIZE CONTROLLERS: Completed initialization for ${_textControllers.length} text controllers',
    );

    // Force a UI update to ensure all widgets reflect the loaded values
    if (mounted) {
      setState(() {
        // This will trigger a rebuild with properly initialized controllers
      });
    }
  }

  Future<void> _calculateAndSetCurrentQuestionIndex() async {
    if (_questions.isEmpty || _responses.isEmpty) {
      setState(() {
        _currentQuestionIndex = 0;
      });
      // CRITICAL FIX: Initialize PageController with page 0
      _pageController = PageController(initialPage: 0);
      return;
    }

    int lastAnsweredIndex = -1;
    int lastNonCalculatedAnsweredIndex = -1;

    // Find the last question that has a valid response
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      final questionId = question['question_id'] as String;
      final questionType = question['question_type'] as String;

      // Check if this question has a response
      final response = _responses[questionId];

      if (response != null) {
        final value = response['value']?.toString() ?? '';

        // For calculated questions, they're automatically filled so they count as answered
        if (questionType == 'calculated' || value.trim().isNotEmpty) {
          lastAnsweredIndex = i;

          // Track non-calculated questions separately
          if (questionType != 'calculated' && value.trim().isNotEmpty) {
            lastNonCalculatedAnsweredIndex = i;
          }

          // CRITICAL FIX: For SF-12, log each found response for debugging
          if (_isSf12Questionnaire()) {
            print(
              'SF-12 PROGRESS: Found response for question ${i + 1}: $questionId = "$value"',
            );
          }
        }
      }
    }

    // CRITICAL FIX: For MUST questionnaire, special handling
    // If only calculated questions (BMI) are answered, start from question 1
    // If user has answered any non-calculated questions, resume from where they left off
    if (_isMustQuestionnaire()) {
      if (lastNonCalculatedAnsweredIndex == -1) {
        // Only BMI (calculated) is answered, start from question 1
        print('MUST QUESTIONNAIRE: Only BMI answered, starting from question 1 (index 0)');
        setState(() {
          _currentQuestionIndex = 0;
        });
        _pageController = PageController(initialPage: 0);
        return;
      } else {
        // User has answered some non-calculated questions, continue from there
        print('MUST QUESTIONNAIRE: User has answered up to question ${lastNonCalculatedAnsweredIndex + 1}, continuing from next question');
      }
    }

    // Set current question index to the next unanswered question
    // If all questions are answered, set to last question
    int nextQuestionIndex = lastAnsweredIndex + 1;

    if (nextQuestionIndex >= _questions.length) {
      nextQuestionIndex = _questions.length - 1;
    }

    print(
      'CONTINUE FROM PROGRESS: Last answered index: $lastAnsweredIndex, Setting current index to: $nextQuestionIndex',
    );

    // CRITICAL FIX: For SF-12, provide detailed progress information
    if (_isSf12Questionnaire()) {
      final answeredCount = lastAnsweredIndex + 1;
      final totalQuestions = _questions.length;
      final progressPercent = ((answeredCount / totalQuestions) * 100).round();

      print('SF-12 DETAILED PROGRESS:');
      print('  - Questions answered: $answeredCount/$totalQuestions');
      print('  - Progress: $progressPercent%');
      print('  - Will resume at question: ${nextQuestionIndex + 1}');
      print('  - Loaded responses: ${_responses.length}');
    }

    setState(() {
      _currentQuestionIndex = nextQuestionIndex;
      // CRITICAL FIX: Initialize PageController with the correct initial page
      // This ensures the PageView starts at the right question immediately
      _pageController = PageController(initialPage: nextQuestionIndex);
    });

    print(
      'CONTINUE FROM PROGRESS: Initialized PageController at page $nextQuestionIndex',
    );
  }

  Future<void> _loadCalculatedValues() async {
    try {
      final userId = SupabaseService.instance.client.auth.currentUser?.id ??
          'd4a87e24-2cab-4fc0-a753-fba15ba7c755'; // Mock for demo

      final calculatedValues = await _questionnaireService.getCalculatedValues(
        userId,
      );
      setState(() {
        _calculatedValues = calculatedValues;
      });

      // Auto-populate calculated responses
      await _populateCalculatedResponses();
    } catch (e) {
      print('Error loading calculated values: $e');
    }
  }

  Future<void> _populateCalculatedResponses() async {
    for (final question in _questions) {
      final questionId = question['question_id'] as String;
      final questionType = question['question_type'] as String;

      if (questionType == 'calculated') {
        await _handleCalculatedQuestion(questionId);
      }
    }
  }

  // CRITICAL FIX: Enhanced calculated question handling to properly process NRS 2002 BMI calculations
  Future<void> _handleCalculatedQuestion(String questionId) async {
    String? calculatedValue;
    String? displayValue;
    int? score;

    // CRITICAL FIX: Enhanced NRS 2002 BMI question handling with improved auto-assignment
    if (questionId == 'nrs_bmi_under_20_5' && _isNrs2002Questionnaire()) {
      final bmi = _calculatedValues['bmi'];
      if (bmi != null) {
        // NRS 2002 specific BMI categorization with enhanced feedback
        final isUnder20_5 = bmi < 20.5;
        calculatedValue = isUnder20_5 ? 'Sì' : 'No';
        displayValue =
            'BMI: ${bmi.toStringAsFixed(1)} - ${isUnder20_5 ? "Sotto 20.5 (fattore di rischio)" : "Sopra o uguale a 20.5 (normale)"}';
        // NRS 2002 Q1-Q5 are screening questions with NO scores
        score = null;

        print(
          'NRS 2002 BMI CALCULATION: BMI=$bmi, under20.5=$isUnder20_5, NO SCORE (screening question)',
        );

        // CRITICAL FIX: Auto-assign the response immediately for NRS 2002 BMI calculation
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_responses[questionId] == null ||
              _responses[questionId]!['value'] != calculatedValue) {
            await _saveResponse(
              questionId,
              calculatedValue!,
              score,
              calculatedValue: displayValue,
            );
            print(
              'AUTO-SAVED NRS 2002 BMI RESPONSE: $calculatedValue with score $score',
            );

            // CRITICAL FIX: Force immediate UI update for NRS 2002
            if (mounted) {
              setState(() {
                _responses[questionId] = {
                  'value': calculatedValue,
                  'score': score,
                  'calculated_value': displayValue,
                };
              });
            }
          }
        });
      } else {
        calculatedValue = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score = 0;
        print('NRS 2002 BMI CALCULATION: No medical data available');
      }
    }
    // CRITICAL FIX: Specific handling for MUST BMI question with exact question ID matching
    else if (questionId == 'must_bmi_calculated') {
      final bmi = _calculatedValues['bmi'];
      if (bmi != null) {
        // MUST-specific BMI categorization with EXACT scoring criteria as requested
        if (bmi < 18.5) {
          calculatedValue = 'BMI < 18.5';
          displayValue = 'BMI: ${bmi.toStringAsFixed(1)} (Sottopeso grave)';
          score = 2;
        } else if (bmi >= 18.5 && bmi < 20.0) {
          calculatedValue = '18.5 ≤ BMI < 20';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Lievemente sottopeso)';
          score = 1;
        } else {
          calculatedValue = 'BMI ≥ 20';
          displayValue = 'BMI: ${bmi.toStringAsFixed(1)} (Normale o superiore)';
          score = 0;
        }

        print(
          'MUST BMI CALCULATION: BMI=$bmi, category=$calculatedValue, score=$score',
        );

        // CRITICAL: Auto-assign the response immediately for BMI calculation
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_responses[questionId] == null ||
              _responses[questionId]!['value'] != calculatedValue) {
            int bmiScore;
            if (bmi < 18.5) {
              bmiScore = 2;
            } else if (bmi >= 18.5 && bmi < 20.0) {
              bmiScore = 1;
            } else {
              bmiScore = 0;
            }

            await _saveResponse(
              questionId,
              calculatedValue!,
              bmiScore,
              calculatedValue: displayValue,
            );
            print(
              'AUTO-ASSIGNED MUST BMI: $calculatedValue with hidden score $bmiScore',
            );
          }
        });
      } else {
        calculatedValue = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        score = 0;
        print('MUST BMI CALCULATION: No medical data available');
      }
    }
    // Handle other BMI-related questions (legacy support)
    else if (questionId.contains('bmi') || questionId.contains('BMI')) {
      final bmi = _calculatedValues['bmi'];
      if (bmi != null) {
        calculatedValue = bmi.toStringAsFixed(1);
        displayValue = 'BMI: $calculatedValue';

        // For general BMI < 20.5 questions
        if (questionId.contains('20_5') || questionId.contains('under')) {
          final isUnder20_5 = bmi < 20.5;
          calculatedValue = isUnder20_5 ? 'Sì' : 'No';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} - ${isUnder20_5 ? "Sotto 20.5" : "Sopra o uguale a 20.5"}';
          score = isUnder20_5 ? 1 : 0;
        }
      }
    }
    // Handle pathology-related questions
    else if (questionId.contains('patologia') ||
        questionId.contains('pathology')) {
      final pathologyInfo = await _questionnaireService.getPathologyInfo(
        SupabaseService.instance.client.auth.currentUser?.id ??
            'd4a87e24-2cab-4fc0-a753-fba15ba7c755',
      );

      final hasPathology = pathologyInfo['has_pathology'] as bool? ?? false;
      final primaryPathology = pathologyInfo['primary_pathology'] as String?;

      if (hasPathology && primaryPathology != null) {
        calculatedValue = 'Sì';
        displayValue = primaryPathology;
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
      final weightLoss3m = _calculatedValues['weight_loss_3m'];
      if (weightLoss3m != null) {
        final isSignificantLoss = weightLoss3m > 5.0;
        calculatedValue = isSignificantLoss ? 'Sì' : 'No';
        displayValue =
            'Perdita di peso 3 mesi: ${weightLoss3m.toStringAsFixed(1)}% - ${isSignificantLoss ? "Significativa (>5%)" : "Non significativa (≤5%)"}';
        score = isSignificantLoss ? 1 : 0;
      }
    }

    // Save the calculated response if we have a value
    if (calculatedValue != null && _sessionId != null) {
      await _saveResponse(
        questionId,
        calculatedValue,
        score,
        calculatedValue: displayValue,
      );
      print(
        'CALCULATED QUESTION SAVED: $questionId = $calculatedValue (score: $score)',
      );
    }
  }

  Widget _buildQuestionWidget(Map<String, dynamic> question) {
    final questionType = question['question_type'] as String;
    final questionText = question['question_text'] as String;
    final questionId = question['question_id'] as String;

    // CRITICAL FIX: Enhanced options parsing to handle both List and Map formats safely
    List<dynamic> options = [];
    Map<String, dynamic> scores = {};

    try {
      final optionsRaw = question['options'];
      final scoresRaw = question['scores'];

      // Handle options field - could be List, Map, or null
      if (optionsRaw != null) {
        if (optionsRaw is List) {
          options = optionsRaw;
        } else if (optionsRaw is Map) {
          // If it's a Map, extract values as options
          options = (optionsRaw as Map<String, dynamic>).values.toList();
        } else if (optionsRaw is String) {
          // If it's a JSON string, try to parse it
          try {
            final parsed = jsonDecode(optionsRaw);
            if (parsed is List) {
              options = parsed;
            } else if (parsed is Map) {
              options = (parsed as Map<String, dynamic>).values.toList();
            }
          } catch (parseError) {
            print(
              'OPTION PARSE ERROR: Failed to parse options JSON: $parseError',
            );
            options = []; // Default to empty list
          }
        }
      }

      // Handle scores field - should be Map
      if (scoresRaw != null) {
        if (scoresRaw is Map) {
          scores = Map<String, dynamic>.from(scoresRaw);
        } else if (scoresRaw is String) {
          // If it's a JSON string, try to parse it
          try {
            final parsed = jsonDecode(scoresRaw);
            if (parsed is Map) {
              scores = Map<String, dynamic>.from(parsed);
            }
          } catch (parseError) {
            print(
              'SCORE PARSE ERROR: Failed to parse scores JSON: $parseError',
            );
            scores = {}; // Default to empty map
          }
        }
      }

      print(
        'PARSED QUESTION DATA: questionId=$questionId, questionType=$questionType, optionsCount=${options.length}, scoresCount=${scores.length}',
      );
    } catch (e) {
      print(
        'QUESTION PARSING ERROR: Failed to parse question data for $questionId: $e',
      );
      // Use safe defaults
      options = [];
      scores = {};
    }

    final isRequired = question['is_required'] as bool? ?? true;
    final currentValue = _responses[questionId]?['value']?.toString() ?? '';

    // CRITICAL FIX: Add specific handling for MUST weight loss question to ensure proper options
    if (questionId == 'must_weight_loss_3_6_months') {
      // Ensure MUST question 2 has exactly 3 options as requested
      if (options.isEmpty || options.length != 3) {
        print(
          'MUST WEIGHT LOSS: Fixing options for question 2 - current count: ${options.length}',
        );
        options = [
          '2-5% negli ultimi 3 mesi (o 5-10% negli ultimi 6 mesi)',
          '> 5% negli ultimi 3 mesi (o >10% negli ultimi 6 mesi)',
          'Grave perdita di peso (>15% negli ultimi 3-6 mesi o BMI<18.5 con perdita recente)',
        ];

        // Set appropriate scores for MUST questionnaire
        scores = {
          '2-5% negli ultimi 3 mesi (o 5-10% negli ultimi 6 mesi)': 1,
          '> 5% negli ultimi 3 mesi (o >10% negli ultimi 6 mesi)': 2,
          'Grave perdita di peso (>15% negli ultimi 3-6 mesi o BMI<18.5 con perdita recente)':
              2,
        };

        print(
          'MUST WEIGHT LOSS: Fixed options - now has ${options.length} options',
        );
      }
    }

    // Extract help text from notes field
    final helpText = question['notes'] as String?;

    switch (questionType) {
      case 'yes_no':
        return _buildYesNoQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
          scores,
          helpText,
        );
      case 'single_choice':
        return _buildSingleChoiceQuestion(
          questionText,
          questionId,
          options,
          currentValue,
          scores,
          isRequired,
          helpText,
        );
      case 'multiple_choice':
        return _buildMultipleChoiceQuestion(
          questionText,
          questionId,
          options,
          currentValue,
          scores,
          isRequired,
        );
      case 'scale_0_10':
        return _buildScaleQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
        );
      case 'number_input':
        return _buildNumberInputQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
        );
      case 'text_input':
        return _buildTextInputQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
        );
      case 'calculated':
        return _buildCalculatedQuestion(questionText, questionId, currentValue);
      case 'food_database':
        return _buildFoodDatabaseQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
        );
      default:
        return _buildTextInputQuestion(
          questionText,
          questionId,
          currentValue,
          isRequired,
        );
    }
  }

  Widget _buildYesNoQuestion(
    String questionText,
    String questionId,
    String currentValue,
    bool isRequired,
    Map<String, dynamic> scores,
    String? helpText,
  ) {
    // Get scores from database, with fallback to default values
    int yesScore = 1; // Default
    int noScore = 0;  // Default

    // Try to get scores from the scores map
    if (scores.isNotEmpty) {
      // Handle both "Sì" and "Si" variations
      if (scores.containsKey('Sì')) {
        yesScore = scores['Sì'] is int ? scores['Sì'] : int.tryParse(scores['Sì'].toString()) ?? 1;
      } else if (scores.containsKey('Si')) {
        yesScore = scores['Si'] is int ? scores['Si'] : int.tryParse(scores['Si'].toString()) ?? 1;
      }

      if (scores.containsKey('No')) {
        noScore = scores['No'] is int ? scores['No'] : int.tryParse(scores['No'].toString()) ?? 0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildQuestionTextWithFormatting(
                questionText,
                GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (helpText != null && helpText.isNotEmpty) ...[
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            SizedBox(width: 2.w),
                            Text(
                              'Informazione',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          helpText,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Chiudi',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                tooltip: 'Mostra informazioni',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: _buildChoiceCard(
                'Sì',
                currentValue == 'Sì',
                // CRITICAL FIX: Use scores from database instead of hardcoded values
                () => _saveResponse(
                  questionId,
                  'Sì',
                  (_isSarcFQuestionnaire() ||
                          _isSf12Questionnaire() ||
                          _isEsasQuestionnaire())
                      ? null
                      : yesScore,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildChoiceCard(
                'No',
                currentValue == 'No',
                // CRITICAL FIX: Use scores from database instead of hardcoded values
                () => _saveResponse(
                  questionId,
                  'No',
                  (_isSarcFQuestionnaire() ||
                          _isSf12Questionnaire() ||
                          _isEsasQuestionnaire())
                      ? null
                      : noScore,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleChoiceQuestion(
    String questionText,
    String questionId,
    List<dynamic> options,
    String currentValue,
    Map<String, dynamic> scores,
    bool isRequired, [
    String? helpText,
  ]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildQuestionTextWithFormatting(
                questionText,
                GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            if (helpText != null && helpText.isNotEmpty) ...[
              SizedBox(width: 2.w),
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade600),
                            SizedBox(width: 2.w),
                            Text(
                              'Informazione',
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          helpText,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Chiudi',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(
                  Icons.help_outline,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                tooltip: 'Mostra informazioni',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Column(
          children: options.map<Widget>((option) {
            final optionText = option.toString();
            final optionScore = scores[optionText] as int? ?? 0;

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: _buildChoiceCard(
                optionText,
                currentValue == optionText,
                // CRITICAL FIX: Don't calculate scores for SARC-F and SF-12 questionnaires
                () => _saveResponse(
                  questionId,
                  optionText,
                  (_isSarcFQuestionnaire() ||
                          _isSf12Questionnaire() ||
                          _isEsasQuestionnaire())
                      ? null
                      : optionScore,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMultipleChoiceQuestion(
    String questionText,
    String questionId,
    List<dynamic> options,
    String currentValue,
    Map<String, dynamic> scores,
    bool isRequired,
  ) {
    final selectedOptions =
        currentValue.isNotEmpty ? currentValue.split(',') : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Column(
          children: options.map<Widget>((option) {
            final optionText = option.toString();
            final isSelected = selectedOptions.contains(optionText);

            return Container(
              margin: EdgeInsets.only(bottom: 2.h),
              child: _buildMultipleChoiceCard(
                optionText,
                isSelected,
                () => _toggleMultipleChoice(questionId, optionText, scores),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildScaleQuestion(
    String questionText,
    String questionId,
    String currentValue,
    bool isRequired,
  ) {
    final currentScale = double.tryParse(currentValue) ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '0',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    currentScale.toInt().toString(),
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Text(
                    '10',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Slider(
                value: currentScale,
                min: 0,
                max: 10,
                divisions: 10,
                label: currentScale.toInt().toString(),
                onChanged: (value) {
                  // CRITICAL FIX: Don't calculate scores for SARC-F questionnaire
                  _saveResponse(
                    questionId,
                    value.toInt().toString(),
                    _isSarcFQuestionnaire() ? null : value.toInt(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputQuestion(
    String questionText,
    String questionId,
    String currentValue,
    bool isRequired,
  ) {
    // CRITICAL FIX: Use persistent controller with proper state management
    final controller = _getTextController(questionId, currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
            // CRITICAL FIX: Add focus indication
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withAlpha(13),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal:
                  true, // CRITICAL FIX: Allow decimal input for measurements
              signed: false, // Don't allow negative numbers
            ),
            textInputAction: TextInputAction.done,
            // CRITICAL FIX: Add autofocus and selection behavior for better input experience
            autofocus: false,
            textAlign: TextAlign.start,
            enableInteractiveSelection: true,
            maxLength: null, // Allow unlimited length for measurements
            decoration: InputDecoration(
              hintText: 'Inserisci un numero',
              border: InputBorder.none,
              hintStyle: GoogleFonts.inter(
                color: Colors.grey[500],
                fontSize: 16.sp,
              ),
              // CRITICAL FIX: Add content padding and improved styling
              contentPadding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 1.h,
              ),
              // CRITICAL FIX: Remove counter text that might interfere
              counterText: '',
            ),
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            // CRITICAL FIX: Enhanced text change handling with proper cursor management
            onChanged: (value) {
              print(
                'NUMBER INPUT CHANGED: questionId=$questionId, value="$value"',
              );

              // Immediate state update for UI responsiveness
              setState(() {
                _responses[questionId] = {
                  'value': value,
                  'score': _calculateNumberScore(value),
                  'calculated_value': null,
                };
              });

              // CRITICAL FIX: Debounced save to prevent too many database calls
              _debouncedSave(questionId, value);
            },
            // CRITICAL FIX: Handle submission when user presses done
            onSubmitted: (value) {
              print(
                'NUMBER INPUT SUBMITTED: questionId=$questionId, value="$value"',
              );
              _saveResponseImmediate(
                questionId,
                value,
                _calculateNumberScore(value),
              );
              // CRITICAL FIX: Keep focus for further input if needed
              FocusScope.of(context).requestFocus(FocusNode());
            },
            // CRITICAL FIX: Enhanced focus handling to prevent cursor issues
            onTap: () {
              print('NUMBER INPUT TAPPED: questionId=$questionId');
              // CRITICAL FIX: Ensure proper cursor positioning on tap
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.text.isNotEmpty) {
                  controller.selection = TextSelection.collapsed(
                    offset: controller.text.length,
                  );
                }
              });
            },
            // CRITICAL FIX: Handle editing complete to maintain focus if needed
            onEditingComplete: () {
              print('NUMBER INPUT EDITING COMPLETE: questionId=$questionId');
              // Don't automatically lose focus to allow continued editing
            },
          ),
        ),
        // CRITICAL FIX: Add visual feedback for current value
        if (currentValue.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Valore corrente: $currentValue${_getUnitForQuestion(questionId)}',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
        SizedBox(height: 2.h),
        // CRITICAL FIX: Add helpful instructions for SARC-F calf circumference
        if (questionId.contains('circonferenza') ||
            questionId.contains('circumference')) ...[
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue.withAlpha(13),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withAlpha(26)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600, size: 20),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Puoi inserire valori decimali (es. 32,5 cm). Tocca il campo per modificare liberamente.',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // CRITICAL FIX: Helper method to determine unit based on question
  String _getUnitForQuestion(String questionId) {
    if (questionId.contains('circonferenza') ||
        questionId.contains('circumference')) {
      return ' cm';
    }
    if (questionId.contains('peso') || questionId.contains('weight')) {
      return ' kg';
    }
    if (questionId.contains('altezza') || questionId.contains('height')) {
      return ' cm';
    }
    return '';
  }

  // CRITICAL FIX: Calculate appropriate score for number input
  int? _calculateNumberScore(String value) {
    // CRITICAL FIX: Don't calculate scores for SARC-F, SF-12, and ESAS questionnaires
    if (_isSarcFQuestionnaire() ||
        _isSf12Questionnaire() ||
        _isEsasQuestionnaire()) {
      return null; // No score calculation for SARC-F, SF-12, or ESAS
    }

    final numValue = double.tryParse(value);
    if (numValue == null || value.trim().isEmpty) return 0;

    // For SARC-F calf circumference, typically:
    // < 31 cm for men or < 33 cm for women indicates sarcopenia risk
    // Since we don't know gender here, use a general threshold
    if (numValue < 32.0) {
      return 1; // Higher score indicates higher risk
    }
    return 0;
  }

  // CRITICAL FIX: Debounced save to prevent excessive database calls
  Timer? _saveTimer;
  void _debouncedSave(String questionId, String value) {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () {
      final score = _calculateNumberScore(value);
      _saveResponseImmediate(questionId, value, score);
    });
  }

  // CRITICAL FIX: Immediate save method for critical saves
  Future<void> _saveResponseImmediate(
    String questionId,
    String value,
    int? score,
  ) async {
    try {
      print(
        'IMMEDIATE SAVE: questionId=$questionId, value="$value", score=$score',
      );
      await _saveResponse(questionId, value, score);
    } catch (e) {
      print('IMMEDIATE SAVE ERROR: $e');
    }
  }

  Widget _buildTextInputQuestion(
    String questionText,
    String questionId,
    String currentValue,
    bool isRequired,
  ) {
    final controller = _getTextController(questionId, currentValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Inserisci la tua risposta',
              border: InputBorder.none,
              hintStyle: GoogleFonts.inter(color: Colors.grey[500]),
            ),
            style: GoogleFonts.inter(fontSize: 16.sp),
            onChanged: (value) {
              _saveResponse(questionId, value, 0);
            },
          ),
        ),
      ],
    );
  }

  // CRITICAL FIX: Enhanced BMI display for calculated questions with NRS 2002-specific logic
  Widget _buildCalculatedQuestion(
    String questionText,
    String questionId,
    String currentValue,
  ) {
    final calculatedDisplayValue =
        _responses[questionId]?['calculated_value']?.toString();
    final responseValue = _responses[questionId]?['value']?.toString();

    String? displayValue;
    String? resultText;
    Color resultColor = Colors.blue.shade700;
    IconData resultIcon = Icons.calculate;

    // CRITICAL FIX: Enhanced NRS 2002 BMI question handling with improved visual feedback
    if (questionId == 'nrs_bmi_under_20_5' && _isNrs2002Questionnaire()) {
      final bmi = _calculatedValues['bmi'];
      if (bmi != null) {
        final isUnder20_5 = bmi < 20.5;
        resultText = isUnder20_5 ? 'Sì' : 'No';
        displayValue =
            'BMI: ${bmi.toStringAsFixed(1)} - ${isUnder20_5 ? "Sotto 20.5 (fattore di rischio)" : "Sopra o uguale a 20.5 (normale)"}';
        resultColor =
            isUnder20_5 ? Colors.orange.shade700 : Colors.green.shade700;
        resultIcon =
            isUnder20_5 ? Icons.warning_rounded : Icons.check_circle_rounded;

        // CRITICAL FIX: Auto-assign response with improved state management
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_responses[questionId] == null ||
              _responses[questionId]!['value'] != resultText) {
            final score = isUnder20_5 ? 1 : 0;
            await _saveResponse(
              questionId,
              resultText!,
              score,
              calculatedValue: displayValue,
            );
            print('AUTO-ASSIGNED NRS 2002 BMI: $resultText with score $score');

            // Force UI update
            if (mounted) {
              setState(() {
                _responses[questionId] = {
                  'value': resultText,
                  'score': score,
                  'calculated_value': displayValue,
                };
              });
            }
          }
        });
      } else {
        resultText = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        resultColor = Colors.grey.shade600;
        resultIcon = Icons.error_outline_rounded;
      }
    }
    // CRITICAL FIX: Enhanced MUST BMI question handling with exact question ID
    else if (questionId == 'must_bmi_calculated' && _isMustQuestionnaire()) {
      final bmi = _calculatedValues['bmi'];
      if (bmi != null) {
        // MUST-specific BMI categorization with exact scoring criteria (scores hidden from user)
        if (bmi < 18.5) {
          resultText = 'BMI < 18.5';
          displayValue = 'BMI: ${bmi.toStringAsFixed(1)} (Sottopeso grave)';
          resultColor = Colors.red.shade700;
          resultIcon = Icons.warning;
        } else if (bmi >= 18.5 && bmi < 20.0) {
          resultText = '18.5 ≤ BMI < 20';
          displayValue =
              'BMI: ${bmi.toStringAsFixed(1)} (Lievemente sottopeso)';
          resultColor = Colors.orange.shade700;
          resultIcon = Icons.info;
        } else {
          resultText = 'BMI ≥ 20';
          displayValue = 'BMI: ${bmi.toStringAsFixed(1)} (Normale o superiore)';
          resultColor = Colors.green.shade700;
          resultIcon = Icons.check_circle;
        }

        // Auto-assign response with correct question ID
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (_responses[questionId] == null ||
              _responses[questionId]!['value'] != resultText) {
            int bmiScore;
            if (bmi < 18.5) {
              bmiScore = 2;
            } else if (bmi >= 18.5 && bmi < 20.0) {
              bmiScore = 1;
            } else {
              bmiScore = 0;
            }

            await _saveResponse(
              questionId,
              resultText!,
              bmiScore,
              calculatedValue: displayValue,
            );
            print(
              'AUTO-ASSIGNED MUST BMI: $resultText with hidden score $bmiScore',
            );
          }
        });
      } else {
        resultText = 'Dati insufficienti';
        displayValue =
            'BMI non calcolabile - inserire altezza e peso nel profilo medico';
        resultColor = Colors.grey.shade600;
        resultIcon = Icons.error_outline;
      }
    }
    // Handle other calculated questions (existing logic)
    else if (questionId.contains('patologia') ||
        questionId.contains('pathology')) {
      final hasPathology = _calculatedValues['has_pathology'] as bool? ?? false;
      final pathologyText = _calculatedValues['pathology_text'] as String?;

      if (hasPathology && pathologyText != null) {
        resultText = 'Sì - $pathologyText';
        displayValue = 'Il paziente presenta: $pathologyText';
        resultColor = Colors.orange.shade700;
        resultIcon = Icons.medical_services;
      } else {
        resultText = 'No';
        displayValue = 'Nessuna patologia registrata nei dati medici';
        resultColor = Colors.green.shade700;
        resultIcon = Icons.health_and_safety;
      }
    }
    // Handle weight loss questions
    else if (questionId.contains('weight_loss') ||
        questionId.contains('perdita_peso')) {
      final weightLoss3m = _calculatedValues['weight_loss_3m'];
      if (weightLoss3m != null) {
        displayValue =
            'Perdita di peso (3 mesi): ${weightLoss3m.toStringAsFixed(1)}%';
        final isSignificant = weightLoss3m > 5.0;
        resultText = isSignificant ? 'Sì (>5%)' : 'No (≤5%)';
        resultColor =
            isSignificant ? Colors.red.shade700 : Colors.green.shade700;
        resultIcon = isSignificant ? Icons.trending_down : Icons.trending_flat;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            children: [
              Icon(resultIcon, color: resultColor, size: 32),
              SizedBox(height: 1.h),
              Text(
                'Valore Calcolato Automaticamente',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
              if (displayValue != null) ...[
                SizedBox(height: 1.h),
                Text(
                  displayValue,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (resultText != null) ...[
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: resultColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: resultColor.withAlpha(51)),
                  ),
                  child: Text(
                    // CRITICAL FIX: For NRS 2002 and MUST questionnaires, show clean result without "Risposta:" prefix
                    (_isMustQuestionnaire() || _isNrs2002Questionnaire())
                        ? resultText
                        : 'Risposta: $resultText',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: resultColor,
                    ),
                  ),
                ),
              ],
              if (responseValue == null && _calculatedValues.isEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  'Caricamento dati medici...',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              // CRITICAL FIX: Enhanced continue button for NRS 2002
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () {
                  // CRITICAL FIX: For NRS 2002, ensure all calculations are complete before proceeding
                  if (_isNrs2002Questionnaire() &&
                      questionId == 'nrs_bmi_under_20_5') {
                    print(
                        'NRS 2002: Ensuring BMI calculation is saved before proceeding');
                    // Small delay to ensure response is saved
                    Future.delayed(Duration(milliseconds: 300), () {
                      _nextQuestion();
                    });
                  } else {
                    _nextQuestion();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w,
                    vertical: 1.5.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Continua',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFoodDatabaseQuestion(
    String questionText,
    String questionId,
    String currentValue,
    bool isRequired,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          questionText,
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        if (isRequired) ...[
          SizedBox(height: 1.h),
          Text(
            '* Campo obbligatorio',
            style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red),
          ),
        ],
        SizedBox(height: 3.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Column(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Colors.orange.shade700,
                size: 32,
              ),
              SizedBox(height: 1.h),
              Text(
                'Selezione dal Database Alimentari',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () {
                  // TODO: Navigate to food database selection
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Selezione database alimentari - In sviluppo',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Seleziona Alimento',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
              if (currentValue.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  'Selezionato: $currentValue',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceCard(String text, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        print('CHOICE SELECTED: $text, isSelected: $isSelected');
        onTap();
        // Force UI update after selection
        setState(() {
          // This will trigger a rebuild and update the _canProceedToNext() check
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.blue.shade700 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceCard(
    String text,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.green.shade300 : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected ? Colors.green : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.green : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.green.shade700 : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CRITICAL FIX: Enhanced save response specifically for MUST questionnaire
  Future<void> _saveResponse(
    String questionId,
    String value,
    int? score, {
    String? calculatedValue,
  }) async {
    if (_sessionId == null) return;

    // CRITICAL FIX: Update local state immediately for UI responsiveness
    setState(() {
      _responses[questionId] = {
        'value': value,
        'score': score,
        'calculated_value': calculatedValue,
        'question_id': questionId,
      };
    });

    // CRITICAL FIX: For NRS 2002, re-filter conditional questions after saving screening questions
    if (_isNrs2002Questionnaire()) {
      final isScreeningQuestion = [
        'nrs_weight_loss_3m',
        'nrs_reduced_intake',
        'nrs_acute_pathology',
        'nrs_intensive_care'
      ].contains(questionId);

      if (isScreeningQuestion) {
        print('NRS 2002: Re-filtering conditional questions after saving $questionId');
        _filterConditionalQuestions();
      }
    }

    // CRITICAL FIX: For MUST questionnaire, don't show scores to user but still calculate backend
    print(
      'SAVE RESPONSE MUST: questionId=$questionId, value=$value, score=$score (hidden from user), sessionId=$_sessionId',
    );

    try {
      // CRITICAL FIX: Enhanced service call with retry logic
      final success =
          await _questionnaireService.saveQuestionnaireResponseWithRetry(
        _sessionId!,
        questionId,
        value,
        score, // Score is saved to backend but not shown to user for MUST
      );

      if (success) {
        print(
          'SAVE RESPONSE: Successfully saved response for question $questionId',
        );
      } else {
        print(
          'SAVE RESPONSE: Failed to save response for question $questionId',
        );
        // REMOVED: Hide orange popup as requested by user - users don't need to know about local saving
        // if (mounted) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text(
        //         'Risposta salvata localmente. Sarà sincronizzata automaticamente.',
        //       ),
        //       backgroundColor: Colors.orange,
        //       duration: Duration(seconds: 2),
        //     ),
        //   );
        // }
      }
    } catch (e) {
      print('SAVE RESPONSE ERROR: $e');

      // REMOVED: Hide orange popup as requested by user - users don't need to know about local saving
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text(
      //         'Risposta salvata localmente. Sarà sincronizzata automaticamente.',
      //       ),
      //       backgroundColor: Colors.orange,
      //       duration: Duration(seconds: 2),
      //     ),
      //   );
      // }
    }
  }

  void _toggleMultipleChoice(
    String questionId,
    String optionText,
    Map<String, dynamic> scores,
  ) {
    final currentValue = _responses[questionId]?['value']?.toString() ?? '';
    final selectedOptions =
        currentValue.isNotEmpty ? currentValue.split(',') : <String>[];

    if (selectedOptions.contains(optionText)) {
      selectedOptions.remove(optionText);
    } else {
      selectedOptions.add(optionText);
    }

    final newValue = selectedOptions.join(',');

    // CRITICAL FIX: Don't calculate scores for SARC-F questionnaire
    int? totalScore;
    if (!_isSarcFQuestionnaire() &&
        !_isSf12Questionnaire() &&
        !_isEsasQuestionnaire()) {
      totalScore = 0;
      for (final option in selectedOptions) {
        totalScore = (totalScore ?? 0) + (scores[option] as int? ?? 0);
      }
    }

    _saveResponse(questionId, newValue, totalScore);
  }

  void _nextQuestion() {
    print(
      'NEXT QUESTION: Current index $_currentQuestionIndex, Total questions ${_questions.length}',
    );

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
      _pageController?.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      print(
        'NAVIGATION: Moved to question ${_currentQuestionIndex + 1}/${_questions.length}',
      );
    } else {
      print('NAVIGATION: Reached last question, submitting questionnaire');
      _submitQuestionnaire();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
      _pageController?.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      print(
        'NAVIGATION: Moved back to question ${_currentQuestionIndex + 1}/${_questions.length}',
      );
    }
  }

  bool _canProceedToNext() {
    if (_questions.isEmpty) {
      print('CAN PROCEED: No questions available');
      return false;
    }

    final currentQuestion = _questions[_currentQuestionIndex];
    final questionId = currentQuestion['question_id'] as String;
    final questionType = currentQuestion['question_type'] as String;
    final isRequired = currentQuestion['is_required'] as bool? ?? true;

    // Special handling for calculated questions - they should always be able to proceed
    if (questionType == 'calculated') {
      print('CAN PROCEED: Calculated question, allowing proceed');
      return true;
    }

    // For non-required questions, always allow proceed
    if (!isRequired) {
      print('CAN PROCEED: Non-required question, allowing proceed');
      return true;
    }

    // Check if we have a response for this question
    final response = _responses[questionId];
    if (response == null) {
      print('CAN PROCEED: No response found for required question $questionId');
      return false;
    }

    final value = response['value']?.toString() ?? '';
    final canProceed = value.trim().isNotEmpty;

    print(
      'CAN PROCEED: questionId=$questionId, value="$value", canProceed=$canProceed',
    );

    return canProceed;
  }

  // CRITICAL FIX: Enhanced submission method with NRS 2002 specific pre-calculation
  Future<void> _submitQuestionnaire() async {
    if (_sessionId == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // CRITICAL FIX: For NRS 2002, ensure BMI calculation is complete before submission
      if (_isNrs2002Questionnaire()) {
        print(
            'NRS 2002 SUBMISSION: Pre-calculating BMI responses before completion');

        // Force calculation of BMI values if not already done
        await _loadCalculatedValues();
        await _populateCalculatedResponses();

        // Wait for calculations to complete
        await Future.delayed(Duration(milliseconds: 500));

        print('NRS 2002 SUBMISSION: BMI pre-calculation completed');
      }

      // CRITICAL FIX: Enhanced validation before submission
      print(
        'SUBMIT FIX: Starting questionnaire submission for session: $_sessionId',
      );

      final results = await _questionnaireService.completeAssessment(
        _sessionId!,
      );

      // CRITICAL FIX: Handle structured error responses from the enhanced service
      if (results != null && results['error'] == true) {
        final errorType =
            results['error_type'] as String? ?? 'completion_error';
        final errorMessage = results['error_message'] as String? ??
            'Si è verificato un problema nel completare il questionario';
        final actionRequired =
            results['action_required'] as String? ?? 'retry_completion';

        print('SUBMIT ERROR: $errorType - $errorMessage');

        setState(() {
          _isSubmitting = false;
        });

        // CRITICAL FIX: Show appropriate dialog based on error type
        if (errorType == 'bmi_validation_required') {
          // Show specific BMI validation error dialog
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.medical_information,
                      color: Colors.blue.shade700,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Dati Medici Richiesti',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per completare questo questionario sono necessari peso e altezza.',
                      style: GoogleFonts.inter(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.blue.shade700,
                            size: 24,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Le tue risposte sono state salvate automaticamente.',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Vai alle impostazioni del profilo per inserire i dati mancanti, poi riprova.',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Return to questionnaires
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: Text(
                      'Torna ai Questionari',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      // Navigate to profile settings (assuming route exists)
                      Navigator.pushNamed(context, '/profile-settings');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Aggiorna Profilo',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }
        } else {
          // Show generic completion error dialog (existing logic)
          if (mounted) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    Icon(
                      Icons.warning_amber,
                      color: Colors.orange.shade700,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Errore Completamento',
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorMessage,
                      style: GoogleFonts.inter(fontSize: 16.sp),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: Text(
                              'Le tue risposte sono state salvate automaticamente.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Vuoi riprovare a completare il questionario?',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(
                        context,
                      ); // Return to questionnaires list
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                    child: Text(
                      'Esci',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      _submitQuestionnaire(); // Retry submission
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF27AE60),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Riprova',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }
        }
        return; // Exit early for error cases
      }

      // CRITICAL FIX: Handle successful completion
      if (results != null && results['error'] != true) {
        print('SUBMIT SUCCESS: Assessment completed successfully: $results');
        setState(() {
          _isCompleted = true;
          _completionResults = results;
          _isSubmitting = false;
        });

        // CRITICAL FIX: Enhanced success message for NRS 2002
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _isNrs2002Questionnaire()
                          ? 'NRS 2002 completato con successo! Valutazione registrata.'
                          : 'Questionario "$_questionnaireName" completato con successo!',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: Color(0xFF27AE60),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Handle case where results is null or invalid
        throw Exception(
          'Risultati non ricevuti - possibile problema di connessione',
        );
      }
    } catch (e) {
      print('SUBMIT CATCH: Error in _submitQuestionnaire: $e');
      setState(() {
        _isSubmitting = false;
      });

      // CRITICAL FIX: Enhanced error handling with specific error detection for NRS 2002
      final errorMessage = e.toString();

      // CRITICAL FIX: For NRS 2002 specific errors, provide targeted guidance
      if (_isNrs2002Questionnaire() &&
          (errorMessage.contains('BMI') ||
              errorMessage.contains('peso') ||
              errorMessage.contains('altezza') ||
              errorMessage.contains('column') ||
              errorMessage.contains('does not exist'))) {
        print(
            'NRS 2002 SUBMIT ERROR: Detected NRS 2002-specific BMI calculation error');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.medical_information,
                      color: Colors.orange.shade700),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'NRS 2002 - Calcolo BMI',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Si è verificato un problema nel calcolo automatico del BMI per NRS 2002.',
                    style: GoogleFonts.inter(fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'Le tue risposte sono state salvate automaticamente.',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Assicurati che peso e altezza siano inseriti correttamente nel profilo medico e riprova.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to questionnaires
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    'Torna ai Questionari',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Navigate to profile settings
                    Navigator.pushNamed(context, '/profile-settings');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Verifica Profilo',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Check for specific database trigger errors
      if (errorMessage.contains('27000') ||
          errorMessage.contains('tuple to be updated was already modified') ||
          errorMessage.contains('operation triggered by the current command')) {
        print('SUBMIT ERROR: Detected SQL trigger conflict error');

        // For trigger conflicts, show a different message and suggest retry
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.sync_problem, color: Colors.orange.shade700),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Errore di Sincronizzazione',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Si è verificato un conflitto durante il salvataggio dei dati.',
                    style: GoogleFonts.inter(fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Le tue risposte sono state salvate automaticamente.',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Riprova tra qualche secondo per completare il questionario.',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to questionnaires list
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    'Esci',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Wait a moment before retrying to avoid immediate conflict
                    Future.delayed(Duration(seconds: 1), () {
                      _submitQuestionnaire(); // Retry submission
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Riprova',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        // For other errors, show the original generic error dialog
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange.shade700),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Errore Completamento',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Si è verificato un problema nel completare il questionario.',
                    style: GoogleFonts.inter(fontSize: 16.sp),
                  ),
                  SizedBox(height: 2.h),
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'Le tue risposte sono state salvate automaticamente.',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Vuoi riprovare a completare il questionario?',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to questionnaires list
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[600],
                  ),
                  child: Text(
                    'Esci',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _submitQuestionnaire(); // Retry submission
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF27AE60),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 1.5.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Riprova',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  Color _getRiskLevelColor(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRiskLevelText(String? riskLevel) {
    switch (riskLevel?.toLowerCase()) {
      case 'low':
        return 'Basso';
      case 'medium':
        return 'Medio';
      case 'high':
        return 'Alto';
      default:
        return 'Non determinato';
    }
  }

  Widget _buildCompletionScreen() {
    final totalScore = _completionResults?['total_score'] as int? ?? 0;
    final riskLevel = _completionResults?['risk_level'] as String? ?? '';

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade700,
                size: 60,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Questionario Completato!',
              style: GoogleFonts.inter(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            Text(
              'Grazie per aver completato "$_questionnaireName"',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),

            // ESAS questionnaire shows ONLY simple completion message (NO RESULTS or POINTS)
            if (_isEsasQuestionnaire()) ...[
              // For ESAS - show only simple "Questionario completato" message, NO results or points
              Text(
                'Questionario completato',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // For all other questionnaires - show the results container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withAlpha(51)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.medical_information,
                      color: Colors.blue.shade700,
                      size: 48,
                    ),
                    SizedBox(height: 2.h),

                    // NRS 2002 questionnaire shows score and advisory message
                    if (_isNrs2002Questionnaire()) ...[
                      Text(
                        'Valutazione Completata',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // CRITICAL FIX: Only display score if Q6 & Q7 were answered
                      if (_responses.containsKey('nrs_nutritional_status') &&
                          _responses.containsKey('nrs_disease_severity')) ...[
                        // Display the calculated score
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200, width: 2),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Punteggio Totale',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '$totalScore',
                                style: GoogleFonts.inter(
                                  fontSize: 48.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                      ],
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 32,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti.',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'La tua valutazione NRS 2002 è stata registrata e sarà disponibile per la revisione professionale.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.blue.shade600,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ]
                    // SF-12 questionnaire shows specific completion message (no score)
                    else if (_isSf12Questionnaire()) ...[
                      Text(
                        'Questionario Completato',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.assignment_turned_in,
                              color: Colors.green.shade700,
                              size: 32,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Le tue risposte al questionario SF-12 sono state registrate con successo.',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.green.shade700,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'I tuoi dati sono ora disponibili per la revisione da parte del professionista sanitario. Solo l\'ultima valutazione completata è conservata per la consultazione.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.green.shade600,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ]
                    // MUST questionnaire shows score and advisory message
                    else if (_isMustQuestionnaire()) ...[
                      Text(
                        'Valutazione Completata',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      // Display the calculated score
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200, width: 2),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Punteggio Totale',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade900,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '$totalScore',
                              style: GoogleFonts.inter(
                                fontSize: 48.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.blue.shade700,
                              size: 32,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Rivolgiti al professionista presso cui ti trovi in cura nutrizionale per approfondimenti.',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue.shade700,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'La tua valutazione è stata registrata e sarà disponibile per la revisione professionale.',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                color: Colors.blue.shade600,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Original results display for other questionnaires (SARC-F, etc.)
                      Text(
                        _isSarcFQuestionnaire()
                            ? 'Risposte Registrate'
                            : 'Risultati',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      if (_isSarcFQuestionnaire()) ...[
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.assignment_turned_in,
                                color: Colors.blue.shade700,
                                size: 32,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Le tue risposte sono state registrate con successo.',
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                'Puoi consultare le risposte della tua ultima valutazione nella sezione dei questionari completati.',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.blue.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Show scores for other scoring questionnaires (excluding ESAS)
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Punteggio Totale:',
                                    style: GoogleFonts.inter(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    totalScore.toString(),
                                    style: GoogleFonts.inter(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                'Torna ai Questionari',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCompleted) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.seaTop, AppTheme.seaMid, AppTheme.seaDeep],
              stops: [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildOceanHeader('Questionario Completato', showProgress: false),
                Expanded(child: _buildCompletionScreen()),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.seaTop, AppTheme.seaMid, AppTheme.seaDeep],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Ocean Header
              _buildOceanHeader(_questionnaireName ?? 'Questionario'),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _error != null
                        ? _buildErrorState()
                        : _questions.isEmpty
                            ? _buildEmptyState()
                            : _buildQuestionContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOceanHeader(String title, {bool showProgress = true}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showProgress && _questions.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getProgressDisplayText(),
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            )
          else
            SizedBox(width: 10.w),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(4.w),
        decoration: AppTheme.menuCardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
            SizedBox(height: 2.h),
            Text(
              _error!,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.red.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: _loadQuestionsAndResumeProgress,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaMid,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(4.w),
        padding: EdgeInsets.all(4.w),
        decoration: AppTheme.menuCardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 2.h),
            Text(
              'Nessuna domanda disponibile',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Le domande verranno caricate presto',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionContent() {
    return Column(
      children: [
        // Progress Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.all(4.w),
          decoration: AppTheme.menuCardDecoration,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: _isQuestionnaireFullyCompleted()
                              ? Colors.green.withAlpha(26)
                              : AppTheme.seaMid.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getProgressDisplayText(),
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: _isQuestionnaireFullyCompleted()
                                ? Colors.green.shade700
                                : AppTheme.seaMid,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${_getTotalQuestionsCount() > 0 ? ((_getCompletedQuestionsCount() / _getTotalQuestionsCount()) * 100).toInt() : 0}%',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _getTotalQuestionsCount() > 0
                      ? _getCompletedQuestionsCount() / _getTotalQuestionsCount()
                      : 0.0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _isQuestionnaireFullyCompleted()
                        ? Colors.green.shade600
                        : AppTheme.seaMid,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 2.h),

        // Question content
        Expanded(
          child: PageView.builder(
            controller: _pageController ?? PageController(), // CRITICAL FIX: Provide fallback if null
            onPageChanged: (index) {
              print('📄 PAGE CHANGED to index $index (Question ${index + 1}/${_questions.length})');
              setState(() {
                _currentQuestionIndex = index;
              });
            },
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final question = _questions[index];
              print('🔨 BUILDING question at index $index: ${question['question_id']}');
              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: AppTheme.menuCardDecoration,
                  child: _buildQuestionWidget(question),
                ),
              );
            },
          ),
        ),

        // Navigation buttons
        Container(
          margin: EdgeInsets.all(4.w),
          padding: EdgeInsets.all(4.w),
          decoration: AppTheme.menuCardDecoration,
          child: Row(
            children: [
              if (_currentQuestionIndex > 0) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousQuestion,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Precedente',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
              ],
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final canProceed = _canProceedToNext();
                    if (canProceed && !_isSubmitting) {
                      _nextQuestion();
                    } else if (!canProceed && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seleziona una risposta prima di continuare'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canProceedToNext()
                        ? AppTheme.seaMid
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _currentQuestionIndex == _questions.length - 1
                              ? 'Completa'
                              : 'Successiva',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
