import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/body_metrics_service.dart';
import '../../services/questionnaire_service.dart';
import '../../theme/app_theme.dart';
import '../../routes/app_routes.dart';
import './widgets/bmi_validation_modal.dart';

class QuestionnairePage extends StatefulWidget {
  const QuestionnairePage({Key? key}) : super(key: key);

  @override
  State<QuestionnairePage> createState() => _QuestionnairePageState();
}

class _QuestionnairePageState extends State<QuestionnairePage> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  final BodyMetricsService _bodyMetricsService = BodyMetricsService.instance;

  List<Map<String, dynamic>> _questionnaires = [];
  bool _isLoading = true;
  String? _error;
  Map<String, double> _categoryProgress = {};
  Map<String, Map<String, dynamic>> _todaysSessions = {}; // Track today's sessions by questionnaire type
  double _overallProgress = 0.0;
  int _selectedNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestionnaires();
    _loadProgress();
  }

  Future<void> _loadQuestionnaires() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final questionnaires =
          await _questionnaireService.getQuestionnaireTemplates();

      // Filter out "Diario Alimentare" category questionnaires
      final filteredQuestionnaires = questionnaires.where((questionnaire) {
        final category =
            questionnaire['category']?.toString().toLowerCase() ?? '';
        return !category.contains('diario alimentare') &&
            !category.contains('diario');
      }).toList();

      setState(() {
        _questionnaires = filteredQuestionnaires;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento dei questionari: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProgress() async {
    try {
      final progressData = await _questionnaireService.getRealProgressData();
      final overallData = progressData['overall'] as Map<String, dynamic>;
      final categoriesData =
          progressData['categories'] as Map<String, Map<String, int>>;

      // Convert overall progress to double (0.0 to 1.0)
      final overallProgress = (overallData['percentage'] as int) / 100.0;

      // Convert category progress to Map<String, double>
      final categoryProgress = <String, double>{};
      for (final entry in categoriesData.entries) {
        final categoryName = entry.key;
        final progress = entry.value;
        final total = progress['total'] ?? 0;
        final completed = progress['completed'] ?? 0;
        categoryProgress[categoryName] = total > 0 ? completed / total : 0.0;
      }

      setState(() {
        _overallProgress = overallProgress;
        _categoryProgress = categoryProgress;
      });

      // Load today's sessions for all questionnaires
      await _loadTodaysSessions();
    } catch (e) {
      setState(() {
        _overallProgress = 0.0;
        _categoryProgress = {};
      });
    }
  }

  Future<void> _loadTodaysSessions() async {
    try {
      final todaysSessions = <String, Map<String, dynamic>>{};

      // Check today's session for each questionnaire
      for (final questionnaire in _questionnaires) {
        final questionnaireType = questionnaire['questionnaire_type'] as String?;
        if (questionnaireType != null) {
          final sessionInfo = await _questionnaireService.getTodaysSessionInfo(questionnaireType);
          if (sessionInfo != null) {
            todaysSessions[questionnaireType] = sessionInfo;
          }
        }
      }

      setState(() {
        _todaysSessions = todaysSessions;
      });
    } catch (e) {
      print('Error loading today\'s sessions: $e');
    }
  }

  /// ENHANCED: Check if questionnaire requires BMI validation with more specific rules
  bool _requiresBMIValidation(String questionnaireType, String category) {
    final categoryLower = category.toLowerCase();
    final typeLower = questionnaireType.toLowerCase();

    // More comprehensive BMI validation requirements
    final requiresBMI = categoryLower.contains('must') ||
        categoryLower.contains('nrs') ||
        categoryLower.contains('sarcopenia') ||
        categoryLower.contains('nutrizionale') ||
        categoryLower.contains('nutritional') ||
        typeLower.contains('must') ||
        typeLower.contains('nrs') ||
        typeLower.contains('sarc') ||
        typeLower.contains('nutritional_risk') ||
        typeLower.contains('consolidated_nutritional');

    // Additional logging for debugging
    print(
        '🔍 BMI Check - Type: $questionnaireType, Category: $category, Requires BMI: $requiresBMI');

    return requiresBMI;
  }

  /// ENHANCED: Start questionnaire with improved BMI validation
  Future<void> _startQuestionnaire(
    String questionnaireType,
    String title,
  ) async {
    print('🚀 Starting questionnaire: $questionnaireType');

    try {
      // Get questionnaire details to check if BMI validation is required
      final questionnaire = _questionnaires.firstWhere(
        (q) => q['questionnaire_type'] == questionnaireType,
        orElse: () => <String, dynamic>{},
      );

      final category = questionnaire['category']?.toString() ?? '';

      // Enhanced BMI validation logic
      if (_requiresBMIValidation(questionnaireType, category)) {
        print('⚖️ BMI validation required for $questionnaireType');

        // Show loading indicator while validating BMI
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        try {
          // Validate BMI data with enhanced error handling
          final validationResult =
              await _bodyMetricsService.validateBMIForQuestionnaire();

          // Close loading dialog
          Navigator.of(context).pop();

          // Log validation result for debugging
          print('📋 BMI Validation Result: ${validationResult.toString()}');

          if (!validationResult.isValid) {
            print('❌ BMI validation failed: ${validationResult.message}');

            // Show enhanced BMI validation modal
            await BMIValidationModal.show(
              context: context,
              validationResult: validationResult,
              onUpdatePressed: () async {
                print('🔄 Navigating to body metrics for BMI update');

                // Navigate to body metrics page with enhanced arguments
                final result = await Navigator.pushNamed(
                  context,
                  AppRoutes.bodyMetrics,
                  arguments: {
                    'returnAfterUpdate': true,
                    'questionnairePending': {
                      'type': questionnaireType,
                      'title': title,
                    },
                    'requiredUpdate': {
                      'weight': validationResult.requiresWeightUpdate,
                      'height': validationResult.requiresHeightUpdate,
                    },
                    'validationMessage': validationResult.message,
                  },
                );

                // After returning from body metrics, re-validate and potentially start questionnaire
                if (result == true) {
                  print(
                      '✅ Returned from body metrics, restarting questionnaire');
                  await Future.delayed(const Duration(milliseconds: 500));
                  _startQuestionnaire(questionnaireType, title);
                }
              },
              onCancelPressed: () {
                print('🚫 BMI validation cancelled by user');
              },
            );
            return;
          } else {
            print(
                '✅ BMI validation passed: BMI=${validationResult.bmi?.toStringAsFixed(1)}');
          }
        } catch (validationError) {
          // Close loading dialog if still open
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }

          print('🔥 BMI validation error: $validationError');

          // Show error-specific modal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Errore durante la validazione BMI. Verifica la connessione.',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
              action: SnackBarAction(
                label: 'RIPROVA',
                textColor: Colors.white,
                onPressed: () => _startQuestionnaire(questionnaireType, title),
              ),
            ),
          );
          return;
        }
      } else {
        print('⏭️ No BMI validation required for $questionnaireType');
      }

      // Continue with normal questionnaire flow
      print('🔄 Starting assessment session...');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final sessionId = await _questionnaireService.startAssessmentSession(
        questionnaireType,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (sessionId != null) {
        print('✅ Assessment session created: $sessionId');

        // Get template ID for the questionnaire type with improved validation
        String? templateId;

        // First try to get from the loaded questionnaires
        final template = _questionnaires.firstWhere(
          (q) => q['questionnaire_type'] == questionnaireType,
          orElse: () => <String, dynamic>{},
        );

        templateId = template['id'] as String?;

        // If not found, try to get from service
        if (templateId == null || templateId.isEmpty) {
          templateId = await _questionnaireService.getTemplateIdForType(
            questionnaireType,
          );
        }

        // Final validation - if still no template ID, use the session itself to determine template
        if (templateId == null || templateId.isEmpty) {
          print(
              '⚠️ Template ID not found for $questionnaireType, attempting fallback navigation');

          // Navigate without template ID - let the detail screen handle the lookup
          Navigator.pushNamed(
            context,
            AppRoutes.questionnaireDetail,
            arguments: {
              'sessionId': sessionId,
              'questionnaireType': questionnaireType,
              'templateId': '', // Empty, will be resolved in detail screen
              'questionnaireName': title,
            },
          );
          return;
        }

        // Navigate to questionnaire detail screen with validated template ID
        print('📱 Navigating to questionnaire detail screen');
        Navigator.pushNamed(
          context,
          AppRoutes.questionnaireDetail,
          arguments: {
            'sessionId': sessionId,
            'questionnaireType': questionnaireType,
            'templateId': templateId,
            'questionnaireName': title,
          },
        );
      } else {
        print('❌ Failed to create assessment session');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Impossibile avviare il questionario. Riprova tra qualche momento.',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'RIPROVA',
              textColor: Colors.white,
              onPressed: () => _startQuestionnaire(questionnaireType, title),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('🔥 Error starting questionnaire: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Errore tecnico. Riprova più tardi.')),
            ],
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'RIPROVA',
            textColor: Colors.white,
            onPressed: () => _startQuestionnaire(questionnaireType, title),
          ),
        ),
      );
    }
  }

  Color _getCategoryColor(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('diario')) return Colors.orange;
    if (categoryLower.contains('must')) return Colors.blue;
    if (categoryLower.contains('nrs')) return Colors.green;
    if (categoryLower.contains('esas')) return Colors.red;
    if (categoryLower.contains('sf12')) return Colors.purple;
    if (categoryLower.contains('sarc')) return Colors.indigo;
    if (categoryLower.contains('funzionale')) return Colors.teal;
    if (categoryLower.contains('metabolica')) return Colors.amber;
    return Colors.grey;
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();
    if (categoryLower.contains('diario')) return Icons.restaurant_menu;
    if (categoryLower.contains('must')) return Icons.assessment;
    if (categoryLower.contains('nrs')) return Icons.medical_services;
    if (categoryLower.contains('esas')) return Icons.mood;
    if (categoryLower.contains('sf12')) return Icons.favorite;
    if (categoryLower.contains('sarc')) return Icons.fitness_center;
    if (categoryLower.contains('funzionale')) return Icons.directions_run;
    if (categoryLower.contains('metabolica')) return Icons.science;
    return Icons.quiz;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
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
          bottom: false,
          child: Column(
            children: [
              // Ocean Header
              _buildOceanHeader(),

              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadQuestionnaires();
                    await _loadProgress();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress Card
                        _buildProgressCard(),

                        SizedBox(height: 2.h),

                        // Section Title
                        Text(
                          'Questionari Clinici',
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),

                        SizedBox(height: 1.5.h),

                        if (_isLoading)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.h),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          )
                        else if (_error != null)
                          _buildErrorCard()
                        else if (_questionnaires.isEmpty)
                          _buildEmptyCard()
                        else
                          _buildQuestionnairesList(),

                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildOceanBottomNav(),
    );
  }

  Widget _buildOceanHeader() {
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
              'Questionari Clinici',
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(51),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${(_overallProgress * 100).toInt()}%',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    final completedCount = _questionnaires.where((q) {
      final progress = _categoryProgress[q['category']] ?? 0.0;
      return progress >= 1.0;
    }).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progresso Totale',
                    style: GoogleFonts.inter(
                      fontSize: 19.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Questionari completati: $completedCount/${_questionnaires.length}',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.seaMid.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(_overallProgress * 100).toInt()}%',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp, // Increased from 14.sp for better readability
                    fontWeight: FontWeight.bold,
                    color: AppTheme.seaMid,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _overallProgress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.seaMid),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          SizedBox(height: 2.h),
          Text(
            _error!,
            style: GoogleFonts.inter(
              fontSize: 16.sp, // Increased from 14.sp for better readability
              color: Colors.red.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton(
            onPressed: () {
              _loadQuestionnaires();
              _loadProgress();
            },
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
    );
  }

  Widget _buildEmptyCard() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          SizedBox(height: 2.h),
          Text(
            'Nessun questionario disponibile',
            style: GoogleFonts.inter(
              fontSize: 18.sp, // Increased from 16.sp for better readability
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'I questionari verranno caricati presto',
            style: GoogleFonts.inter(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionnairesList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _questionnaires.length,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) {
        final questionnaire = _questionnaires[index];
        return _buildQuestionnaireCard(questionnaire);
      },
    );
  }

  Widget _buildQuestionnaireCard(Map<String, dynamic> questionnaire) {
    final title = questionnaire['title'] ?? 'Senza titolo';
    final description = questionnaire['description'] ?? 'Nessuna descrizione disponibile';
    final category = questionnaire['category'] ?? 'Categoria Sconosciuta';
    final questionnaireType = questionnaire['questionnaire_type'] ?? '';
    final requiresBMI = _requiresBMIValidation(questionnaireType, category);

    // Get progress for this questionnaire
    final progress = _categoryProgress[category] ?? 0.0;
    final progressPercent = (progress * 100).toInt();

    // Check today's session status
    final todaysSession = _todaysSessions[questionnaireType];
    final hasSessionToday = todaysSession != null;
    final isCompletedToday = hasSessionToday && todaysSession['status'] == 'completed';
    final isInProgress = hasSessionToday && todaysSession['status'] == 'in_progress';

    return Container(
      decoration: AppTheme.menuCardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startQuestionnaire(questionnaireType, title),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.seaMid.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category,
                        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          fontSize: 15.sp, // Explicit size for better readability
                          fontWeight: FontWeight.w600,
                          color: AppTheme.seaMid,
                        ),
                      ),
                    ),
                    if (isCompletedToday)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Completato oggi',
                            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                              fontSize: 15.sp, // Explicit size for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade600,
                            ),
                          ),
                        ],
                      )
                    else if (isInProgress)
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.orange.shade600,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'In corso',
                            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                              fontSize: 15.sp, // Explicit size for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade600,
                            ),
                          ),
                        ],
                      )
                    else if (progressPercent >= 100)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Completato',
                            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                              fontSize: 15.sp, // Explicit size for better readability
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                SizedBox(height: 1.5.h),

                // Title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    if (requiresBMI)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monitor_weight_outlined,
                              size: 12,
                              color: Colors.orange.shade700,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'BMI',
                              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 0.5.h),

                // Description
                Text(
                  description,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp, // Increased from 12.sp for better readability
                    color: AppTheme.textMuted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 1.5.h),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progressPercent >= 100
                          ? Colors.green.shade500
                          : Colors.orange.shade400,
                    ),
                    minHeight: 6,
                  ),
                ),

                SizedBox(height: 1.5.h),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startQuestionnaire(questionnaireType, title),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.seaMid,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isCompletedToday ? 'Modifica' : (isInProgress ? 'Continua' : 'Inizia'),
                      style: GoogleFonts.inter(
                        fontSize: 16.sp, // Increased from 14.sp for better readability
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: AppTheme.fabGradientDecoration,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.addMeal);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildOceanBottomNav() {
    return Container(
      margin: EdgeInsets.fromLTRB(4.w, 0, 4.w, 2.h),
      decoration: AppTheme.bottomNavDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.bottomNavBorderRadius),
        child: BottomNavigationBar(
          currentIndex: _selectedNavIndex,
          onTap: _onNavTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.seaMid,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 10.sp,
          unselectedFontSize: 10.sp,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Diario',
            ),
            BottomNavigationBarItem(
              icon: SizedBox(width: 24, height: 24),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Report',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    if (index == 2) return; // FAB placeholder

    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealDiary);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profileSettings);
        break;
    }
  }
}
