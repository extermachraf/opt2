import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/profile_service.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/tutorial_slide_widget.dart';

class TutorialSystem extends StatefulWidget {
  const TutorialSystem({Key? key}) : super(key: key);

  @override
  State<TutorialSystem> createState() => _TutorialSystemState();
}

class _TutorialSystemState extends State<TutorialSystem>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  int _currentPage = 0;
  final int _totalPages = 12;
  bool _isNavigating = false;

  // Tutorial slides data
  final List<Map<String, dynamic>> _tutorialSlides = [
    {
      'title': 'Benvenuto in NutriVita',
      'description':
          'NutriVita è un\'app dedicata al monitoraggio del tuo stato nutrizionale, uno strumento utile per orientare il tuo percorso nutrizionale prima, durante e dopo le cure.\n\nDi seguito un breve tutorial per imparare a utilizzare la app!',
      'image': null,
      'features': [
        'Monitoraggio completo dello stato nutrizionale',
        'Supporto durante tutto il percorso di cura',
        'Strumento di orientamento nutrizionale personalizzato',
      ],
    },
    {
      'title': 'Progresso di oggi',
      'description':
          'Dalla home della app, puoi tenere monitorato il numero di calorie che hai assunto durante la giornata e confrontarlo con il target prescritto',
      'image': 'assets/images/1.png',
      'features': [
        'Monitoraggio calorie giornaliere',
        'Confronto con target prescritto',
        'Visualizzazione peso attuale',
      ],
    },
    {
      'title': 'Aggiungi pasto',
      'description':
        'Aggiungi pasto ti consente di registrare nel tuo diario nutrizionale tutti i pasti che consumi.',
      'image': 'assets/images/2.png',
      'features': [
        'Aggiungi pasto velocemente',
        'Registra peso istantaneo',
        'Avvia valutazione rapida',
      ],
    },
    {
      'title': 'Registra peso',
      'description':
          'Aggiorna il tuo peso per tenerlo monitorato nel tempo',
      'image': 'assets/images/3.png',
      'features': [
        'Database completo alimenti',
        'Calcolo automatico nutrienti',
        'Porzioni personalizzabili',
      ],
    },
    {
      'title': 'Visualizza report',
      'description':
          'Visualizza il riassunto nutrizionale completo dei tuoi pasti. Genera report settimanali dettagliati con calorie totali, distribuzione macronutrienti e statistiche per condividerli con il tuo professionista medico.',
      'image': 'assets/images/4.png',
      'features': [
        'Questionari validati scientificamente',
        'Valutazione stato nutrizionale',
        'Monitoraggio qualità di vita',
      ],
    },
    {
      'title': 'Ricette',
      'description':
          'Consulta una raccolta di ricette a cui attingere per verificarne il contenuto nutrizionale',
      'image': 'assets/images/5.png',
      'features': [
        'Contenuti educativi certificati',
        'Quiz interattivi sulla nutrizione',
        'Materiale formativo sulle terapie',
      ],
    },
    {
      'title': 'Questionari',
      'description':
          'Esegui i questionari di valutazione preliminare del tuo stato nutrizionale e della qualità di vita per intercettare potenziali segnali da manifestare al professionista medico.',
      'image': 'assets/images/6.png',
      'features': [
        'Storico completo pasti',
        'Analisi tendenze alimentari',
        'Filtri per periodo',
      ],
    },
    {
      'title': 'Approfondimenti',
      'description':
          'Accedi al materiale formativo sulla nutrizione prima e durante le terapie e mettiti alla prova con interessanti quiz',
      'image': 'assets/images/7.png',
      'features': [
        'Raccolta completa di ricette',
        'Contenuto nutrizionale verificato',
        'Filtri per esigenze dietetiche',
      ],
    },
    {
      'title': 'Aggiungi pasto',
      'description':
          'Inserisci nel diario nutrizionale il pasto che hai consumato:\nSeleziona quale tipo di pasto, la data, l\'ora e cerca i cibi nel database nutrizionale',
      'image': 'assets/images/8.png',
      'features': [
        'Report settimanali automatici',
        'Grafici dettagliati',
        'Esportazione dati',
      ],
    },
    {
      'title': 'Foto dei pasti',
      'description':
          'Aggiungi una foto del pasto per arricchire il tuo diario nutrizionale. Puoi scattare una foto direttamente o selezionarla dalla galleria, oltre ad aggiungere note aggiuntive correlate al trattamento.',
      'image': 'assets/images/9.png',
      'features': [
        'Selezione tipo di pasto (Colazione, Pranzo, Cena, Spuntino)',
        'Impostazione data e orario del pasto',
        'Ricerca cibi nel database nutrizionale completo',
      ],
    },
    {
      'title': 'Diario nutrizionale',
      'description':
          'Consulta il tuo diario nutrizionale per visualizzare che cosa hai consumato nei giorni precedenti',
      'image': 'assets/images/10.png',
      'features': [
        'Cattura foto dei pasti con fotocamera',
        'Selezione immagini dalla galleria',
        'Note aggiuntive correlate al trattamento',
      ],
    },
    {
      'title': 'Report nutrizionale',
      'description':
          'NutriVita genera anche un report delle assunzioni settimanali o mensili dei nutrienti principali, che puoi condividere con il tuo professionista medico tramite email o app di messaggistica.',
      'image': 'assets/images/11.png',
      'features': [
        'Storico completo dei pasti',
        'Dettagli nutrizionali per giornata',
        'Visualizzazione calorie e macronutrienti',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _progressAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isNavigating) return;

    if (_currentPage < _totalPages - 1) {
      setState(() {
        _isNavigating = true;
      });

      HapticFeedback.lightImpact();
      _pageController
          .nextPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            setState(() {
              _isNavigating = false;
            });
          });
    } else {
      _completeTutorial();
    }
  }

  void _previousPage() {
    if (_isNavigating) return;

    if (_currentPage > 0) {
      setState(() {
        _isNavigating = true;
      });

      HapticFeedback.lightImpact();
      _pageController
          .previousPage(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
          )
          .then((_) {
            setState(() {
              _isNavigating = false;
            });
          });
    }
  }

  void _skipTutorial() async {
    if (_isNavigating) return;

    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final shouldSkip = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3.w),
          ),
          title: Text(
            'Saltare il tutorial?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Puoi sempre rivedere queste informazioni nelle impostazioni.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continua tutorial',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              child: Text('Salta', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (shouldSkip == true) {
      _completeTutorial();
    }
  }

  void _completeTutorial() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      // Mark tutorial as completed in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);

      HapticFeedback.heavyImpact();

      // Check if screening is completed
      if (mounted) {
        print('🔍 Tutorial complete - checking screening status...');
        try {
          final screeningCompleted = await ProfileService.instance.isScreeningCompleted();
          print('🔍 Screening completed: $screeningCompleted');
          
          if (screeningCompleted) {
            // Navigate to dashboard
            print('✅ Navigating to dashboard');
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          } else {
            // Navigate to screening flow
            print('📋 Navigating to screening flow');
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/screening',
              (route) => false,
            );
          }
        } catch (screeningError) {
          print('❌ Error checking screening status: $screeningError');
          // Fallback to dashboard if screening check fails
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('❌ Error completing tutorial: $e');
      setState(() {
        _isNavigating = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel completamento tutorial. Riprova.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.loginBgDark,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Skip Button
            _buildHeader(),

            // Main Content - PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                  HapticFeedback.selectionClick();
                },
                itemCount: _totalPages,
                itemBuilder: (context, index) {
                  return TutorialSlideWidget(
                    title: _tutorialSlides[index]['title'],
                    description: _tutorialSlides[index]['description'],
                    image: _tutorialSlides[index]['image'],
                    features: List<String>.from(
                      _tutorialSlides[index]['features'],
                    ),
                    currentPage: index + 1,
                    totalPages: _totalPages,
                  );
                },
              ),
            ),

            // Bottom Navigation
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tutorial Title
          Text(
            'Tutorial',
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),

          // Skip Button
          TextButton(
            onPressed: _isNavigating ? null : _skipTutorial,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2.w),
              ),
            ),
            child: Text(
              'Salta',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Progress Indicator
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return TutorialProgressIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _totalPages,
                animationValue: _progressAnimation.value,
              );
            },
          ),

          SizedBox(height: 4.h),

          // Navigation Buttons
          Row(
            children: [
              // Previous Button (only show if not on first page)
              if (_currentPage > 0) ...[
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _isNavigating ? null : _previousPage,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'arrow_back',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 4.w,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Indietro',
                          style: TextStyle(
                            color: AppTheme.lightTheme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
              ],

              // Next/Finish Button
              Expanded(
                flex: _currentPage > 0 ? 2 : 1,
                child: ElevatedButton(
                  onPressed: _isNavigating ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 3.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.w),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isNavigating
                          ? SizedBox(
                            height: 5.w,
                            width: 5.w,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _totalPages - 1
                                    ? 'Inizia con NutriVita!'
                                    : 'Avanti',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14.sp,
                                ),
                              ),
                              if (_currentPage < _totalPages - 1) ...[
                                SizedBox(width: 2.w),
                                CustomIconWidget(
                                  iconName: 'arrow_forward',
                                  color: Colors.white,
                                  size: 4.w,
                                ),
                              ] else ...[
                                SizedBox(width: 2.w),
                                Icon(
                                  Icons.celebration,
                                  color: Colors.white,
                                  size: 5.w,
                                ),
                              ],
                            ],
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
