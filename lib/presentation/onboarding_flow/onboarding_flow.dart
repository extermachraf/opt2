import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';
import './widgets/privacy_consent_modal.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  int _currentPage = 0;
  bool _showPrivacyModal = false;
  bool _hasAcceptedPrivacy = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Benvenuto in NutriVita",
      "subtitle": "Il tuo compagno di viaggio nutrizionale",
      "description":
          "Scopri come NutriVita può aiutarti a monitorare e migliorare la tua alimentazione con strumenti professionali e supporto specializzato",
      "imageUrl": "assets/images/image-1761822064543.png",
      "logoScreen": true,
      "textOnlyScreen": false,
      "semanticLabel":
          "First onboarding screen showing NutriVita logo with orange fruit icon, Salta button top right, È un'applicazione di text, AIFOM logo, text about working group development, con il supporto non condizionato di text, Fondazione Guido Berlucchi logo, progress dots, Avanti button, and disclaimer text",
    },
    {
      "title": "Traccia il tuo percorso nutrizionale",
      "subtitle": "",
      "description":
          "Nutrivita consente al paziente di mantenere traccia del proprio diario nutrizionale attraverso un esteso database di cibi e ricette",
      "imageUrl":
          "assets/images/page2.png",
      "logoScreen": false,
      "textOnlyScreen": false,
      "semanticLabel":
          "Beautiful healthy food photography showing colorful nutritious meal with fresh vegetables, lean proteins, and balanced portions arranged appealingly on a plate, representing nutritional tracking and healthy eating habits",
    },
    {
      "title": "Valuta il tuo stato nutrizionale",
      "subtitle": "",
      "description":
          "NutriVita offre un ventaglio di strumenti quali sistemi di monitoraggio e questionari per il controllo della condizione nutrizionale del paziente",
      "imageUrl":
          "assets/images/page3.png",
      "logoScreen": false,
      "textOnlyScreen": false,
      "semanticLabel":
          "Healthy foods including eggs, fruits, and vegetables with a yellow measuring tape wrapped around them, representing nutritional assessment and health monitoring",
    },
    {
      "title": "Accedi al materiale informativo",
      "subtitle": "",
      "description":
          "NutriVita permette ai pazienti di accedere a materiale informativo in merito alla nutrizione in oncologia",
      "imageUrl":
          "https://images.unsplash.com/photo-1758874573116-2bc02232eef1?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1332",
      "logoScreen": false,
      "textOnlyScreen": false,
      "semanticLabel":
          "Person reading educational materials about oncology nutrition on digital device with informational content displayed",
    },
    {
      "title": "Il gruppo di lavoro intersocietario in Oncologia:",
      "subtitle": "",
      "description": "• Associazione Italiana di Oncologia Medica (AIOM)\n\n"
          "• Società Italiana di Nutrizione Artificiale e Metabolismo (SINPE)\n\n"
          "• Federazione delle Associazioni di Volontariato in Oncologia (FAVO)\n\n"
          "• Società Italiana di Chirurgia Oncologia (SICO)\n\n"
          "• Associazione Tecnico Scientifica dell’Alimentazione Nutrizione e Dietetica (ASAND)\n\n"
          "• Associazione Italiana di Radioterapia ed Oncologia clinica (AIRO)\n\n"
          "• Federazione Nazionale degli Ordini delle Professioni Infermieristiche (FNOPI) Supporto Nutrizionale in Oncologia\n\n"
          "• AIOM Nurses",
      "imageUrl": "",
      "logoScreen": false,
      "textOnlyScreen": true,
      "showLogo": true,
      "logoAsset": "assets/images/image-1762878202602.png",
      "semanticLabel":
          "Final onboarding screen displaying NutriVita logo at top, followed by intersocietal working group in oncology with bulleted list of participating Italian medical organizations and associations",
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _checkPrivacyConsentStatus();
  }

  Future<void> _checkPrivacyConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasAccepted = prefs.getBool('privacy_consent_accepted') ?? false;
    setState(() {
      _hasAcceptedPrivacy = hasAccepted;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      HapticFeedback.lightImpact();
    } else {
      _handleOnboardingComplete();
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    _handleOnboardingComplete();
  }

  void _handleOnboardingComplete() {
    if (_hasAcceptedPrivacy) {
      _navigateToDashboard();
    } else {
      _showPrivacyConsentModal();
    }
  }

  void _showPrivacyConsentModal() {
    setState(() {
      _showPrivacyModal = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PrivacyConsentModal(
        onAccept: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('privacy_consent_accepted', true);

          setState(() {
            _hasAcceptedPrivacy = true;
          });

          Navigator.of(context).pop();
          _navigateToDashboard();
        },
        onDecline: () {
          Navigator.of(context).pop();
          setState(() {
            _showPrivacyModal = false;
          });
        },
      ),
    );
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.loginBgDark,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: AppTheme.loginDarkBackground,
          child: Stack(
            children: [
              Column(
                children: [
                  // Main content area with PageView - fill more space
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      itemCount: _onboardingData.length,
                      itemBuilder: (context, index) {
                        final data = _onboardingData[index];
                        return OnboardingPageWidget(
                          title: data["title"] as String,
                          subtitle: data["subtitle"] as String,
                          description: data["description"] as String,
                          imageUrl: data["imageUrl"] as String,
                          isLogoScreen: data["logoScreen"] as bool,
                          isTextOnlyScreen: data["textOnlyScreen"] as bool,
                          semanticLabel: data["semanticLabel"] as String,
                          logoAsset: data["logoAsset"] as String?,
                        );
                      },
                    ),
                  ),

                  // Bottom navigation area - Ocean Blue styled
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.loginBgDark,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Page indicators with orange styling
                        PageIndicatorWidget(
                          currentPage: _currentPage,
                          totalPages: _onboardingData.length,
                        ),

                        SizedBox(height: 2.5.h),
                        // Orange "Avanti" button - pill shape with shadow (matching HTML)
                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF9800).withAlpha(77),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF9800), // Orange color from HTML
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              'Avanti',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Skip button positioned at top-right - Ocean Blue styled
              Positioned(
                top: MediaQuery.of(context).padding.top + 1.h,
                right: 4.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(230),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 1.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Salta',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9800),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
