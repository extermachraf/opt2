import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/medical_service.dart';
import '../../services/dashboard_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_badge_widget.dart';
import './widgets/body_card_widget.dart';
import './widgets/kpi_card_widget.dart';
import './widgets/meal_card_widget.dart';
import './widgets/quick_action_sheet_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with RouteAware {
  final _authService = AuthService.instance;
  final _medicalService = MedicalService.instance;
  final _dashboardService = DashboardService.instance;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _medicalProfile;
  Map<String, dynamic>? _dashboardData;
  Map<String, dynamic>? _dashboardConfig;
  List<dynamic> _dashboardWidgets = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    // Unsubscribe from route observer
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      AppRoutes.routeObserver.unsubscribe(this);
    }
    _dashboardService.unsubscribeFromDataChanges();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route observer to detect when screen becomes visible
    final modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      AppRoutes.routeObserver.subscribe(this, modalRoute);
    }
  }

  // FIXED: RouteAware callbacks - reload data when screen becomes visible
  @override
  void didPopNext() {
    // Called when a route has been popped and this route is now visible
    print('Dashboard became visible after pop - reloading data');
    _loadDashboardData();
  }

  @override
  void didPush() {
    // Called when the current route has been pushed
    print('Dashboard pushed');
  }

  @override
  void didPop() {
    // Called when the current route has been popped
    print('Dashboard popped');
  }

  @override
  void didPushNext() {
    // Called when a new route has been pushed on top of this route
    print('Dashboard covered by new route');
  }

  void _setupRealtimeSubscription() {
    _dashboardService.subscribeToDataChanges((updatedData) {
      if (mounted) {
        setState(() {
          _dashboardData = updatedData;
        });
        print(
          'Dashboard UI updated with new data: ${updatedData['nutrition_summary']}',
        );
      }
    });
  }

  Future<void> _loadDashboardData() async {
    if (!_authService.isAuthenticated) {
      // Defer navigation to avoid calling during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load all dashboard data from database
      final futures = await Future.wait([
        _authService.getCurrentUserProfile(),
        _medicalService.getMedicalProfile(),
        _dashboardService.getDashboardData(),
        _dashboardService.getDashboardConfiguration(),
        _dashboardService.getDashboardWidgets(),
      ]);

      _userProfile = futures[0] as Map<String, dynamic>?;
      _medicalProfile = futures[1] as Map<String, dynamic>?;
      _dashboardData = futures[2] as Map<String, dynamic>;
      _dashboardConfig = futures[3] as Map<String, dynamic>?;
      _dashboardWidgets = futures[4] as List<dynamic>;
    } catch (error) {
      _errorMessage = error.toString().replaceAll('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    // Show confirmation dialog first
    final bool? shouldSignOut = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const CustomIconWidget(
                iconName: 'logout',
                color: Color(0xFFFF9800),
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Conferma logout',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Text(
            'Sei sicuro di voler uscire dall\'applicazione?',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Annulla',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5722),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              ),
              child: Text(
                'Esci',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    // Only proceed with logout if user confirmed
    if (shouldSignOut == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.loginScreen);
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Errore durante il logout: $error')),
          );
        }
      }
    }
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => QuickActionSheetWidget(
            onLogMeal: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.addMeal);
            },
            onAddRecipe: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.recipeManagement);
            },
            onTakePhoto: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.addMeal,
                arguments: {'autoOpenCamera': true},
              );
            },
          ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - stay on current screen
        break;
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealDiary);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.addMeal);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  // save here
  List<BottomNavigationBarItem> _getBottomNavItems() {
    // Simplified navigation - all users are patients now
    return const [
      BottomNavigationBarItem(
        icon: CustomIconWidget(iconName: 'dashboard', size: 24),
        activeIcon: CustomIconWidget(
          iconName: 'dashboard',
          size: 24,
          color: Color(0xFF4CAF50),
        ),
        label: 'Dashboard',
      ),
      BottomNavigationBarItem(
        icon: CustomIconWidget(iconName: 'book', size: 24),
        activeIcon: CustomIconWidget(
          iconName: 'book',
          size: 24,
          color: Color(0xFF4CAF50),
        ),
        label: 'Diario pasti',
      ),
      BottomNavigationBarItem(
        icon: CustomIconWidget(iconName: 'add_circle_outline', size: 24),
        activeIcon: CustomIconWidget(
          iconName: 'add_circle_outline',
          size: 24,
          color: Color(0xFF4CAF50),
        ),
        label: 'Aggiungi pasto',
      ),
      BottomNavigationBarItem(
        icon: CustomIconWidget(iconName: 'bar_chart', size: 24),
        activeIcon: CustomIconWidget(
          iconName: 'bar_chart',
          size: 24,
          color: Color(0xFF4CAF50),
        ),
        label: 'Report',
      ),
      BottomNavigationBarItem(
        icon: CustomIconWidget(iconName: 'person', size: 24),
        activeIcon: CustomIconWidget(
          iconName: 'person',
          size: 24,
          color: Color(0xFF4CAF50),
        ),
        label: 'Profilo',
      ),
    ];
  }

  void _onRoleSpecificNavTap(int index) {
    // Simplified navigation handler - all users have same navigation
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break; // Dashboard - stay on current screen
      case 1:
        Navigator.pushNamed(context, AppRoutes.mealDiary);
        break;
      case 2:
        Navigator.pushNamed(context, AppRoutes.addMeal);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: AppTheme.oceanGradientBackground,
        child: SafeArea(
          bottom: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )
              : _errorMessage != null
                  ? _buildErrorState()
                  : RefreshIndicator(
                      onRefresh: _loadDashboardData,
                      color: AppTheme.seaTop,
                      backgroundColor: Colors.white,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 2.h),
                            // Header with logo and profile
                            _buildOceanHeader(),
                            SizedBox(height: 3.h),

                            // Hero Card with calories
                            _buildHeroCard(),
                            SizedBox(height: 3.h),

                            // Menu Grid Section
                            _buildMenuSection(),
                            SizedBox(height: 3.h),

                            // Recent Meals Section
                            _buildRecentMealsSectionStyled(),
                            SizedBox(height: 3.h),

                            // Achievements Section
                            _buildAchievementsSectionStyled(),

                            // Bottom padding for nav bar
                            SizedBox(height: 14.h),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
      bottomNavigationBar: _buildOceanBottomNav(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: EdgeInsets.all(6.w),
        padding: EdgeInsets.all(6.w),
        decoration: AppTheme.heroCardDecoration,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomIconWidget(
              iconName: 'error_outline',
              color: AppTheme.errorLight,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Errore nel caricamento',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textMuted,
              ),
            ),
            SizedBox(height: 3.h),
            ElevatedButton(
              onPressed: _loadDashboardData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaMid,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
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

  Widget _buildOceanHeader() {
    final userName = (_userProfile?['full_name'] as String?)?.isNotEmpty == true
        ? (_userProfile!['full_name'] as String)
        : 'Utente';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Row(
          children: [
            // Text(
            //   '🍊',
            //   style: TextStyle(fontSize: 20.sp),
            // ),
            // SizedBox(width: 2.w),
            // Text(
            //   'NutriVita',
            //   style: TextStyle(
            //     fontSize: 20.sp,
            //     fontWeight: FontWeight.w800,
            //     color: Colors.white,
            //     letterSpacing: 0.5,
            //     shadows: [
            //       Shadow(
            //         color: Colors.black.withValues(alpha: 0.2),
            //         offset: const Offset(0, 2),
            //         blurRadius: 5,
            //       ),
            //     ],
            //   ),
            // ),
            Image.asset(
              'assets/images/dashboard.png',
              height: 35,
              fit: BoxFit.fitHeight,
            )
          ],
        ),
        // Profile Icon
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profileSettings),
          child: Container(
            width: 44,
            height: 44,
            decoration: AppTheme.profileIconDecoration,
            child: Center(
              child: Text(
                userInitial,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // OCEAN BLUE STYLED WIDGETS
  // ============================================

  Widget _buildHeroCard() {
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final todayCalories = (nutritionSummary['total_calories'] ?? 0).toDouble();
    
    // FIXED: Priority logic for caloric intake
    // Priority 1: Manual entry (daily_caloric_intake)
    // Priority 2: Calculated/target value (target_daily_calories)
    // Priority 3: Fallback (null - will show "-- kcal")
    final manualCalories = _medicalProfile?['daily_caloric_intake'];
    final targetCaloriesFromProfile = _medicalProfile?['target_daily_calories'];
    
    final double? targetCalories = manualCalories != null
        ? (manualCalories as num).toDouble()
        : targetCaloriesFromProfile != null
            ? (targetCaloriesFromProfile as num).toDouble()
            : null;
    
    final remainingCalories = targetCalories != null
        ? (targetCalories - todayCalories).clamp(0, targetCalories)
        : 0.0;
    final progress = targetCalories != null && targetCalories > 0
        ? (todayCalories / targetCalories).clamp(0.0, 1.0)
        : 0.0;

    // Get weight data
    final weightProgress = _dashboardData?['weight_progress'] ?? [];
    final currentWeight = weightProgress.isNotEmpty
        ? (weightProgress.first['weight_kg'] ??
                weightProgress.first['weight'] ??
                0)
            .toDouble()
        : _medicalProfile?['current_weight_kg']?.toDouble() ?? 75.5;

    // Calculate weight change (mock for now, could be from previous entry)
    final weightChange = weightProgress.length > 1
        ? currentWeight -
            (weightProgress[1]['weight_kg'] ?? weightProgress[1]['weight'] ?? currentWeight)
                .toDouble()
        : 0.0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
      decoration: AppTheme.heroCardDecoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Progress Circle
          _buildProgressCircle(progress),
          // Stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Target
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'OBIETTIVO',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: targetCalories != null 
                              ? '${targetCalories.toInt()} '
                              : '-- ',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.seaDeep,
                          ),
                        ),
                        TextSpan(
                          text: 'kcal',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.normal,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              // Current Weight
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PESO ATTUALE',
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textMuted,
                      letterSpacing: 1,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentWeight.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.seaDeep,
                        ),
                      ),
                      if (weightChange != 0) ...[
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: AppTheme.changeBadgeDecoration,
                          child: Text(
                            '${weightChange < 0 ? '▼' : '▲'} ${weightChange.abs().toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00695C),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(double progress) {
    // Calculate percentage - show 100% without decimals to prevent overflow
    final percentValue = progress * 100;
    final percentage = percentValue >= 100
        ? percentValue.toStringAsFixed(0)
        : percentValue.toStringAsFixed(1);

    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          startAngle: -1.5708, // -90 degrees in radians
          endAngle: 4.7124,   // 270 degrees in radians
          colors: [
            const Color(0xFF00BCD4),
            const Color(0xFF00BCD4),
            const Color(0xFFE0F7FA),
            const Color(0xFFE0F7FA),
          ],
          stops: [0.0, progress, progress, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: percentage,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          height: 1.0,
                        ),
                      ),
                      TextSpan(
                        text: '%',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'RAGGIUNTO',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textLabel,
                    letterSpacing: 1,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MENU PRINCIPALE',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 2.h),
        // Grid of menu cards - matching HTML icons exactly
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 2.2,
          children: [
            _buildMenuCard('Pasto', 'add', () {
              Navigator.pushNamed(context, AppRoutes.addMeal);
            }),
            _buildMenuCard('Peso', 'scale', () {
              Navigator.pushNamed(context, AppRoutes.bodyMetrics);
            }),
            _buildMenuCard('Report', 'bar_chart', () {
              Navigator.pushNamed(context, AppRoutes.reports);
            }),
            _buildMenuCard('Ricette', 'menu_book', () {
              Navigator.pushNamed(context, AppRoutes.recipeManagement);
            }),
            _buildMenuCard('Questionari', 'assignment', () {
              Navigator.pushNamed(context, AppRoutes.assessmentScreen);
            }),
            _buildMenuCard('Scopri', 'biotech', () {
              Navigator.pushNamed(context, AppRoutes.patientEducation);
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuCard(String title, String iconName, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        _dashboardService.trackDashboardInteraction(
          widgetId: 'menu_$iconName',
          interactionType: 'click',
          interactionData: {'action': title},
        );
        onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: AppTheme.menuCardDecoration,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: AppTheme.iconBubbleDecoration,
              child: Center(
                child: CustomIconWidget(
                  iconName: iconName,
                  color: const Color(0xFF00838F),
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyStatsSection() {
    final height = _medicalProfile?['height_cm']?.toDouble() ?? 180.0;
    final weightProgress = _dashboardData?['weight_progress'] ?? [];
    final currentWeight = weightProgress.isNotEmpty
        ? (weightProgress.first['weight_kg'] ??
                weightProgress.first['weight'] ??
                0)
            .toDouble()
        : _medicalProfile?['current_weight_kg']?.toDouble() ?? 85.0;

    // Calculate BMI
    double? bmi;
    if (currentWeight > 0 && height > 0) {
      final heightM = height / 100;
      bmi = currentWeight / (heightM * heightM);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'IL TUO CORPO',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 2.h),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.bodyMetrics),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
            decoration: AppTheme.bodyStatsDecoration,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBodyStatItem(
                  '${currentWeight.toStringAsFixed(1)}',
                  'kg',
                  'PESO',
                  false,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: const Color(0xFFECEFF1),
                ),
                _buildBodyStatItem(
                  '${height.toInt()}',
                  'cm',
                  'ALTEZZA',
                  false,
                ),
                Container(
                  height: 50,
                  width: 1,
                  color: const Color(0xFFECEFF1),
                ),
                _buildBodyStatItem(
                  bmi?.toStringAsFixed(1) ?? 'N/A',
                  '',
                  'BMI',
                  true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBodyStatItem(String value, String unit, String label, bool isHighlighted) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? AppTheme.successLight : AppTheme.textDark,
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.normal,
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildOceanBottomNav() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: AppTheme.bottomNavDecoration,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavIcon('home', 0),
              _buildNavIcon('calendar_today', 1),
              SizedBox(width: 15.w), // Space for FAB
              _buildNavIcon('trending_up', 3),
              _buildNavIcon('person', 4),
            ],
          ),
          // Centered FAB
          Positioned(
            top: -35,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showQuickActions,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: AppTheme.fabGradientDecoration,
                  child: const Center(
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(String iconName, int index) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onRoleSpecificNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: isActive ? AppTheme.seaMid : const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  // ============================================
  // STYLED VERSIONS OF ORIGINAL WIDGETS
  // ============================================

  Widget _buildBodyMetricsSectionStyled() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'IL TUO CORPO',
              style: TextStyle(
                fontSize: 15.sp, // Increased from 12.sp for better readability
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 1,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.bodyMetrics),
              child: Text(
                'Visualizza tutto',
                style: TextStyle(
                  fontSize: 15.sp, // Increased from 12.sp for better readability
                  color: AppTheme.accentSand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        // Use the original BodyCardWidget with full functionality
        const BodyCardWidget(),
      ],
    );
  }

  Widget _buildRecentMealsSectionStyled() {
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final todaysMeals = _dashboardData?['todays_meals'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PASTI DI OGGI',
              style: TextStyle(
                fontSize: 14.sp, // Increased from 12.sp for better readability
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.85),
                letterSpacing: 1,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.mealDiary),
              child: Text(
                'Visualizza tutto',
                style: TextStyle(
                  fontSize: 15.sp,
                  color: AppTheme.accentSand,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        // Check if user has meals today
        todaysMeals.isEmpty
            ? _buildEmptyMealsStateStyled(nutritionSummary)
            : _buildMealsListStyled(todaysMeals),
      ],
    );
  }

  Widget _buildEmptyMealsStateStyled(Map<String, dynamic> nutritionSummary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.h),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppTheme.iconBubbleDecoration,
            child: const Center(
              child: CustomIconWidget(
                iconName: 'restaurant',
                color: Color(0xFF00838F),
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Nessun pasto registrato oggi',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Aggiungi i tuoi pasti per tracciare le calorie',
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addMeal),
            icon: const CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'Aggiungi primo pasto',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsListStyled(List<dynamic> meals) {
    return _buildNutritionSummaryCardStyled();
  }

  Widget _buildNutritionSummaryCardStyled() {
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final todaysMeals = _dashboardData?['todays_meals'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riepilogo nutrizionale',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.seaDeep,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7FA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${todaysMeals.length} past${todaysMeals.length != 1 ? 'i' : 'o'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.seaMid,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItemStyled(
                'Calorie',
                '${(nutritionSummary['total_calories'] ?? 0).toInt()}',
                'kcal',
                AppTheme.accentSand,
              ),
              Container(
                height: 4.h,
                width: 1,
                color: const Color(0xFFECEFF1),
              ),
              _buildSummaryItemStyled(
                'Proteine',
                '${(nutritionSummary['total_protein'] ?? 0.0).toStringAsFixed(1)}',
                'g',
                AppTheme.seaMid,
              ),
              Container(
                height: 4.h,
                width: 1,
                color: const Color(0xFFECEFF1),
              ),
              _buildSummaryItemStyled(
                'Carboidrati',
                '${(nutritionSummary['total_carbs'] ?? 0.0).toStringAsFixed(1)}',
                'g',
                AppTheme.seaTop,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItemStyled(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildAchievementsSectionStyled() {
    // Get achievements data from database
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final weightProgress = _dashboardData?['weight_progress'] ?? [];
    final assessmentStatus = _dashboardData?['assessment_status'] ?? {};

    final mealsLogged = (nutritionSummary['meals_logged'] ?? 0).toInt();
    final daysTracked = weightProgress.length;
    final hasProfile = _medicalProfile != null;
    final assessmentRate = (assessmentStatus['completion_rate'] ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RISULTATI',
          style: TextStyle(
            fontSize: 15.sp, // Increased from 12.sp for better readability
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.85),
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 1.h),
        // Build list of visible achievements
        Row(
          children: [
            if (hasProfile)
              Expanded(
                child: AchievementBadgeWidget(
                  achievementData: {
                    'title': 'Profilo completo',
                    'description': 'Profilo medico configurato',
                    'iconName': 'person',
                    'isUnlocked': true,
                    'category': 'milestone',
                  },
                ),
              ),
            if (hasProfile && daysTracked >= 3)
              SizedBox(width: 2.w),
            if (daysTracked >= 3)
              Expanded(
                child: AchievementBadgeWidget(
                  achievementData: {
                    'title': 'Tracker peso',
                    'description': '$daysTracked giorni registrati',
                    'iconName': 'track_changes',
                    'isUnlocked': true,
                    'category': 'consistency',
                  },
                ),
              ),
            // Show placeholder if no achievements
            if (!hasProfile && daysTracked < 3 && mealsLogged == 0 && assessmentRate < 50)
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: AppTheme.menuCardDecoration,
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: AppTheme.iconBubbleDecoration,
                        child: const Center(
                          child: CustomIconWidget(
                            iconName: 'emoji_events',
                            color: Color(0xFF00838F),
                            size: 24,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          'Completa attività per sbloccare badge!',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ============================================
  // LEGACY WIDGETS (kept for compatibility)
  // ============================================

  Widget _buildWelcomeSection() {
    return const SizedBox.shrink(); // No longer used
  }

  Widget _buildKPISection() {
    return const SizedBox.shrink(); // Replaced by _buildHeroCard
  }

  Widget _buildQuickActionsSection() {
    return const SizedBox.shrink(); // Replaced by _buildMenuSection
  }

  Widget _buildBodyMetricsSection() {
    return const SizedBox.shrink(); // Replaced by _buildBodyMetricsSectionStyled
  }

  Widget _buildRecentMealsSection() {
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final todaysMeals = _dashboardData?['todays_meals'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pasti di oggi',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold), // Increased from 18.sp
            ),
            TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, AppRoutes.mealDiary),
              child: Text(
                'Visualizza tutto',
                style: TextStyle(
                  fontSize: 15.sp, // Increased from 14.sp for better readability
                  color: const Color(0xFF4CAF50),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),

        // Check if user has meals today
        todaysMeals.isEmpty
            ? _buildEmptyMealsState(nutritionSummary)
            : _buildMealsList(todaysMeals),
      ],
    );
  }

  Widget _buildEmptyMealsState(Map<String, dynamic> nutritionSummary) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withAlpha(77)),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'restaurant',
            color: Colors.grey[400]!,
            size: 40,
          ),
          SizedBox(height: 1.h),
          Text(
            'Nessun pasto registrato oggi',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Aggiungi i tuoi pasti per tracciare le calorie',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addMeal),
            icon: const CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              'Aggiungi primo pasto',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealsList(List<dynamic> meals) {
    return _buildNutritionSummaryCard();
  }

  Widget _buildNutritionSummaryCard() {
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final todaysMeals = _dashboardData?['todays_meals'] as List<dynamic>? ?? [];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withAlpha(26),
            const Color(0xFF66BB6A).withAlpha(26),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4CAF50).withAlpha(77)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Riepilogo nutrizionale',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4CAF50),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${todaysMeals.length} past${todaysMeals.length != 1 ? 'i' : 'o'}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                'Calorie',
                '${(nutritionSummary['total_calories'] ?? 0).toInt()}',
                'kcal',
                const Color(0xFFFF9800),
              ),
              Container(
                height: 4.h,
                width: 1,
                color: Colors.grey.withAlpha(77),
              ),
              _buildSummaryItem(
                'Proteine',
                '${(nutritionSummary['total_protein'] ?? 0.0).toStringAsFixed(1)}',
                'g',
                const Color(0xFF2196F3),
              ),
              Container(
                height: 4.h,
                width: 1,
                color: Colors.grey.withAlpha(77),
              ),
              _buildSummaryItem(
                'Carboidrati',
                '${(nutritionSummary['total_carbs'] ?? 0.0).toStringAsFixed(1)}',
                'g',
                const Color(0xFF4CAF50),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          '$value$unit',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAchievementsSection() {
    // Get achievements data from database
    final nutritionSummary = _dashboardData?['nutrition_summary'] ?? {};
    final weightProgress = _dashboardData?['weight_progress'] ?? [];
    final assessmentStatus = _dashboardData?['assessment_status'] ?? {};

    final mealsLogged = (nutritionSummary['meals_logged'] ?? 0).toInt();
    final caloriesLogged = (nutritionSummary['total_calories'] ?? 0).toInt();
    final daysTracked = weightProgress.length;
    final hasProfile = _medicalProfile != null;
    final assessmentRate = (assessmentStatus['completion_rate'] ?? 0).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risultati',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 2.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (hasProfile)
                AchievementBadgeWidget(
                  achievementData: {
                    'title': 'Profilo completo',
                    'description': 'Profilo medico configurato',
                    'iconName': 'person',
                    'isUnlocked': true,
                    'category': 'milestone',
                  },
                ),
              if (daysTracked >= 3) ...[
                SizedBox(width: 2.w),
                AchievementBadgeWidget(
                  achievementData: {
                    'title': 'Tracker peso',
                    'description': '$daysTracked giorni registrati',
                    'iconName': 'track_changes',
                    'isUnlocked': true,
                    'category': 'consistency',
                  },
                ),
              ],
              if (assessmentRate >= 50) ...[
                SizedBox(width: 2.w),
                AchievementBadgeWidget(
                  achievementData: {
                    'title': 'Esperto valutazioni',
                    'description': '$assessmentRate% tasso completamento',
                    'iconName': 'quiz',
                    'isUnlocked': true,
                    'category': 'assessment',
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
