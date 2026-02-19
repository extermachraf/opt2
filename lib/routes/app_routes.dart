import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/onboarding_flow/onboarding_flow.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/tutorial_system/tutorial_system.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/profile_settings/profile_settings.dart';
import '../presentation/dark_mode_settings/dark_mode_settings.dart';
import '../presentation/accessibility_settings/accessibility_settings.dart';
import '../presentation/data_sync_frequency_settings/data_sync_frequency_settings.dart';
import '../presentation/biometric_authentication_settings/biometric_authentication_settings.dart';
import '../presentation/meal_diary/meal_diary.dart';
import '../presentation/add_meal/add_meal.dart';
import '../presentation/body_metrics/body_metrics.dart';
import '../presentation/reports/reports.dart';
import '../presentation/recipe_management/recipe_management.dart';
import '../presentation/recipe_detail/recipe_detail_screen.dart';
import '../presentation/assessment_screen/assessment_screen.dart';
import '../presentation/questionnaire_page/questionnaire_page.dart';
import '../presentation/questionnaire_detail/questionnaire_detail_screen.dart';
import '../presentation/quiz_page/quiz_page.dart';
import '../presentation/patient_education/patient_education.dart';
import '../presentation/app_icon_management/app_icon_management.dart';
import '../presentation/nutrition_database/nutrition_database_screen.dart';
import '../presentation/screening/screening_flow.dart';


class AppRoutes {
  // Route observer for tracking navigation
  static final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  
  // Routes constants
  static const String splashScreen = '/splash_screen';
  static const String onboardingFlow = '/onboarding_flow';
  static const String loginScreen = '/login_screen';
  static const String registrationScreen = '/registration_screen';
  static const String otpVerification = '/otp_verification_screen';
  static const String tutorialSystem = '/tutorial-system';
  static const String dashboard = '/dashboard';
  static const String profileSettings = '/profile-settings';
  static const String darkModeSettings = '/dark-mode-settings';
  static const String accessibilitySettings = '/accessibility-settings';
  static const String dataSyncFrequencySettings =
      '/data-sync-frequency-settings';
  static const String biometricAuthenticationSettings =
      '/biometric-authentication-settings';
  static const String mealDiary = '/meal-diary';
  static const String addMeal = '/add-meal';
  static const String bodyMetrics = '/body_metrics';
  static const String reports = '/reports';
  static const String recipeManagement = '/recipe-management';
  static const String recipeDetail = '/recipe-detail';
  static const String assessmentScreen = '/assessment-screen';
  static const String questionnairePage = '/questionnaire-page';
  static const String questionnaireDetail = '/questionnaire-detail';
  static const String quizPage = '/quiz-page';
  static const String patientEducation = '/patient-education';
  static const String appIconManagement = '/app-icon-management';
  static const String nutritionDatabase = '/nutrition-database';
  static const String screening = '/screening';

  // Routes map
  static Map<String, WidgetBuilder> get routes => {
    splashScreen: (context) => const SplashScreen(),
    onboardingFlow: (context) => const OnboardingFlow(),
    loginScreen: (context) => const LoginScreen(),
    registrationScreen: (context) => const RegistrationScreen(),
    tutorialSystem: (context) => const TutorialSystem(),
    dashboard: (context) => const Dashboard(),
    profileSettings: (context) => const ProfileSettings(),
    darkModeSettings: (context) => const DarkModeSettings(),
    accessibilitySettings: (context) => const AccessibilitySettings(),
    dataSyncFrequencySettings: (context) => const DataSyncFrequencySettings(),
    biometricAuthenticationSettings:
        (context) => const BiometricAuthenticationSettings(),
    mealDiary: (context) => const MealDiary(),
    addMeal: (context) => const AddMeal(),
    bodyMetrics: (context) => const BodyMetrics(),
    reports: (context) => const Reports(),
    recipeManagement: (context) => const RecipeManagement(),
    recipeDetail: (context) => const RecipeDetailScreen(),
    assessmentScreen: (context) => const AssessmentScreen(),
    questionnairePage: (context) => const QuestionnairePage(),
    questionnaireDetail: (context) => const QuestionnaireDetailScreen(),
    quizPage: (context) => const QuizPage(),
    patientEducation: (context) => const PatientEducation(),
    appIconManagement: (context) => const AppIconManagement(),
    nutritionDatabase: (context) => const NutritionDatabaseScreen(),
    screening: (context) => const ScreeningFlow(),
  };
}
