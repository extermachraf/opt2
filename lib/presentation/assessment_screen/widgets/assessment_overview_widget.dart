import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/dashboard_service.dart';
import '../../../services/questionnaire_service.dart';
import '../../../theme/app_theme.dart';

class AssessmentOverviewWidget extends StatefulWidget {
  final String userId;
  final VoidCallback? onNavigateToQuestionnaire;

  const AssessmentOverviewWidget({
    super.key,
    required this.userId,
    this.onNavigateToQuestionnaire,
  });

  @override
  State<AssessmentOverviewWidget> createState() =>
      _AssessmentOverviewWidgetState();
}

class _AssessmentOverviewWidgetState extends State<AssessmentOverviewWidget> {
  final QuestionnaireService _questionnaireService = QuestionnaireService();
  Map<String, dynamic> progressData = {};
  bool isLoading = true;
  String? errorMessage;

  Future<void> _handleNavigationAndTracking(
      String navigationType, VoidCallback? callback) async {
    // Track the interaction before navigation
    try {
      await DashboardService.instance.trackAssessmentNavigation(navigationType);
    } catch (e) {
      print('Failed to track navigation: $e');
    }

    // Execute the navigation callback
    callback?.call();
  }

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _questionnaireService.getRealProgressData();

      if (!mounted) return;

      setState(() {
        progressData = data;
        isLoading = false;

        // Check if there was an error in the data or if fallback was used
        if (data.containsKey('error')) {
          if (data.containsKey('fallback_used')) {
            // Fallback was used - show data but with info message
            errorMessage =
                null; // Don't show error, just show reduced functionality
          } else {
            errorMessage = 'Errore nel caricamento dei dati di progresso';
          }
        }
      });
    } catch (e) {
      print('Error loading progress data: $e');
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Errore di connessione. Riprova più tardi.';
        progressData = {
          'overall': {
            'completed': 0,
            'total': 0,
            'percentage': 0,
            'completed_questionnaires': 0,
            'total_questionnaires': 0,
          },
          'categories': {},
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main progress overview container
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: AppTheme.menuCardDecoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with refresh button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Panoramica Valutazioni',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    GestureDetector(
                      onTap: isLoading ? null : _loadProgressData,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.seaMid.withAlpha(26),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 20,
                          color: isLoading ? Colors.grey : AppTheme.seaMid,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                if (isLoading)
                  _buildLoadingState()
                else if (errorMessage != null)
                  _buildErrorState()
                else
                  _buildProgressContent(),

                // Show info if fallback was used
                if (!isLoading &&
                    errorMessage == null &&
                    progressData.containsKey('fallback_used') &&
                    progressData['fallback_used'] == true) ...[
                  SizedBox(height: 1.5.h),
                  _buildFallbackInfoCard(),
                ],
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Navigation buttons section
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Inizia la tua valutazione',
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          'Completa i questionari clinici per una valutazione approfondita della tua salute nutrizionale:',
          style: GoogleFonts.inter(
            fontSize: 14.sp,
            color: Colors.white.withAlpha(200),
          ),
        ),
        SizedBox(height: 2.h),

        // Only Questionnaire button remains
        _buildNavigationCard(
          title: 'Questionari Clinici',
          subtitle: 'Valutazioni approfondite per la tua salute nutrizionale',
          icon: Icons.assignment_outlined,
          color: AppTheme.seaMid,
          onTap: () => _handleNavigationAndTracking(
              'questionnaire', widget.onNavigateToQuestionnaire),
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: AppTheme.menuCardDecoration,
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.seaMid.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppTheme.seaMid,
              ),
            ),
            SizedBox(width: 4.w),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppTheme.textMuted,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.seaMid.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.seaMid,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 15.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.seaMid),
              strokeWidth: 3,
            ),
            SizedBox(height: 2.h),
            Text(
              'Caricamento dati...',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: 12.h,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 32, color: Colors.red[400]),
            SizedBox(height: 1.h),
            Text(
              errorMessage!,
              style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.red[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            ElevatedButton(
              onPressed: _loadProgressData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaMid,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Riprova', style: GoogleFonts.inter(fontSize: 12.sp)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackInfoCard() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.orange.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            size: 20,
            color: Colors.orange,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Modalità semplificata attiva. Alcuni dettagli potrebbero non essere disponibili.',
              style: GoogleFonts.inter(fontSize: 11.sp, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    final overall = progressData['overall'] as Map<String, dynamic>? ?? {};
    final categories =
        progressData['categories'] as Map<String, Map<String, int>>? ?? {};

    final overallPercentage = overall['percentage'] as int? ?? 0;
    final completedQuestionnaires =
        overall['completed_questionnaires'] as int? ?? 0;
    final totalQuestionnaires = overall['total_questionnaires'] as int? ?? 0;
    final completedQuestions = overall['completed'] as int? ?? 0;
    final totalQuestions = overall['total'] as int? ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall progress section
        _buildOverallProgressCard(
          overallPercentage,
          completedQuestionnaires,
          totalQuestionnaires,
          completedQuestions,
          totalQuestions,
        ),

        SizedBox(height: 2.h),

        // Category breakdown
        if (categories.isNotEmpty) ...[
          Text(
            'Progresso per Categoria',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 1.5.h),
          ...categories.entries
              .map(
                (entry) => _buildCategoryProgress(
                  entry.key,
                  entry.value['completed'] ?? 0,
                  entry.value['total'] ?? 0,
                ),
              )
              .toList(),
        ],

        // Information about duplicate prevention
        if (overallPercentage > 0) ...[SizedBox(height: 2.h), _buildInfoCard()],
      ],
    );
  }

  Widget _buildOverallProgressCard(
    int percentage,
    int completedQuestionnaires,
    int totalQuestionnaires,
    int completedQuestions,
    int totalQuestions,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.seaTop, AppTheme.seaMid],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.seaMid.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso Totale',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${percentage}%',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.5.h),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage / 100.0,
              backgroundColor: Colors.white.withAlpha(77),
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),

          SizedBox(height: 1.5.h),

          // Stats breakdown - showing only questionnaires completed
          Center(
            child: _buildStatItem(
              'Questionari Completati',
              '$completedQuestionnaires/$totalQuestionnaires',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            color: Colors.white.withAlpha(230),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgress(String category, int completed, int total) {
    final percentage = total > 0 ? ((completed / total) * 100).round() : 0;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.seaMid.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.seaMid.withAlpha(51)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  category,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Text(
                '$completed/$total',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: total > 0 ? completed / total : 0.0,
              backgroundColor: AppTheme.seaMid.withAlpha(51),
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.seaMid),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    // return Container(
    //   padding: EdgeInsets.all(3.w),
    //   decoration: BoxDecoration(
    //     color: AppTheme.seaMid.withAlpha(26),
    //     borderRadius: BorderRadius.circular(12),
    //     border: Border.all(color: AppTheme.seaMid.withAlpha(77)),
    //   ),
    //   child: Row(
    //     children: [
    //       Icon(Icons.info_outline, size: 20, color: AppTheme.seaMid),
    //       SizedBox(width: 3.w),
    //       Expanded(
    //         child: Text(
    //           'I questionari completati non possono essere ripetuti. Il progresso mostrato è accurato e non include duplicati.',
    //           style: GoogleFonts.inter(fontSize: 14.sp, color: AppTheme.textDark),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    return const SizedBox.shrink();
  }
}
