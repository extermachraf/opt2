import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/meal_diary_service.dart';
import '../dashboard/widgets/quick_action_sheet_widget.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/date_picker_widget.dart';
import './widgets/meal_timeline_widget.dart';

class MealDiary extends StatefulWidget {
  const MealDiary({Key? key}) : super(key: key);

  @override
  State<MealDiary> createState() => _MealDiaryState();
}

class _MealDiaryState extends State<MealDiary> with TickerProviderStateMixin {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  XFile? _capturedImage; // ignore: unused_field - used for camera functionality
  int _selectedNavIndex = 1; // Meal Diary is index 1

  // Real user data from Supabase
  List<Map<String, dynamic>> _userMeals = [];
  bool _hasUserMeals = false;

  @override
  void initState() {
    super.initState();
    _loadUserMeals();

    // Listen for navigation to refresh meals when returning from add meal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        _handleArguments(args);
      }
    });
  }

  void _handleArguments(dynamic args) {
    if (args is Map<String, dynamic>) {
      // Handle return from add meal with specific date
      if (args.containsKey('selected_date')) {
        final returnedDate = args['selected_date'] as DateTime?;
        if (returnedDate != null) {
          setState(() {
            _selectedDate = returnedDate;
          });
          _loadUserMeals();
        }
      }

      // Handle meal added confirmation
      if (args.containsKey('meal_added')) {
        _refreshData();
      }
    }
  }

  Future<void> _loadUserMeals() async {
    if (!AuthService.instance.isAuthenticated) {
      setState(() {
        _userMeals = [];
        _hasUserMeals = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final meals = await MealDiaryService.instance.getUserMeals(
        specificDate: _selectedDate,
      );

      final hasAnyMeals = await MealDiaryService.instance.hasUserMeals();

      setState(() {
        _userMeals = meals;
        _hasUserMeals = hasAnyMeals;
        _isLoading = false;
      });
    } catch (error) {
      print('Error loading meals: $error');
      setState(() {
        _userMeals = [];
        _hasUserMeals = false;
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredMeals {
    // Sort by meal time
    final filtered = List<Map<String, dynamic>>.from(_userMeals);
    filtered.sort((a, b) {
      final timeA = a['time'] ?? '00:00';
      final timeB = b['time'] ?? '00:00';
      return timeA.compareTo(timeB);
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Container(
        decoration: AppTheme.oceanGradientBackground,
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.seaTop,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  // Ocean-themed header
                  _buildOceanHeader(),
                  SizedBox(height: 2.h),
                  // Date picker card
                  DatePickerWidget(
                    selectedDate: _selectedDate,
                    onDateChanged: _onDateChanged,
                    onTodayPressed: _onTodayPressed,
                  ),
                  SizedBox(height: 2.h),
                  // Macro summary card
                  _buildMacroSummaryCard(),
                  SizedBox(height: 2.h),
                  // Meal content
                  _isLoading ? _buildLoadingState() : _buildMealContent(),
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

  Widget _buildOceanHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            // Navigate to home page (dashboard) instead of previous page
            Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          },
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CustomIconWidget(
              iconName: 'arrow_back',
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            'Diario Pasti',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GestureDetector(
          onTap: _showMealSummary,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CustomIconWidget(
              iconName: 'analytics',
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        SizedBox(width: 2.w),
        GestureDetector(
          onTap: _showSettings,
          child: Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const CustomIconWidget(
              iconName: 'more_vert',
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroSummaryCard() {
    // Calculate totals from today's meals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final meal in _userMeals) {
      totalCalories += (meal['calories'] as num?)?.toDouble() ?? 0;
      totalProtein += (meal['protein'] as num?)?.toDouble() ?? 0;
      totalCarbs += (meal['carbs'] as num?)?.toDouble() ?? 0;
      totalFat += (meal['fat'] as num?)?.toDouble() ?? 0;
    }

    final totalMacros = totalProtein + totalCarbs + totalFat;
    final proteinPercent = totalMacros > 0 ? (totalProtein / totalMacros * 100).round() : 0;
    final carbsPercent = totalMacros > 0 ? (totalCarbs / totalMacros * 100).round() : 0;
    final fatPercent = totalMacros > 0 ? (totalFat / totalMacros * 100).round() : 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ripartizione Macro',
                style: TextStyle(
                  fontSize: 17.sp, // Increased from 14.sp for better readability
                  fontWeight: FontWeight.w600,
                  color: AppTheme.seaDeep,
                ),
              ),
              Text(
                '${totalCalories.toInt()} kcal',
                style: TextStyle(
                  fontSize: 14.sp, // Increased from 12.sp for better readability
                  fontWeight: FontWeight.w500,
                  color: AppTheme.seaMid,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Macro bar
          Container(
            height: 1.2.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Row(
                children: [
                  if (proteinPercent > 0)
                    Expanded(
                      flex: proteinPercent,
                      child: Container(color: AppTheme.seaMid),
                    ),
                  if (carbsPercent > 0)
                    Expanded(
                      flex: carbsPercent,
                      child: Container(color: const Color(0xFFFFC107)),
                    ),
                  if (fatPercent > 0)
                    Expanded(
                      flex: fatPercent,
                      child: Container(color: const Color(0xFF4CAF50)),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1.5.h),
          // Macro labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroLabel('$proteinPercent% P', AppTheme.seaMid),
              _buildMacroLabel('$carbsPercent% C', const Color(0xFFFFC107)),
              _buildMacroLabel('$fatPercent% G', const Color(0xFF4CAF50)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLabel(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 13.sp, // Increased from 11.sp for better readability
            fontWeight: FontWeight.w500,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMealContent() {
    if (!AuthService.instance.isAuthenticated) {
      return _buildAuthRequiredState();
    }

    if (!_hasUserMeals) {
      return _buildEmptyFirstTimeState();
    }

    if (_filteredMeals.isEmpty) {
      return _buildEmptyDateState();
    }

    return _buildMealTimeline();
  }

  Widget _buildAuthRequiredState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppTheme.iconBubbleDecoration,
            child: const Center(
              child: CustomIconWidget(
                iconName: 'login',
                color: AppTheme.seaDeep,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Accedi per visualizzare il tuo diario pasti',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.seaDeep,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Tieni traccia dei tuoi pasti quotidiani',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.loginScreen),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Accedi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFirstTimeState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppTheme.iconBubbleDecoration,
            child: const Center(
              child: CustomIconWidget(
                iconName: 'restaurant_menu',
                color: AppTheme.seaDeep,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Benvenuto nel tuo Diario Pasti!',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.seaDeep,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Inizia a tracciare i tuoi pasti per monitorare la tua alimentazione.',
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          ElevatedButton.icon(
            onPressed: _onAddMeal,
            icon: const CustomIconWidget(
              iconName: 'add',
              color: Colors.white,
              size: 20,
            ),
            label: const Text('Aggiungi il tuo primo pasto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDateState() {
    final isToday = _selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: AppTheme.iconBubbleDecoration,
            child: const Center(
              child: CustomIconWidget(
                iconName: 'event_available',
                color: AppTheme.seaDeep,
                size: 32,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            isToday ? 'Nessun pasto registrato oggi' : 'Nessun pasto in questa data',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.seaDeep,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            isToday
                ? 'Inizia a tracciare i tuoi pasti di oggi'
                : 'Cambia data o aggiungi un pasto',
            style: TextStyle(
              fontSize: 14.sp, // Increased from 12.sp for better readability
              color: AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 3.h),
          if (isToday) ...[
            ElevatedButton.icon(
              onPressed: _onAddMeal,
              icon: const CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 20,
              ),
              label: const Text('Aggiungi pasto'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.seaMid,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: _onTodayPressed,
              child: Text(
                'Vai a oggi',
                style: TextStyle(
                  color: AppTheme.seaMid,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(6.w),
      decoration: AppTheme.menuCardDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.seaMid),
          SizedBox(height: 2.h),
          Text(
            'Caricamento pasti...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimeline() {
    return MealTimelineWidget(
      meals: _filteredMeals,
      onMealTap: _onMealTap,
      onDuplicateMeal: _onDuplicateMeal,
      onShareMeal: _onShareMeal,
      onAddToFavorites: _onAddToFavorites,
      onDeleteMeal: _onDeleteMeal,
      onAddMeal: _onAddMeal,
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
    final isActive = _selectedNavIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: isActive ? AppTheme.seaMid : const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => QuickActionSheetWidget(
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
          _openCamera();
        },
      ),
    );
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        // Already on Meal Diary
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

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _loadUserMeals();
  }

  void _onTodayPressed() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadUserMeals();
  }

  Future<void> _refreshData() async {
    await _loadUserMeals();

    // Show confirmation if we just added a meal
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('meal_added')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Pasto aggiunto al diario!',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      });
    }
  }

  void _onMealTap(Map<String, dynamic> meal) {
    // Refresh the meal data after potential updates
    _loadUserMeals();
  }

  void _onDuplicateMeal(Map<String, dynamic> meal) {
    // TODO: Implement meal duplication using MealDiaryService
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Funzione in sviluppo'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onShareMeal(Map<String, dynamic> meal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pasto condiviso con il medico'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  void _onAddToFavorites(Map<String, dynamic> meal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pasto aggiunto ai preferiti'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  Future<void> _onDeleteMeal(Map<String, dynamic> meal) async {
    try {
      // Delete the meal entry
      await MealDiaryService.instance.deleteMealEntry(meal['id']);

      // Reload meals to update the list and recalculate calories
      await _loadUserMeals();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Pasto cancellato con successo'),
            ],
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nella cancellazione: $error'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _onAddMeal() {
    Navigator.pushNamed(
      context,
      AppRoutes.addMeal,
      arguments: {'selected_date': _selectedDate}, // Pass current selected date
    );
  }

  void _openCamera() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CameraOverlayWidget(
          onPhotoTaken: _onPhotoTaken,
          onClose: () => Navigator.of(context).pop(),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _onPhotoTaken(XFile photo) {
    setState(() {
      _capturedImage = photo;
    });

    Navigator.of(context).pop();
    Navigator.pushNamed(
      context,
      AppRoutes.addMeal,
      arguments: {
        'photo': photo,
        'timestamp': DateTime.now(),
        'selected_date': _selectedDate, // Pass current selected date
      },
    );
  }

  void _showMealSummary() async {
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    try {
      final summary = await MealDiaryService.instance.getNutritionalSummary(
        specificDate: _selectedDate,
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Riassunto giornaliero',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSummaryRow(
                'Calorie totali',
                '${summary['total_calories']?.toStringAsFixed(0) ?? '0'} kcal',
              ),
              _buildSummaryRow(
                'Proteine',
                '${summary['total_protein']?.toStringAsFixed(1) ?? '0'}g',
              ),
              _buildSummaryRow(
                'Carboidrati',
                '${summary['total_carbs']?.toStringAsFixed(1) ?? '0'}g',
              ),
              _buildSummaryRow(
                'Grassi',
                '${summary['total_fat']?.toStringAsFixed(1) ?? '0'}g',
              ),
              _buildSummaryRow(
                'Fibre',
                '${summary['total_fiber']?.toStringAsFixed(1) ?? '0'}g',
              ),
              _buildSummaryRow(
                'Pasti registrati',
                '${summary['meal_count'] ?? 0}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Chiudi',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, AppRoutes.reports);
              },
              child: const Text('Visualizza report'),
            ),
          ],
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nel caricamento del riassunto: $error')),
      );
    }
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Accesso richiesto'),
        content: Text(
          'Devi effettuare l\'accesso per utilizzare questa funzione.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRoutes.loginScreen);
            },
            child: Text('Accedi'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTheme.lightTheme.textTheme.bodyMedium),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5.w)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 1.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(0.5.h),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Opzioni diario pasti',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            _buildSettingsOption('Esporta dati', 'download', () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRoutes.reports);
            }),
            _buildSettingsOption('Sincronizza con medico', 'sync', () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sincronizzazione con il medico...'),
                ),
              );
            }),
            _buildSettingsOption('Impostazioni', 'settings', () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, AppRoutes.profileSettings);
            }),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 6.w,
      ),
      title: Text(title, style: AppTheme.lightTheme.textTheme.bodyLarge),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 5.w,
      ),
      onTap: onTap,
    );
  }
}
