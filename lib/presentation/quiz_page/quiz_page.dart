import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:convert';

import '../../core/app_export.dart';
import '../../services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  Map<String, dynamic> _answers = {};
  double _progressValue = 0.0;
  String? _currentCategory;
  String? _currentTemplateId;
  int _overallProgress = 0;
  bool _showCategorySelection = true;
  bool _isLoading = false;

  // New variables for explanation timer functionality
  bool _showExplanation = false;
  int _explanationCountdown = 5;
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;

  // Database-loaded quiz data
  List<Map<String, dynamic>> _availableQuizzes = [];
  List<Map<String, dynamic>> _currentQuestions = [];
  Map<String, dynamic>? _currentQuizTemplate;

  @override
  void initState() {
    super.initState();
    _loadAvailableQuizzes();

    // Initialize timer animation controller
    _timerAnimationController = AnimationController(
      duration: Duration(seconds: 5),
      vsync: this,
    );

    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerAnimationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _timerAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableQuizzes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load quiz templates from database
      final templates = await QuizService.getAllQuizTemplates();

      setState(() {
        _availableQuizzes = templates.map((template) {
          return {
            'id': template['id'],
            'title': template['title'],
            'description': template['description'] ?? 'Quiz educativo',
            'category': template['category'],
            'topic': template['topic'],
            'icon': _getIconForCategory(template['category']),
            'color': _getColorForCategory(template['category']),
            'estimatedTime': '8-12 min',
            'difficulty':
                template['category'] == 'false_myths' ? 'Intermedio' : 'Base',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading quizzes: $e');
      // Show error or fallback to empty list
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'false_myths':
        return Icons.psychology;
      case 'topic_based':
        return Icons.school;
      default:
        return Icons.quiz;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'false_myths':
        return Colors.purple;
      case 'topic_based':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }

  void _showExplanationWithTimer(dynamic userAnswer) {
    if (_currentQuestionIndex >= _currentQuestions.length) return;

    final currentQuestion = _currentQuestions[_currentQuestionIndex];
    final userAnswerText = currentQuestion['options'][userAnswer];
    final correctAnswer = currentQuestion['correct_answer'];
    final explanation =
        currentQuestion['explanation'] ?? 'Spiegazione non disponibile';
    final isCorrect = userAnswerText == correctAnswer;

    // Debug logging
    print('🎯 Showing explanation for question ${_currentQuestionIndex + 1}');
    print('User answer: $userAnswerText');
    print('Correct answer: $correctAnswer');
    print(
        'Explanation: ${explanation.length > 50 ? explanation.substring(0, 50) + '...' : explanation}');
    print('Is correct: $isCorrect');

    setState(() {
      _showExplanation = true;
      _explanationCountdown = 5;
    });

    // Start the timer animation
    _timerAnimationController.reset();
    _timerAnimationController.forward();

    // Start countdown timer
    _startExplanationTimer();
  }

  void _startExplanationTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (_showExplanation && _explanationCountdown > 1) {
        setState(() {
          _explanationCountdown--;
        });
        _startExplanationTimer();
      } else if (_showExplanation && _explanationCountdown <= 1) {
        setState(() {
          _showExplanation = false;
          _explanationCountdown = 5;
        });
        _timerAnimationController.reset();
        // Auto advance to next question
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            _nextQuestion();
          }
        });
      }
    });
  }

  void _loadQuizQuestions(String templateId) async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading quiz questions for template: $templateId');
      final questions = await QuizService.getQuizQuestions(templateId);
      print('✅ Loaded ${questions.length} questions from database');

      setState(() {
        _currentQuestions = questions.map((q) {
          List<String> options;
          try {
            // Parse JSON options safely
            if (q['options'] is List) {
              options = List<String>.from(q['options']);
            } else if (q['options'] is String) {
              // Parse JSON string
              final dynamic parsed = jsonDecode(q['options']);
              options = List<String>.from(parsed);
            } else {
              options = ['Vero', 'Falso']; // Default fallback
            }
          } catch (e) {
            print('⚠️ Error parsing options for question ${q['id']}: $e');
            options = ['Vero', 'Falso']; // Default fallback
          }

          // Debug log for explanation
          final explanation = q['explanation']?.toString() ?? '';
          print(
              '📝 Question ${q['order_index']}: ${q['question_text']?.substring(0, 30)}...');
          print('   Explanation length: ${explanation.length}');
          print('   Has explanation: ${explanation.isNotEmpty}');

          return {
            'id': q['id'],
            'question': q['question_text'],
            'options': options,
            'correct_answer': q['correct_answer'],
            'explanation': explanation.isNotEmpty
                ? explanation
                : 'Spiegazione non disponibile per questa domanda.',
            'order_index': q['order_index'] ?? 0,
          };
        }).toList();

        // Sort by order_index
        _currentQuestions.sort((a, b) =>
            (a['order_index'] as int).compareTo(b['order_index'] as int));
      });

      print('✅ Successfully processed ${_currentQuestions.length} questions');
    } catch (e) {
      print('❌ Error loading quiz questions: $e');
      setState(() {
        _currentQuestions = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _updateProgress() {
    setState(() {
      _progressValue = _currentQuestions.isEmpty
          ? 0
          : (_currentQuestionIndex + 1) / _currentQuestions.length;
    });
    _calculateOverallProgress();
  }

  void _calculateOverallProgress() {
    // Simple progress calculation for current quiz
    setState(() {
      _overallProgress = _currentQuestions.isEmpty
          ? 0
          : ((_currentQuestionIndex + 1) / _currentQuestions.length * 100)
              .round();
    });
  }

  void _selectAnswer(dynamic answer) {
    if (_currentTemplateId == null || _showExplanation) return;
    final key = '${_currentTemplateId}_$_currentQuestionIndex';
    setState(() {
      _answers[key] = answer;
    });

    // Show explanation with timer instead of dialog
    _showExplanationWithTimer(answer);
    _calculateOverallProgress();
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _showExplanation = false;
        _explanationCountdown = 5;
        _updateProgress();
      });
      _timerAnimationController.reset();
    } else {
      _showQuizComplete();
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _showExplanation = false;
        _explanationCountdown = 5;
        _updateProgress();
      });
      _timerAnimationController.reset();
    }
  }

  void _selectQuiz(Map<String, dynamic> quiz) async {
    setState(() {
      _currentCategory = quiz['category'];
      _currentTemplateId = quiz['id'];
      _currentQuizTemplate = quiz;
      _currentQuestionIndex = 0;
      _showCategorySelection = false;
      _answers.clear();
      _showExplanation = false;
      _explanationCountdown = 5;
    });

    _loadQuizQuestions(quiz['id']);
    _updateProgress();
  }

  void _goBackToCategorySelection() {
    setState(() {
      _showCategorySelection = true;
      _currentCategory = null;
      _currentTemplateId = null;
      _currentQuizTemplate = null;
      _currentQuestions.clear();
      _answers.clear();
      _showExplanation = false;
      _explanationCountdown = 5;
    });
    _timerAnimationController.reset();
  }

  void _showQuizComplete() {
    int correctAnswers = 0;

    if (_currentTemplateId == null) return;

    for (int i = 0; i < _currentQuestions.length; i++) {
      final key = '${_currentTemplateId}_$i';
      if (_answers.containsKey(key)) {
        final question = _currentQuestions[i];
        final userAnswer = _answers[key];
        final correctAnswer = question['correct_answer'];
        final selectedOption = question['options'][userAnswer];

        if (selectedOption == correctAnswer) {
          correctAnswers++;
        }
      }
    }

    final percentage = (_currentQuestions.isNotEmpty)
        ? (correctAnswers / _currentQuestions.length * 100).round()
        : 0;

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
                size: 28,
              ),
              SizedBox(width: 2.w),
              Expanded(child: Text('Quiz Completato!')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: percentage >= 80
                      ? Colors.green.withAlpha(26)
                      : percentage >= 60
                          ? Colors.blue.withAlpha(26)
                          : Colors.orange.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '$percentage%',
                      style: GoogleFonts.inter(
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
                      'Punteggio',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '$correctAnswers/${_currentQuestions.length} corrette',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _getRecommendation(percentage),
                style: GoogleFonts.inter(fontSize: 14.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetCurrentQuiz();
              },
              child: const Text('Riprova'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _goBackToCategorySelection();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Altri Quiz'),
            ),
          ],
        );
      },
    );
  }

  String _getRecommendation(int percentage) {
    if (percentage >= 80) {
      return 'Eccellente! Hai una solida comprensione di questo argomento.';
    } else if (percentage >= 60) {
      return 'Buon lavoro! Potresti rivedere alcuni concetti per migliorare.';
    } else {
      return 'Ti consigliamo di studiare di più questo argomento e consultare il tuo team medico.';
    }
  }

  void _resetCurrentQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _answers.clear();
      _showExplanation = false;
      _explanationCountdown = 5;
      _updateProgress();
    });
    _timerAnimationController.reset();
  }

  bool _isQuizCompleted(String quizId) {
    for (int i = 0; i < _currentQuestions.length; i++) {
      final key = '${quizId}_$i';
      if (!_answers.containsKey(key)) {
        return false;
      }
    }
    return _currentQuestions.isNotEmpty;
  }

  double _getQuizProgress(String quizId) {
    if (_currentQuestions.isEmpty) return 0;

    int answered = 0;
    for (int i = 0; i < _currentQuestions.length; i++) {
      final key = '${quizId}_$i';
      if (_answers.containsKey(key)) {
        answered++;
      }
    }
    return (answered / _currentQuestions.length) * 100;
  }

  // Build explanation section widget
  Widget _buildExplanationSection() {
    if (!_showExplanation ||
        _currentQuestionIndex >= _currentQuestions.length) {
      return SizedBox();
    }

    final currentQuestion = _currentQuestions[_currentQuestionIndex];
    final questionKey = '${_currentTemplateId}_$_currentQuestionIndex';
    final userAnswer = _answers[questionKey];
    final userAnswerText = currentQuestion['options'][userAnswer];
    final correctAnswer = currentQuestion['correct_answer'];
    final explanation = currentQuestion['explanation'];
    final isCorrect = userAnswerText == correctAnswer;

    return Container(
      margin: EdgeInsets.only(top: 2.h),
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
          // Timer header with countdown
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: _currentQuizTemplate!['color'].withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _currentQuizTemplate!['color'].withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _timerAnimation,
                        builder: (context, child) {
                          return CircularProgressIndicator(
                            value: _timerAnimation.value,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _currentQuizTemplate!['color'],
                            ),
                            strokeWidth: 3,
                          );
                        },
                      ),
                      Text(
                        '$_explanationCountdown',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _currentQuizTemplate!['color'],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Prossima domanda in $_explanationCountdown secondi',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: _currentQuizTemplate!['color'],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Answer result
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: isCorrect
                  ? Colors.green.withAlpha(26)
                  : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCorrect
                    ? Colors.green.withAlpha(51)
                    : Colors.red.withAlpha(51),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.error,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      isCorrect ? 'Risposta Corretta!' : 'Risposta Errata',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isCorrect
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  'Tua risposta: $userAnswerText',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCorrect ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
                if (!isCorrect) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Risposta corretta: $correctAnswer',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ),

          SizedBox(height: 2.h),

          // Explanation
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.shade200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Spiegazione:',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  explanation.isNotEmpty
                      ? explanation
                      : 'Spiegazione non disponibile per questa domanda.',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: Text(
            'Quiz Educativi',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_showCategorySelection) {
      return _buildQuizSelectionScreen();
    }

    if (_currentQuizTemplate == null || _currentQuestions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Quiz Educativi',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
        ),
        body: const Center(child: Text('Errore nel caricamento del quiz')),
      );
    }

    final currentQuestion = _currentQuestions[_currentQuestionIndex];
    final questionKey = '${_currentTemplateId}_$_currentQuestionIndex';
    final hasAnswer = _answers.containsKey(questionKey);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quiz Educativi',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBackToCategorySelection,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 4.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _currentQuizTemplate!['color'].withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Progresso: $_overallProgress%',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: _currentQuizTemplate!['color'],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quiz Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _currentQuizTemplate!['color'].withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _currentQuizTemplate!['color'].withAlpha(51),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _currentQuizTemplate!['color'],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _currentQuizTemplate!['icon'],
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentQuizTemplate!['title'],
                                style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: _currentQuizTemplate!['color'],
                                ),
                              ),
                              Text(
                                _currentQuizTemplate!['description'],
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Progress Bar
                  Row(
                    children: [
                      Text(
                        'Domanda ${_currentQuestionIndex + 1} di ${_currentQuestions.length}',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: _currentQuizTemplate!['color'],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${(_progressValue * 100).round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: _currentQuizTemplate!['color'],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  LinearProgressIndicator(
                    value: _progressValue,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _currentQuizTemplate!['color'],
                    ),
                    minHeight: 6,
                  ),
                ],
              ),
            ),

            // Question Area and Explanation
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Question Container
                    Container(
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
                            currentQuestion['question'],
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: currentQuestion['options'].length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 1.h),
                            itemBuilder: (context, index) {
                              final isSelected = _answers[questionKey] == index;
                              return InkWell(
                                onTap: (hasAnswer || _showExplanation)
                                    ? null
                                    : () => _selectAnswer(index),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? _currentQuizTemplate!['color']
                                            .withAlpha(26)
                                        : Colors.grey[50],
                                    border: Border.all(
                                      color: isSelected
                                          ? _currentQuizTemplate!['color']
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? _currentQuizTemplate!['color']
                                              : Colors.transparent,
                                          border: Border.all(
                                            color: isSelected
                                                ? _currentQuizTemplate!['color']
                                                : Colors.grey,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Text(
                                          currentQuestion['options'][index],
                                          style: GoogleFonts.inter(
                                            fontSize: 16.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? _currentQuizTemplate!['color']
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Explanation Section (shown inline after answer selection)
                    _buildExplanationSection(),
                  ],
                ),
              ),
            ),

            // Navigation Buttons
            if (!_showExplanation)
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentQuestionIndex > 0)
                      ElevatedButton.icon(
                        onPressed: _previousQuestion,
                        icon: const Icon(Icons.arrow_back, size: 16),
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
                    if (hasAnswer &&
                        _currentQuestionIndex == _currentQuestions.length - 1)
                      ElevatedButton.icon(
                        onPressed: _showQuizComplete,
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Vedi Risultati'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _currentQuizTemplate!['color'],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSelectionScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Quiz Educativi',
          style: GoogleFonts.inter(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade50, Colors.green.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(Icons.quiz, size: 48, color: Colors.blue.shade700),
                    SizedBox(height: 2.h),
                    Text(
                      'Seleziona un Quiz Educativo',
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'Testa le tue conoscenze nutrizionali e scopri nuove informazioni',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              Text(
                'Quiz Disponibili',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 2.h),

              // Quiz List
              if (_availableQuizzes.isEmpty)
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 4.h),
                      Icon(
                        Icons.quiz_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Nessun quiz disponibile',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _availableQuizzes.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final quiz = _availableQuizzes[index];
                    final isCompleted = _isQuizCompleted(quiz['id']);
                    final progress = _getQuizProgress(quiz['id']);

                    return InkWell(
                      onTap: () => _selectQuiz(quiz),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: quiz['color'].withAlpha(51),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(13),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: quiz['color'],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                quiz['icon'],
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    quiz['title'],
                                    style: GoogleFonts.inter(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                      color: quiz['color'],
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    quiz['description'],
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 1.h),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              quiz['estimatedTime'],
                                              style: GoogleFonts.inter(
                                                fontSize: 11.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 2.w,
                                          vertical: 0.5.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.bar_chart,
                                              size: 12,
                                              color: Colors.grey[600],
                                            ),
                                            SizedBox(width: 1.w),
                                            Text(
                                              quiz['difficulty'],
                                              style: GoogleFonts.inter(
                                                fontSize: 11.sp,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (isCompleted)
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                else
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      value: progress / 100,
                                      backgroundColor: Colors.grey[300],
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        quiz['color'],
                                      ),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  '${progress.round()}%',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isCompleted
                                        ? Colors.green
                                        : quiz['color'],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}