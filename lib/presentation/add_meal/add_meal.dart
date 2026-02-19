import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/meal_diary_service.dart';
import '../../services/profile_service.dart';
import '../../services/recipe_service.dart';
import '../../widgets/custom_date_picker_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/food_search_widget.dart';
import './widgets/meal_type_selector_widget.dart';
import './widgets/notes_section_widget.dart';
import './widgets/nutrition_summary_widget.dart';

class AddMeal extends StatefulWidget {
  const AddMeal({Key? key}) : super(key: key);

  @override
  State<AddMeal> createState() => _AddMealState();
}

class _AddMealState extends State<AddMeal> {
  String _selectedMealType = 'breakfast';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _selectedDate = DateTime.now(); // Add date selection
  XFile? _capturedImage;
  List<Map<String, dynamic>> _selectedFoods = [];
  String _notes = '';
  bool _saveAsFavorite = false;
  bool _shareWithProvider = true;
  bool _isLoading = false;
  int _selectedNavIndex = 2; // Add Meal is index 2
  Map<String, dynamic>? _medicalProfile;

  // CRITICAL FIX: GlobalKey to access CameraPreviewWidget for auto-open camera
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey<CameraPreviewWidgetState>();
  
  // FIXED: ScrollController to enable auto-scroll to camera panel
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMedicalProfile();
    // Check if we received arguments (for editing or pre-filled data)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null) {
        _handleArguments(args);
      }
    });
  }

  Future<void> _loadMedicalProfile() async {
    try {
      final profile = await ProfileService.instance.getCompleteProfile();
      if (mounted) {
        setState(() {
          _medicalProfile = profile?['medical_profile'];
        });
      }
    } catch (error) {
      print('Error loading medical profile: $error');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleArguments(dynamic args) {
    if (args is Map<String, dynamic>) {
      setState(() {
        // Handle recipe data from recipe detail screen
        if (args.containsKey('recipe_data')) {
          final recipeData = args['recipe_data'] as Map<String, dynamic>?;
          if (recipeData != null) {
            _addRecipeToSelectedFoods(recipeData);
          }
        }

        // If editing an existing meal
        if (args.containsKey('meal_type')) {
          _selectedMealType = _mapMealTypeFromDB(args['meal_type'] as String);
        }
        if (args.containsKey('meal_time') && args['meal_time'] != null) {
          final timeString = args['meal_time'] as String;
          final timeParts = timeString.split(':');
          _selectedTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
        if (args.containsKey('notes')) {
          _notes = args['notes'] as String? ?? '';
        }
        // Handle photo from camera
        if (args.containsKey('photo')) {
          _capturedImage = args['photo'] as XFile?;
        }
        // Handle selected date from meal diary
        if (args.containsKey('selected_date')) {
          _selectedDate = args['selected_date'] as DateTime;
        }
        // Handle meal date from existing meal
        if (args.containsKey('date')) {
          final dateStr = args['date'] as String?;
          if (dateStr != null) {
            _selectedDate = DateTime.parse(dateStr);
          }
        }
      });

      // CRITICAL FIX: Handle auto-open camera parameter
      // This must be done after setState to ensure the widget is built
      if (args.containsKey('autoOpenCamera') && args['autoOpenCamera'] == true) {
        // Delay to ensure the CameraPreviewWidget is built
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _triggerCameraOpen();
          }
        });
      }
    }
  }

  /// Add recipe to selected foods list
  void _addRecipeToSelectedFoods(Map<String, dynamic> recipeData) {
    try {
      final servings = (recipeData['servings'] as num?)?.toInt() ?? 1;
      final totalCalories =
          (recipeData['total_calories'] as num?)?.toInt() ?? 0;
      final totalProtein =
          (recipeData['total_protein_g'] as num?)?.toDouble() ?? 0.0;
      final totalCarbs =
          (recipeData['total_carbs_g'] as num?)?.toDouble() ?? 0.0;
      final totalFat = (recipeData['total_fat_g'] as num?)?.toDouble() ?? 0.0;

      // Use calories_per_100g from DB if available (populated from CSV data)
      final dbCaloriesPer100g = (recipeData['calories_per_100g'] as num?)?.toInt() ?? 0;
      final dbTotalWeight = ((recipeData['total_weight_g'] as num?) ?? 0).toDouble();

      // Calculate true per-100g values using total_weight_g from DB
      int caloriesPer100g;
      double proteinPer100g;
      double carbsPer100g;
      double fatPer100g;

      if (dbCaloriesPer100g > 0) {
        // Best case: use pre-calculated calories_per_100g from DB
        caloriesPer100g = dbCaloriesPer100g;
        if (dbTotalWeight > 0) {
          proteinPer100g = (totalProtein / dbTotalWeight) * 100;
          carbsPer100g = (totalCarbs / dbTotalWeight) * 100;
          fatPer100g = (totalFat / dbTotalWeight) * 100;
        } else {
          // Fallback for macros: estimate with 250g per serving
          final estWeight = 250.0 * servings;
          proteinPer100g = estWeight > 0 ? (totalProtein / estWeight) * 100 : 0;
          carbsPer100g = estWeight > 0 ? (totalCarbs / estWeight) * 100 : 0;
          fatPer100g = estWeight > 0 ? (totalFat / estWeight) * 100 : 0;
        }
      } else if (dbTotalWeight > 0) {
        // Use total_weight_g to calculate per-100g
        caloriesPer100g = ((totalCalories / dbTotalWeight) * 100).round();
        proteinPer100g = (totalProtein / dbTotalWeight) * 100;
        carbsPer100g = (totalCarbs / dbTotalWeight) * 100;
        fatPer100g = (totalFat / dbTotalWeight) * 100;
      } else {
        // Last resort fallback: estimate with 250g per serving
        final estWeight = 250.0 * servings;
        caloriesPer100g = estWeight > 0 ? ((totalCalories / estWeight) * 100).round() : 0;
        proteinPer100g = estWeight > 0 ? (totalProtein / estWeight) * 100 : 0;
        carbsPer100g = estWeight > 0 ? (totalCarbs / estWeight) * 100 : 0;
        fatPer100g = estWeight > 0 ? (totalFat / estWeight) * 100 : 0;
      }

      // Create food item from recipe
      final recipeFood = {
        'id': recipeData['id'],
        'name': recipeData['title'] ?? 'Ricetta',
        'type': 'recipe',
        'brand': 'Ricetta personalizzata',
        'calories_per_100g': caloriesPer100g,
        'protein': proteinPer100g,
        'carbs': carbsPer100g,
        'fats': fatPer100g,
        'total_calories': totalCalories,
        'servings_count': servings,
        'quantity': 100.0,
        'selected_serving': '100g',
        'image_url': recipeData['image_url'] ?? recipeData['imageUrl'],
      };

      _selectedFoods.add(recipeFood);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ricetta "${recipeData['title']}" aggiunta al pasto'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error adding recipe to selected foods: $e');
    }
  }

  // FIXED: Method to trigger camera opening and scroll to it
  void _triggerCameraOpen() {
    // Access the CameraPreviewWidget via GlobalKey and open the camera
    final cameraState = _cameraKey.currentState;
    if (cameraState != null) {
      // Call a public method on CameraPreviewWidget to open camera
      cameraState.openCameraExternally();
      
      // FIXED: Scroll to camera panel after a short delay to ensure it's rendered
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && _scrollController.hasClients) {
          // Scroll to a position that shows the camera panel
          // Approximate position: after date selector, meal type, and food search
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent * 0.6, // Scroll to ~60% of content
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  String _mapMealTypeFromDB(String dbMealType) {
    switch (dbMealType) {
      case 'breakfast':
        return 'breakfast';
      case 'lunch':
        return 'lunch';
      case 'dinner':
        return 'dinner';
      case 'snack':
        return 'snack';
      default:
        return 'breakfast';
    }
  }

  String _mapMealTypeToDB(String displayMealType) {
    switch (displayMealType) {
      case 'Colazione':
      case 'breakfast':
        return 'breakfast';
      case 'Pranzo':
      case 'lunch':
        return 'lunch';
      case 'Cena':
      case 'dinner':
        return 'dinner';
      case 'Spuntino':
      case 'snack':
        return 'snack';
      default:
        return 'breakfast';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF00ACC1), // seaMid
              Color(0xFF006064), // seaDeep
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildOceanTopBar(),
              Expanded(child: _buildBody()),
              _buildOceanBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOceanTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Close button
          GestureDetector(
            onTap: () => _handleCancel(),
            child: Text(
              '✕',
              style: TextStyle(
                fontSize: 20.sp,
                color: const Color(0xFFE0F7FA).withValues(alpha: 0.8),
              ),
            ),
          ),
          // Title
          Text(
            'Aggiungi pasto',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE0F7FA),
              shadows: [
                Shadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          // Save button
          GestureDetector(
            onTap: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF80DEEA)),
                    ),
                  )
                : Text(
                    'Salva',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: _canSave()
                          ? const Color(0xFF80DEEA) // Light cyan for active
                          : const Color(0xFFE0F7FA).withValues(alpha: 0.4),
                    ),
                  ),
          ),
        ],
      ),
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
                onTap: () {}, // Already on add meal page
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
      onTap: () => _onBottomNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: isActive ? AppTheme.seaMid : const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedNavIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.mealDiary);
        break;
      case 2:
        // Already on Add Meal - stay on current screen
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      controller: _scrollController, // FIXED: Added scroll controller
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Date Selector - New section
            _buildDateSelector(),

            SizedBox(height: 3.h),

            // Meal Type and Time Selector
            MealTypeSelectorWidget(
              selectedMealType: _selectedMealType,
              onMealTypeChanged: (type) {
                setState(() {
                  _selectedMealType = type;
                });
              },
              selectedTime: _selectedTime,
              onTimeChanged: (time) {
                setState(() {
                  _selectedTime = time;
                });
              },
            ),

            SizedBox(height: 3.h),

            // Food Search and Selection - Moved above camera section
            Container(
              child: FoodSearchWidget(
                selectedFoods: _selectedFoods,
                onFoodAdded: (food) {
                  try {
                    print(
                        'Received food to add: ${food['name']} (ID: ${food['id']})');
                    setState(() {
                      _selectedFoods.add(food);
                    });
                    print(
                        'Food added to _selectedFoods. New count: ${_selectedFoods.length}');

                    // Immediately check if save button should be enabled
                    final canSave = _canSave();
                    print('Can save after adding food: $canSave');
                    if (!canSave) {
                      print(
                          'Warning: Food was added but _canSave() returns false');
                      // Try to understand why by checking each food
                      for (int i = 0; i < _selectedFoods.length; i++) {
                        final foodData =
                            _prepareFoodDataForDB(_selectedFoods[i]);
                        print(
                            'Food $i validation result: ${foodData != null ? 'VALID' : 'INVALID'}');
                      }
                    }
                  } catch (e) {
                    print('Error adding food: $e');
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Errore nell\'aggiunta del cibo: $e'),
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                onFoodRemoved: (index) {
                  try {
                    if (index >= 0 && index < _selectedFoods.length) {
                      final removedFood = _selectedFoods[index];
                      print(
                          'Removing food: ${removedFood['name']} at index $index');
                      setState(() {
                        _selectedFoods.removeAt(index);
                      });
                      print(
                          'Food removed. New count: ${_selectedFoods.length}');
                    }
                  } catch (e) {
                    print('Error removing food: $e');
                  }
                },
                onFoodUpdated: (index, field, value) {
                  try {
                    if (index >= 0 &&
                        index < _selectedFoods.length &&
                        value != null) {
                      print('Updating food at index $index: $field = $value');
                      setState(() {
                        _selectedFoods[index][field] = value;
                      });

                      // Check validation after update
                      final foodData =
                          _prepareFoodDataForDB(_selectedFoods[index]);
                      print(
                          'Food validation after update: ${foodData != null ? 'VALID' : 'INVALID'}');
                    }
                  } catch (e) {
                    print('Error updating food: $e');
                  }
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Camera Preview Section - Moved below food search
            // FIXED: Optimized height for better camera preview experience
            SizedBox(
              height: 55.h, // Increased to 55% for larger, more immersive camera view
              child: CameraPreviewWidget(
                key: _cameraKey,
                capturedImage: _capturedImage,
                onImageCaptured: (image) {
                  setState(() {
                    _capturedImage = image;
                  });
                },
              ),
            ),

            SizedBox(height: 3.h),

            // Only show nutrition summary if there are valid selected foods
            if (_selectedFoods.isNotEmpty) ...[
              Container(
                child: NutritionSummaryWidget(
                  selectedFoods: _selectedFoods,
                  medicalProfile: _medicalProfile,
                ),
              ),
              SizedBox(height: 3.h),
            ],

            // Notes and Options Section
            NotesSectionWidget(
              notes: _notes,
              onNotesChanged: (notes) {
                setState(() {
                  _notes = notes ?? '';
                });
              },
              saveAsFavorite: _saveAsFavorite,
              onSaveAsFavoriteChanged: (value) {
                setState(() {
                  _saveAsFavorite = value ?? false;
                });
              },
              shareWithProvider: _shareWithProvider,
              onShareWithProviderChanged: (value) {
                setState(() {
                  _shareWithProvider = value ?? true;
                });
              },
            ),

            SizedBox(height: 4.h),

            // Log Meal Button
            _buildLogMealButton(),

            SizedBox(height: 4.h), // Padding for bottom navigation
          ],
        ),
      );
  }

  Widget _buildDateSelector() {
    return CustomDatePickerWidget(
      selectedDate: _selectedDate,
      title: 'Data del pasto',
      helpText: 'Seleziona data del pasto',
      onDateSelected: (DateTime pickedDate) {
        setState(() {
          _selectedDate = pickedDate;
        });

        // Show confirmation message
        final isToday = pickedDate.year == DateTime.now().year &&
            pickedDate.month == DateTime.now().month &&
            pickedDate.day == DateTime.now().day;

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
                Expanded(
                  child: Text(
                    isToday
                        ? 'Data impostata per oggi'
                        : 'Data impostata: ${_formatSelectedDate()}',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
            duration: Duration(seconds: 2),
          ),
        );
      },
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 7)),
      showPastIndicator: true,
    );
  }

  String _formatSelectedDate() {
    final now = DateTime.now();
    if (_selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day) {
      return 'Oggi';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (_selectedDate.year == yesterday.year &&
        _selectedDate.month == yesterday.month &&
        _selectedDate.day == yesterday.day) {
      return 'Ieri';
    }

    final weekdays = ['', 'Lun', 'Mar', 'Mer', 'Gio', 'Ven', 'Sab', 'Dom'];
    final months = [
      '',
      'Gen',
      'Feb',
      'Mar',
      'Apr',
      'Mag',
      'Giu',
      'Lug',
      'Ago',
      'Set',
      'Ott',
      'Nov',
      'Dic',
    ];

    return '${weekdays[_selectedDate.weekday]} ${_selectedDate.day} ${months[_selectedDate.month]}';
  }

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(
        Duration(days: 365),
      ), // Allow up to 1 year ago
      lastDate: DateTime.now().add(
        Duration(days: 7),
      ), // Allow up to 1 week in future
      locale: const Locale('it', 'IT'),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme.copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
              primary: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
      helpText: 'Seleziona data del pasto',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Widget _buildLogMealButton() {
    final canSave = _canSave();
    return GestureDetector(
      onTap: canSave && !_isLoading ? _handleLogMeal : null,
      child: Container(
        width: double.infinity,
        height: 6.h,
        decoration: BoxDecoration(
          gradient: canSave
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF26C6DA), // seaTop
                    Color(0xFF00838F), // darker teal
                  ],
                )
              : null,
          color: canSave ? null : const Color(0xFFB0BEC5).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canSave
              ? [
                  BoxShadow(
                    color: const Color(0xFF00838F).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      'Salvataggio pasto...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomIconWidget(
                      iconName: 'restaurant',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Registra pasto',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  bool _canSave() {
    // Enhanced validation: check not just for non-empty list, but for valid foods
    if (_selectedFoods.isEmpty) return false;

    // Check if at least one food item is valid
    for (final food in _selectedFoods) {
      final preparedFood = _prepareFoodDataForDB(food);
      if (preparedFood != null) {
        return true; // Found at least one valid food
      }
    }

    return false; // No valid foods found
  }

  void _handleCancel() {
    if (_selectedFoods.isNotEmpty ||
        _capturedImage != null ||
        _notes.isNotEmpty) {
      _showDiscardDialog();
    } else {
      Navigator.of(context).pop();
    }
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            'Scartare le modifiche?',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Hai modifiche non salvate. Sei sicuro di volerle scartare?',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Continua modifica',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text(
                'Scarta',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSave() async {
    if (!_canSave() || _isLoading) return;

    // Check authentication
    if (!AuthService.instance.isAuthenticated) {
      _showAuthRequiredDialog();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate that we have valid foods to save
      if (_selectedFoods.isEmpty) {
        throw Exception('Nessun cibo selezionato per il pasto');
      }

      // Prepare meal foods data for database with improved validation
      final mealFoods = <Map<String, dynamic>>[];

      for (final food in _selectedFoods) {
        final foodData = _prepareFoodDataForDB(food);
        if (foodData != null) {
          mealFoods.add(foodData);
        }
      }

      // Critical validation: ensure we have valid meal foods before proceeding
      if (mealFoods.isEmpty) {
        throw Exception(
            'Nessun cibo valido da salvare. Controlla che tutti i cibi selezionati siano validi.');
      }

      // Create meal entry using MealDiaryService with selected date
      final mealEntry = await MealDiaryService.instance.addMealEntry(
        mealDate: _selectedDate, // Use selected date instead of DateTime.now()
        mealType: _mapMealTypeToDB(_selectedMealType),
        mealTime: _selectedTime,
        notes: _notes.isNotEmpty ? _notes : null,
        foods: mealFoods,
        imageFile: _capturedImage, // Pass captured image to be saved
      );

      // Verify the meal was saved successfully and has foods
      if (mealFoods.isNotEmpty) {
        // FIXED: Save recipes to favorites if toggle is enabled
        if (_saveAsFavorite) {
          await _saveRecipesToFavorites();
        }

        // Clear the form after successful save
        if (mounted) {
          setState(() {
            _selectedFoods.clear();
            _notes = '';
            _capturedImage = null;
            _selectedTime = TimeOfDay.now();
            _saveAsFavorite = false; // Reset toggle
            // Keep the selected date for potential additional meals
          });
        }

        // Show success message with date confirmation
        if (mounted) {
          final hasImage = _capturedImage != null;
          final dateText = _formatSelectedDate();

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
                  Expanded(
                    child: Text(
                      hasImage
                          ? 'Pasto e foto salvati per $dateText!'
                          : 'Pasto registrato per $dateText!',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: EdgeInsets.all(4.w),
              duration: Duration(seconds: 3),
              action: hasImage
                  ? SnackBarAction(
                      label: 'Visualizza',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.mealDiary,
                          arguments: {
                            'selected_date': _selectedDate,
                            'show_saved_meal': true,
                          },
                        );
                      },
                    )
                  : null,
            ),
          );

          // Navigate to meal diary with selected date
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.mealDiary,
                arguments: {
                  'selected_date': _selectedDate,
                  'highlight_new_meal': true,
                }, // Pass selected date back
              );
            }
          });
        }
      } else {
        throw Exception(
            'Il pasto è stato salvato ma potrebbe essere incompleto');
      }
    } catch (e) {
      print('Error saving meal: $e');

      // Show specific error messages based on the error type
      if (mounted) {
        String errorMessage;

        if (e.toString().contains('Nessun cibo selezionato')) {
          errorMessage =
              'Devi selezionare almeno un cibo prima di salvare il pasto.';
        } else if (e.toString().contains('Nessun cibo valido')) {
          errorMessage =
              'I cibi selezionati non sono validi. Riprova ad aggiungere gli alimenti.';
        } else if (e.toString().contains('User not authenticated')) {
          errorMessage = 'Devi effettuare l\'accesso per salvare il pasto.';
        } else if (e.toString().contains('Failed to upload image')) {
          errorMessage =
              'Errore nel caricamento dell\'immagine. Il pasto è stato salvato senza foto.';
        } else if (e.toString().contains('violates foreign key constraint') ||
            e.toString().contains('constraint violation')) {
          errorMessage =
              'Errore nella struttura dati. Riprova o contatta il supporto.';
        } else {
          errorMessage =
              'Errore nel salvare il pasto. Controlla la tua connessione e riprova.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: EdgeInsets.all(4.w),
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Riprova',
              textColor: Colors.white,
              onPressed: () {
                // Allow user to retry saving
                _handleSave();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// FIXED: Save all selected recipes to favorites
  Future<void> _saveRecipesToFavorites() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    try {
      // Filter only recipes from selected foods
      final recipes = _selectedFoods.where((food) => food['type'] == 'recipe').toList();
      
      if (recipes.isEmpty) return;

      // Save each recipe to favorites
      int savedCount = 0;
      for (final recipe in recipes) {
        try {
          await RecipeService.instance.addToFavorites(
            recipe['id'],
            user.id,
          );
          savedCount++;
        } catch (e) {
          print('Error saving recipe ${recipe['name']} to favorites: $e');
        }
      }

      // Show success message if any recipes were saved
      if (savedCount > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              savedCount == 1
                  ? 'Ricetta salvata nei preferiti!'
                  : '$savedCount ricette salvate nei preferiti!',
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error in _saveRecipesToFavorites: $e');
    }
  }

  Map<String, dynamic>? _prepareFoodDataForDB(Map<String, dynamic> food) {
    try {
      final foodId = food['id'];
      final foodName = food['name'];

      // Enhanced validation for essential data
      if (foodId == null) {
        print('Food item missing ID: $food');
        return null;
      }

      if (foodName == null || foodName.toString().trim().isEmpty) {
        print('Food item missing name: $food');
        return null;
      }

      final foodType = (food['type'] as String?) ?? 'food_item';
      final quantity =
          (food['quantity'] as num?)?.toDouble() ?? 100.0; // Default to 100g
      final selectedServing = "100g"; // Always 100g now

      // Validate quantity - updated for grams-only system
      if (quantity <= 0 || quantity > 10000) {
        print('Invalid quantity for food: $food, quantity: $quantity');
        // Instead of returning null, set a default valid quantity
        food['quantity'] = 100.0;
      }

      double finalCalories = 0.0;
      double finalProtein = 0.0;
      double finalCarbs = 0.0;
      double finalFat = 0.0;
      double finalFiber = 0.0;
      final finalQuantityGrams = quantity; // Direct grams value

      if (foodType == 'recipe') {
        // For recipes, use the pre-calculated calories_per_100g
        final caloriesPer100g = (food['calories_per_100g'] as int?) ?? 0;
        final proteinPer100g = ((food['protein'] as num?) ?? 0).toDouble();
        final carbsPer100g = ((food['carbs'] as num?) ?? 0).toDouble();
        final fatPer100g = ((food['fats'] as num?) ?? 0).toDouble();
        final fiberPer100g = ((food['fiber'] as num?) ?? 0).toDouble();

        // Fixed calculation: (grams / 100g) × nutrition per 100g
        final multiplier = quantity / 100.0;
        finalCalories = caloriesPer100g * multiplier;
        finalProtein = proteinPer100g * multiplier;
        finalCarbs = carbsPer100g * multiplier;
        finalFat = fatPer100g * multiplier;
        finalFiber = fiberPer100g * multiplier;
      } else if (foodType == 'food_ingredient') {
        // For food ingredients from the Food Ingredients table
        final caloriesPer100g = (food['calories_per_100g'] as int?) ?? 0;
        final proteinPer100g = ((food['protein'] as num?) ?? 0).toDouble();
        final carbsPer100g = ((food['carbs'] as num?) ?? 0).toDouble();
        final fatPer100g = ((food['fats'] as num?) ?? 0).toDouble();
        final fiberPer100g = ((food['fiber'] as num?) ?? 0).toDouble();

        // Fixed calculation: (grams / 100g) × nutrition per 100g
        final multiplier = quantity / 100.0;
        finalCalories = caloriesPer100g * multiplier;
        finalProtein = proteinPer100g * multiplier;
        finalCarbs = carbsPer100g * multiplier;
        finalFat = fatPer100g * multiplier;
        finalFiber = fiberPer100g * multiplier;
      } else {
        // For food items, use direct nutritional values per 100g
        final caloriesPer100g = (food['calories_per_100g'] as int?) ?? 0;
        final proteinPer100g = ((food['protein'] as num?) ?? 0).toDouble();
        final carbsPer100g = ((food['carbs'] as num?) ?? 0).toDouble();
        final fatPer100g = ((food['fats'] as num?) ?? 0).toDouble();
        final fiberPer100g = ((food['fiber'] as num?) ?? 0).toDouble();

        // Fixed calculation: (grams / 100g) × nutrition per 100g
        final multiplier = quantity / 100.0;
        finalCalories = caloriesPer100g * multiplier;
        finalProtein = proteinPer100g * multiplier;
        finalCarbs = carbsPer100g * multiplier;
        finalFat = fatPer100g * multiplier;
        finalFiber = fiberPer100g * multiplier;
      }

      // Clamp values to reasonable ranges
      finalCalories = finalCalories.clamp(0.0, 50000.0);
      finalProtein = finalProtein.clamp(0.0, 1000.0);
      finalCarbs = finalCarbs.clamp(0.0, 1000.0);
      finalFat = finalFat.clamp(0.0, 1000.0);
      finalFiber = finalFiber.clamp(0.0, 1000.0);

      // Ensure we have either food_item_id, food_ingredient_code, or recipe_id, but not multiple
      final Map<String, dynamic> result;
      if (foodType == 'recipe') {
        result = {
          'food_item_id': null,
          'food_ingredient_code': null,
          'recipe_id': foodId,
          'quantity_grams': finalQuantityGrams,
          'calories': finalCalories,
          'protein_g': finalProtein,
          'carbs_g': finalCarbs,
          'fat_g': finalFat,
          'fiber_g': finalFiber,
        };
      } else if (foodType == 'food_ingredient') {
        result = {
          'food_item_id': null,
          'food_ingredient_code': foodId, // Use the Codice Alimento as the code
          'recipe_id': null,
          'quantity_grams': finalQuantityGrams,
          'calories': finalCalories,
          'protein_g': finalProtein,
          'carbs_g': finalCarbs,
          'fat_g': finalFat,
          'fiber_g': finalFiber,
        };
      } else {
        result = {
          'food_item_id': foodId,
          'food_ingredient_code': null,
          'recipe_id': null,
          'quantity_grams': finalQuantityGrams,
          'calories': finalCalories,
          'protein_g': finalProtein,
          'carbs_g': finalCarbs,
          'fat_g': finalFat,
          'fiber_g': finalFiber,
        };
      }

      // Final validation: ensure exactly one food source is provided
      final sourceCount = [
        result['food_item_id'],
        result['food_ingredient_code'],
        result['recipe_id'],
      ].where((id) => id != null).length;

      if (sourceCount != 1) {
        print('Invalid food source configuration: $result (sourceCount: $sourceCount)');
        return null;
      }

      // Debug log successful preparation
      print(
          'Successfully prepared food data for DB: ${result['food_item_id'] ?? result['food_ingredient_code'] ?? result['recipe_id']} (type: $foodType) with ${result['calories'].toStringAsFixed(1)} calories from ${result['quantity_grams']}g');

      return result;
    } catch (e) {
      print('Error preparing food data for DB: $e');
      print('Food data that caused error: $food');
      return null;
    }
  }

  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: Text(
          'Accesso richiesto',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Devi effettuare l\'accesso per salvare i pasti.',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.8,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annulla',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
            ),
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

  Future<void> _handleLogMeal() async {
    await _handleSave();
  }
}
