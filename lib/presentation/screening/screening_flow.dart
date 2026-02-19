import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/app_export.dart';
import '../../services/body_metrics_service.dart';
import '../../services/profile_service.dart';
import 'widgets/screening_input_field.dart';
import 'widgets/screening_option_button.dart';
import 'widgets/screening_page_widget.dart';

/// Main screening flow with 6 pages to collect initial user data
class ScreeningFlow extends StatefulWidget {
  const ScreeningFlow({Key? key}) : super(key: key);

  @override
  State<ScreeningFlow> createState() => _ScreeningFlowState();
}

class _ScreeningFlowState extends State<ScreeningFlow> {
  final PageController _pageController = PageController();
  final ProfileService _profileService = ProfileService.instance;
  final BodyMetricsService _bodyMetricsService = BodyMetricsService.instance;

  int _currentPage = 0;
  bool _isLoading = false;

  // Form controllers
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();

  // Data storage
  double? _heightCm;
  double? _weightKg;
  int? _dailyCalories;
  bool _caloriesFromDoctor = false;
  final Set<String> _dietaryPreferences = {};
  final Set<String> _foodPreferences = {};
  final Set<String> _beveragePreferences = {};

  @override
  void dispose() {
    _pageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeScreening();
    }
  }

  Future<void> _completeScreening() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Save height and weight if provided
      if (_heightCm != null) {
        await _profileService.updateMedicalProfile({
          'height_cm': _heightCm,
        });
      }

      if (_weightKg != null) {
        // Save weight entry
        await _bodyMetricsService.saveWeightEntry(weightKg: _weightKg!);
        
        // Update current weight in profile
        await _profileService.updateMedicalProfile({
          'current_weight_kg': _weightKg,
        });
      }

      // Calculate and save calorie target
      int? targetCalories;
      if (_caloriesFromDoctor && _dailyCalories != null) {
        // Use doctor-provided calories
        targetCalories = _dailyCalories;
        await _profileService.updateMedicalProfile({
          'daily_caloric_intake': _dailyCalories,
          'calories_from_doctor': true,
        });
      } else if (_weightKg != null) {
        // Calculate based on weight (25-30 x weight)
        targetCalories = (_weightKg! * 27.5).round(); // Use midpoint
        await _profileService.updateMedicalProfile({
          'target_daily_calories': targetCalories,
        });
      }

      // Save preferences
      await _profileService.updateMedicalProfile({
        'dietary_preferences': _dietaryPreferences.toList(),
        'food_preferences': _foodPreferences.toList(),
        'beverage_preferences': _beveragePreferences.toList(),
        'screening_completed': true,
      });

      if (mounted) {
        // Navigate to dashboard
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    } catch (error) {
      print('Error completing screening: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvare i dati: $error'),
            backgroundColor: Colors.red,
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

  void _skipScreening() {
    // Mark screening as completed (skipped) and go to dashboard
    _profileService.updateMedicalProfile({'screening_completed': true});
    Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_currentPage > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildHeightPage(),
          _buildWeightPage(),
          _buildCaloriesPage(),
          _buildDietaryPreferencesPage(),
          _buildFoodPreferencesPage(),
          _buildBeveragePreferencesPage(),
        ],
      ),
    );
  }

  // Page 1: Height
  Widget _buildHeightPage() {
    return ScreeningPageWidget(
      question: 'Qual è la tua altezza?',
      content: ScreeningInputField(
        controller: _heightController,
        suffix: 'cm',
        hint: '170',
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
        ],
      ),
      onButtonPressed: () {
        final height = double.tryParse(_heightController.text);
        if (height != null && height > 0) {
          _heightCm = height;
          _nextPage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserisci un\'altezza valida')),
          );
        }
      },
      onSkipChanged: (value) {
        if (value == true) {
          _skipScreening();
        }
      },
    );
  }

  // Page 2: Weight
  Widget _buildWeightPage() {
    return ScreeningPageWidget(
      question: 'Qual è il tuo peso?',
      content: ScreeningInputField(
        controller: _weightController,
        suffix: 'Kg',
        hint: '70',
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(5),
        ],
      ),
      onButtonPressed: () {
        final weight = double.tryParse(_weightController.text);
        if (weight != null && weight > 0) {
          _weightKg = weight;
          _nextPage();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Inserisci un peso valido')),
          );
        }
      },
      onSkipChanged: (value) {
        if (value == true) {
          _skipScreening();
        }
      },
    );
  }

  // Page 3: Calories
  Widget _buildCaloriesPage() {
    final minCalories = _weightKg != null ? (_weightKg! * 25).round() : 0;
    final maxCalories = _weightKg != null ? (_weightKg! * 30).round() : 0;

    return ScreeningPageWidget(
      description: _weightKg != null
          ? 'La stima iniziale del tuo fabbisogno calorico è: da $minCalories Kcal a $maxCalories Kcal al giorno'
          : null,
      content: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _caloriesFromDoctor,
                  onChanged: (value) {
                    setState(() {
                      _caloriesFromDoctor = value ?? false;
                    });
                  },
                  fillColor: MaterialStateProperty.resolveWith((states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.white;
                    }
                    return Colors.transparent;
                  }),
                  checkColor: const Color(0xFF00ACC1),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Il fabbisogno calorico mi è stato comunicato dal medico',
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_caloriesFromDoctor) ...[
            SizedBox(height: 3.h),
            ScreeningInputField(
              controller: _caloriesController,
              suffix: 'Kcal',
              hint: '2000',
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
            ),
          ],
        ],
      ),
      onButtonPressed: () {
        if (_caloriesFromDoctor) {
          final calories = int.tryParse(_caloriesController.text);
          if (calories != null && calories > 0) {
            _dailyCalories = calories;
            _nextPage();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inserisci un valore valido')),
            );
          }
        } else {
          _nextPage();
        }
      },
      onSkipChanged: (value) {
        if (value == true) {
          _skipScreening();
        }
      },
    );
  }

  // Page 4: Dietary Preferences
  Widget _buildDietaryPreferencesPage() {
    final options = ['Onnivora', 'Vegetariana', 'Vegana', 'Mediterranea'];

    return ScreeningPageWidget(
      question: 'Segui una dieta specifica?',
      content: Column(
        children: options.map((option) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2.h),
            child: ScreeningOptionButton(
              label: option,
              isSelected: _dietaryPreferences.contains(option),
              onTap: () {
                setState(() {
                  if (_dietaryPreferences.contains(option)) {
                    _dietaryPreferences.remove(option);
                  } else {
                    _dietaryPreferences.add(option);
                  }
                });
              },
            ),
          );
        }).toList(),
      ),
      onButtonPressed: _nextPage,
      onSkipChanged: (value) {
        if (value == true) {
          _skipScreening();
        }
      },
    );
  }

  // Page 5: Food Preferences
  Widget _buildFoodPreferencesPage() {
    final options = [
      'Verdura',
      'Frutta',
      'Cereali',
      'Uova',
      'Affettati',
      'Latte e derivati',
      'Riso',
      'Pasta',
      'Carne',
      'Pesce',
      'Dolci e prodotti da forno',
      'Legumi',
    ];

    return ScreeningPageWidget(
      question: 'Cosa ti piace mangiare?',
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 2.5,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return ScreeningOptionButton(
            label: option,
            isSelected: _foodPreferences.contains(option),
            onTap: () {
              setState(() {
                if (_foodPreferences.contains(option)) {
                  _foodPreferences.remove(option);
                } else {
                  _foodPreferences.add(option);
                }
              });
            },
          );
        },
      ),
      buttonText: 'Iniziamo →',
      onButtonPressed: _nextPage,
      onSkipChanged: (value) {
        if (value == true) {
          _skipScreening();
        }
      },
    );
  }

  // Page 6: Beverage Preferences
  Widget _buildBeveragePreferencesPage() {
    final options = [
      'Vino',
      'Birra',
      'Caffè',
      'Tè / Tisane',
      'Succhi di frutta',
      'Altro',
    ];

    return ScreeningPageWidget(
      question: 'Cosa ti piace bere?',
      content: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3.w,
          mainAxisSpacing: 2.h,
          childAspectRatio: 2.5,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final option = options[index];
          return ScreeningOptionButton(
            label: option,
            isSelected: _beveragePreferences.contains(option),
            onTap: () {
              setState(() {
                if (_beveragePreferences.contains(option)) {
                  _beveragePreferences.remove(option);
                } else {
                  _beveragePreferences.add(option);
                }
              });
            },
          );
        },
      ),
      buttonText: 'Iniziamo →',
      onButtonPressed: _completeScreening,
      showSkipOption: false, // Last page, no skip option
    );
  }
}
