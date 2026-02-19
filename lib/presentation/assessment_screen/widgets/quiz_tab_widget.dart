import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';
import '../../../services/quiz_service.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_routes.dart';

class QuizTabWidget extends StatefulWidget {
  final VoidCallback onDataChanged;
  final Function(int)? onProgressUpdate;
  final String? initialCategory;
  final bool hideCategorySelector;

  const QuizTabWidget({
    super.key,
    required this.onDataChanged,
    this.onProgressUpdate,
    this.initialCategory,
    this.hideCategorySelector = false,
  });

  @override
  State<QuizTabWidget> createState() => _QuizTabWidgetState();
}

class _QuizTabWidgetState extends State<QuizTabWidget> {
  int _currentQuestionIndex = 0;
  Map<int, dynamic> _answers = {};
  double _progressValue = 0.0;
  String _currentCategory = 'false_myths';

  List<Map<String, dynamic>> _currentQuestions = [];
  Map<String, dynamic>? _currentTemplate;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Set initial category if provided
    if (widget.initialCategory != null) {
      _currentCategory = widget.initialCategory!;
    }
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Use the enhanced method that can handle both category and topic queries
      final templates = await QuizService.getQuizTemplatesByCategoryOrTopic(
        _currentCategory,
      );

      if (templates.isNotEmpty) {
        _currentTemplate = templates.first;

        // Get questions for the template
        final questions = await QuizService.getQuizQuestions(
          _currentTemplate!['id'],
        );

        setState(() {
          _currentQuestions = questions;
          _isLoading = false;
          _updateProgress();
        });
      } else {
        setState(() {
          _error = 'Nessuna domanda trovata per questa categoria';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Errore nel caricamento delle domande: $e';
        _isLoading = false;
      });
    }
  }

  void _updateProgress() {
    if (_currentQuestions.isNotEmpty) {
      setState(() {
        _progressValue = (_currentQuestionIndex + 1) / _currentQuestions.length;
      });
    }
  }

  void _selectAnswer(dynamic answer) {
    setState(() {
      _answers[_currentQuestionIndex] = answer;
    });
    widget.onDataChanged();
    
    // Show explanation immediately after selecting answer
    _showExplanationAfterAnswer(answer);
  }

  void _showExplanationAfterAnswer(dynamic userAnswer) {
    if (_currentQuestions.isEmpty || _currentQuestionIndex >= _currentQuestions.length) {
      return;
    }

    final question = _currentQuestions[_currentQuestionIndex];
    final options = List<String>.from(question['options']);
    final userAnswerText = options[userAnswer];
    final correctAnswer = question['correct_answer'];
    final explanation = question['explanation'] ?? 'Spiegazione non disponibile';
    final isCorrect = userAnswerText == correctAnswer;

    print('📖 Showing explanation after answer: $userAnswerText (correct: $isCorrect)');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info_outline,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
              SizedBox(width: 2.w),
              Text(isCorrect ? 'Corretto!' : 'Risposta'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show user's answer vs correct answer
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect ? Colors.green.shade200 : Colors.orange.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'La tua risposta: $userAnswerText',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Risposta corretta: $correctAnswer',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                // Show explanation
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Auto-advance to next question after closing explanation
                Future.delayed(Duration(milliseconds: 300), () {
                  if (mounted) {
                    _nextQuestion();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: Text(
                _currentQuestionIndex == _currentQuestions.length - 1
                    ? 'Termina Quiz'
                    : 'Prossima Domanda',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _updateProgress();
      });
    } else {
      _showResults();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _updateProgress();
      });
    }
  }

  Future<void> _showResults() async {
    int correctAnswers = 0;
    int totalAnswered = 0;
    Map<String, dynamic> userAnswers = {};

    for (int i = 0; i < _currentQuestions.length; i++) {
      if (_answers.containsKey(i)) {
        totalAnswered++;
        final question = _currentQuestions[i];
        final userAnswer = _answers[i];
        final options = List<String>.from(question['options']);
        final selectedOption = options[userAnswer];
        final correctAnswer = question['correct_answer'];

        userAnswers[i.toString()] = {
          'question_id': question['id'],
          'selected_option': selectedOption,
          'correct_answer': correctAnswer,
          'is_correct': selectedOption == correctAnswer,
        };

        if (selectedOption == correctAnswer) {
          correctAnswers++;
        }
      }
    }

    final percentage =
        totalAnswered > 0 ? (correctAnswers / totalAnswered * 100).round() : 0;

    // Save quiz attempt to database
    if (_currentTemplate != null) {
      try {
        final user = AuthService.instance.currentUser;
        if (user != null) {
          await QuizService.saveQuizAttempt(
            userId: user.id,
            templateId: _currentTemplate!['id'],
            score: correctAnswers,
            totalQuestions: totalAnswered,
            answers: userAnswers,
          );
        }
      } catch (e) {
        print('Error saving quiz attempt: $e');
      }
    }

    // Update progress
    if (widget.onProgressUpdate != null) {
      widget.onProgressUpdate!(totalAnswered);
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                percentage >= 80
                    ? Icons.star
                    : percentage >= 60
                        ? Icons.thumb_up
                        : Icons.info,
                color: percentage >= 80
                    ? Colors.amber
                    : percentage >= 60
                        ? Colors.green
                        : Colors.orange,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text('Quiz Completato!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? Colors.green.withAlpha(26)
                      : percentage >= 60
                          ? Colors.blue.withAlpha(26)
                          : Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Punteggio:',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$correctAnswers/$totalAnswered',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: percentage >= 80
                            ? Colors.green
                            : percentage >= 60
                                ? Colors.blue
                                : Colors.orange,
                      ),
                    ),
                    Text(
                      'Completamento',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _getRecommendation(percentage),
                style: TextStyle(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetQuiz();
              },
              child: const Text('Riprova Quiz'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.patientEducation);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Quiz Educativi'),
            ),
          ],
        );
      },
    );
  }

  void _switchCategory() {
    setState(() {
      _currentCategory =
          _currentCategory == 'false_myths' ? 'topic_based' : 'false_myths';
      _currentQuestionIndex = 0;
      _answers.clear();
    });
    _loadQuizData();
  }

  String _getRecommendation(int percentage) {
    if (percentage >= 80) {
      return 'Eccellente! Hai una solida conoscenza della nutrizione durante il trattamento.';
    } else if (percentage >= 60) {
      return 'Buona conoscenza! Considera di rivedere alcuni concetti chiave sulla nutrizione.';
    } else {
      return 'Ti consigliamo di consultare il tuo team sanitario riguardo alla nutrizione durante il trattamento.';
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _progressValue = 0.0;
    });
    _loadQuizData();
  }

  void _showExplanation() {
    if (_currentQuestions.isEmpty || _currentQuestionIndex >= _currentQuestions.length) {
      print('❌ Cannot show explanation: no questions or invalid index');
      return;
    }

    final question = _currentQuestions[_currentQuestionIndex];
    final explanation = question['explanation'] ?? 'Spiegazione non disponibile';
    
    print('📖 Showing explanation for question ${_currentQuestionIndex + 1}: ${explanation.substring(0, 50)}...');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.orange),
              SizedBox(width: 2.w),
              Text('Spiegazione'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Domanda: ${question['question_text'] ?? question['question'] ?? 'Domanda non disponibile'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    explanation,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Ho capito!',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        padding: EdgeInsets.all(3.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4CAF50)),
              SizedBox(height: 2.h),
              Text(
                'Caricamento domande...',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: EdgeInsets.all(3.w),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
              SizedBox(height: 2.h),
              Text(
                _error!,
                style: TextStyle(fontSize: 16.sp, color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: _loadQuizData,
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentQuestions.isEmpty) {
      return Container(
        padding: EdgeInsets.all(3.w),
        child: Center(
          child: Text(
            'Nessuna domanda disponibile per questa categoria',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final currentQuestion = _currentQuestions[_currentQuestionIndex];
    final hasAnswer = _answers.containsKey(_currentQuestionIndex);
    final options = List<String>.from(currentQuestion['options']);

    return Container(
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Selector - Only show if hideCategorySelector is false
          if (!widget.hideCategorySelector)
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_currentCategory != 'false_myths') {
                          _switchCategory();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 3.w,
                        ),
                        decoration: BoxDecoration(
                          color: _currentCategory == 'false_myths'
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Falsi Miti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _currentCategory == 'false_myths'
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        if (_currentCategory != 'topic_based') {
                          _switchCategory();
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 1.h,
                          horizontal: 3.w,
                        ),
                        decoration: BoxDecoration(
                          color: _currentCategory == 'topic_based'
                              ? const Color(0xFF4CAF50)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Quiz Argomenti',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: _currentCategory == 'topic_based'
                                ? Colors.white
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Add spacing only if category selector is shown
          if (!widget.hideCategorySelector) SizedBox(height: 2.h),

          // Progress Indicator
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
                      'Domanda ${_currentQuestionIndex + 1} di ${_currentQuestions.length}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '${(_progressValue * 100).round()}%',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4CAF50),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        IconButton(
                          onPressed: () {
                            print('🔍 Help button pressed for question ${_currentQuestionIndex + 1}');
                            _showExplanation();
                          },
                          icon: const CustomIconWidget(
                            iconName: 'help_outline',
                            color: Colors.grey,
                            size: 20,
                          ),
                          tooltip: 'Mostra spiegazione',
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Question Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion['question_text'],
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Expanded(child: _buildAnswerOptions(options)),
                ],
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Navigation Buttons - Only show if no answer is selected yet
          if (!hasAnswer)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton.icon(
                    onPressed: _previousQuestion,
                    icon: const CustomIconWidget(
                      iconName: 'arrow_back',
                      color: Colors.white,
                      size: 16,
                    ),
                    label: const Text('Precedente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.5.h,
                      ),
                    ),
                  )
                else
                  const SizedBox(),
                const SizedBox(), // Placeholder since next happens automatically
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(List<String> options) {
    return ListView.separated(
      itemCount: options.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final isSelected = _answers[_currentQuestionIndex] == index;
        return InkWell(
          onTap: () => _selectAnswer(index),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF4CAF50).withAlpha(26)
                  : Colors.grey[50],
              border: Border.all(
                color: isSelected ? const Color(0xFF4CAF50) : Colors.grey[300]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    options[index],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color:
                          isSelected ? const Color(0xFF4CAF50) : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
