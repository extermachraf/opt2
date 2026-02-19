import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/body_metrics_service.dart';
import '../../services/profile_service.dart';
import '../../widgets/custom_date_picker_widget.dart';
import './widgets/bmi_display_card.dart';
import './widgets/clinical_indicators_section.dart';
import './widgets/metric_input_card.dart';
import './widgets/notes_section.dart';
import './widgets/quick_entry_buttons.dart';
import './widgets/weight_trend_chart.dart';

class BodyMetrics extends StatefulWidget {
  const BodyMetrics({Key? key}) : super(key: key);

  @override
  State<BodyMetrics> createState() => _BodyMetricsState();
}

class _BodyMetricsState extends State<BodyMetrics> {
  final BodyMetricsService _bodyMetricsService = BodyMetricsService.instance;

  // Current metric values
  String _currentWeight = "";
  String _currentHeight = "";
  String _currentWaistCircumference = "";
  String _currentHipCircumference = "";
  String _currentLeanMass = "";
  String _currentFatMass = "";
  String _currentCellularMass = "";
  String _currentPhaseAngle = "";
  String _currentHandGrip = "";
  String _notes = "";

  // Unit toggles
  bool _isWeightInLbs = false; // Default to kg
  bool _isHeightInFeet = false; // Default to cm
  bool _isTempInFahrenheit = true;

  // Date range
  String _selectedDateRange = "Ultimi 30 giorni";
  int _selectedNavIndex = 0;

  // NEW: Date selection for weight entry
  DateTime _selectedWeightDate = DateTime.now();

  // Loading states
  bool _isLoading = false;
  bool _isChartLoading = false;
  bool _isSaving = false;

  // Data
  List<Map<String, dynamic>> _weightData = [];
  Map<String, dynamic>? _medicalProfile;
  Map<String, dynamic>? _latestWeight;

  @override
  void initState() {
    super.initState();
    _loadBodyMetricsData();
  }

  Future<void> _loadBodyMetricsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // FIXED: Better error handling and data validation
      final results = await Future.wait([
        _bodyMetricsService.getBodyMetricsSummary(),
        _bodyMetricsService.getWeightProgressData(limit: 50),
      ]);

      final summary = results[0] as Map<String, dynamic>;
      final weightData = results[1] as List<Map<String, dynamic>>;

      setState(() {
        _medicalProfile = summary['medical_profile'];
        _latestWeight = summary['today_weight']; // FIXED: Use today's weight, not latest
        _weightData = weightData;

        // FIXED: Only load TODAY's weight into the form
        // If selected date is today, show today's weight
        // Otherwise, load weight for the selected date
        _currentHeight =
            (_medicalProfile?['height_cm'] as num?)?.toString() ?? "";

        // Debug logging to track loaded weight value
        print('📊 Loading body metrics:');
        print('   Today\'s weight entry: ${summary['today_weight']}');
        print('   Latest weight entry: ${summary['latest_weight']}');
        print('   Selected date: $_selectedWeightDate');
      });

      // Load weight data for the currently selected date
      await _loadWeightForSelectedDate();

    } catch (error) {
      print('Error loading body metrics data: $error');
      _showErrorSnackBar(
        'Errore nel caricamento dei dati: ${error.toString()}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// NEW: Load weight data for the selected date
  Future<void> _loadWeightForSelectedDate() async {
    try {
      final weightEntry = await _bodyMetricsService.getWeightEntryForDate(_selectedWeightDate);

      setState(() {
        if (weightEntry != null) {
          // Load all fields from the weight entry for this date
          _currentWeight = (weightEntry['weight_kg'] as num?)?.toString() ?? "";
          _currentWaistCircumference =
              (weightEntry['waist_circumference_cm'] as num?)?.toString() ?? "";
          _currentHipCircumference =
              (weightEntry['hip_circumference_cm'] as num?)?.toString() ?? "";
          _currentLeanMass =
              (weightEntry['lean_mass_kg'] as num?)?.toString() ?? "";
          _currentFatMass =
              (weightEntry['fat_mass_kg'] as num?)?.toString() ?? "";
          _currentCellularMass =
              (weightEntry['cellular_mass_kg'] as num?)?.toString() ?? "";
          _currentPhaseAngle =
              (weightEntry['phase_angle_degrees'] as num?)?.toString() ?? "";
          _currentHandGrip =
              (weightEntry['hand_grip_strength_kg'] as num?)?.toString() ?? "";
          _notes = weightEntry['notes']?.toString() ?? "";

          print('✅ Loaded weight for selected date: $_currentWeight kg');
        } else {
          // No entry for this date - clear the form
          _currentWeight = "";
          _currentWaistCircumference = "";
          _currentHipCircumference = "";
          _currentLeanMass = "";
          _currentFatMass = "";
          _currentCellularMass = "";
          _currentPhaseAngle = "";
          _currentHandGrip = "";
          _notes = "";

          print('ℹ️ No weight entry for selected date - form cleared');
        }
      });
    } catch (error) {
      print('Error loading weight for selected date: $error');
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
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF80DEEA)),
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          children: [
                            SizedBox(height: 2.h),

                            // NEW: Weight Entry Date Selector - moved up
                            _buildWeightEntryDateSelector(),
                            SizedBox(height: 2.h),

                            // REARRANGED: Basic metrics (Peso, Altezza) above Clinical Indicators
                            _buildBasicMetricsCards(),
                            SizedBox(height: 2.h),

                            // MOVED: BMI Display placed between basic metrics and clinical indicators
                            _buildBMIDisplay(),
                            SizedBox(height: 2.h),

                            // REARRANGED: Clinical Indicators Section (Indicatori Nutrizionali Clinici)
                            _buildClinicalIndicatorsSection(),
                            SizedBox(height: 2.h),

                            // Weight Trend Chart with integrated period selector
                            WeightTrendChart(
                              weightData: _weightData,
                              dateRange: _selectedDateRange,
                              onDateRangeChanged: _handleDateRangeChanged,
                              isLoading: _isChartLoading,
                            ),
                            SizedBox(height: 2.h),
                            QuickEntryButtons(
                              onSameAsYesterday: _handleSameAsYesterday,
                            ),
                            SizedBox(height: 2.h),
                            NotesSection(
                              notes: _notes,
                              onNotesChanged: (notes) {
                                setState(() {
                                  _notes = notes;
                                });
                              },
                            ),
                            SizedBox(height: 4.h),
                            _buildSaveButton(),
                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
              ),
              _buildOceanBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // NEW: Weight Entry Date Selector Widget - UPDATED
  Widget _buildWeightEntryDateSelector() {
    return CustomDatePickerWidget(
      selectedDate: _selectedWeightDate,
      title: 'Data della misurazione del peso',
      helpText: 'Seleziona data della misurazione',
      onDateSelected: (DateTime pickedDate) async {
        setState(() {
          _selectedWeightDate = pickedDate;
        });

        // FIXED: Load weight data for the newly selected date
        await _loadWeightForSelectedDate();

        // Show confirmation message
        final isToday = pickedDate.year == DateTime.now().year &&
            pickedDate.month == DateTime.now().month &&
            pickedDate.day == DateTime.now().day;

        _showSuccessSnackBar(
          isToday
              ? 'Data impostata per oggi'
              : 'Data impostata: ${_formatWeightSelectedDate()}',
        );
      },
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 1)),
      showPastIndicator: true,
    );
  }

  // NEW: Format selected weight date
  String _formatWeightSelectedDate() {
    final now = DateTime.now();
    if (_selectedWeightDate.year == now.year &&
        _selectedWeightDate.month == now.month &&
        _selectedWeightDate.day == now.day) {
      return 'Oggi';
    }

    final yesterday = now.subtract(Duration(days: 1));
    if (_selectedWeightDate.year == yesterday.year &&
        _selectedWeightDate.month == yesterday.month &&
        _selectedWeightDate.day == yesterday.day) {
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

    return '${weekdays[_selectedWeightDate.weekday]} ${_selectedWeightDate.day} ${months[_selectedWeightDate.month]}';
  }

  // NEW: Weight entry date picker
  Future<void> _selectWeightEntryDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedWeightDate,
      firstDate: DateTime.now().subtract(
        Duration(days: 365),
      ), // Up to 1 year ago
      lastDate: DateTime.now().add(Duration(days: 1)), // Up to tomorrow
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
      helpText: 'Seleziona data della misurazione',
      cancelText: 'Annulla',
      confirmText: 'Conferma',
    );

    if (pickedDate != null && pickedDate != _selectedWeightDate) {
      setState(() {
        _selectedWeightDate = pickedDate;
      });

      // Show confirmation message
      final isToday = pickedDate.year == DateTime.now().year &&
          pickedDate.month == DateTime.now().month &&
          pickedDate.day == DateTime.now().day;

      _showSuccessSnackBar(
        isToday
            ? 'Data impostata per oggi'
            : 'Data impostata: ${_formatWeightSelectedDate()}',
      );
    }
  }

  Widget _buildOceanTopBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Text(
              '←',
              style: TextStyle(
                fontSize: 20.sp,
                color: const Color(0xFFE0F7FA).withValues(alpha: 0.8),
              ),
            ),
          ),
          // Title
          Text(
            'Metriche Corporee',
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
            onTap: _isSaving ? null : _handleSaveEntry,
            child: _isSaving
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
                      color: _currentWeight.isNotEmpty
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
                onTap: () => Navigator.pushNamed(context, AppRoutes.addMeal),
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
        Navigator.pushNamed(context, AppRoutes.addMeal);
        break;
      case 3:
        Navigator.pushNamed(context, AppRoutes.reports);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.profileSettings);
        break;
    }
  }

  Future<void> _handleDateRangeChanged(String range) async {
    if (_selectedDateRange != range) {
      setState(() {
        _selectedDateRange = range;
        _isChartLoading = true;
      });

      try {
        await _loadWeightDataForRange(range);
      } catch (error) {
        _showErrorSnackBar(
          'Errore nel caricamento dati per $range: ${error.toString()}',
        );
      } finally {
        setState(() {
          _isChartLoading = false;
        });
      }
    }
  }

  Future<void> _loadWeightDataForRange(String range) async {
    try {
      DateTime startDate;
      final now = DateTime.now();

      switch (range) {
        case "Ultimi 7 giorni":
          startDate = now.subtract(const Duration(days: 7));
          break;
        case "Ultimi 30 giorni":
          startDate = now.subtract(const Duration(days: 30));
          break;
        case "Ultimi 3 mesi":
          startDate = now.subtract(const Duration(days: 90));
          break;
        case "Ultimi 6 mesi":
          startDate = now.subtract(const Duration(days: 180));
          break;
        default:
          startDate = now.subtract(const Duration(days: 30));
      }

      // FIXED: Better date filtering and ensure selected date is included
      final endDate = now.add(const Duration(days: 1)); // Include today

      // If selected date is outside the range, extend the range to include it
      DateTime effectiveStartDate = startDate;
      if (_selectedWeightDate.isBefore(startDate)) {
        effectiveStartDate = DateTime(
          _selectedWeightDate.year,
          _selectedWeightDate.month,
          _selectedWeightDate.day,
        );
      }

      final weightData = await _bodyMetricsService.getWeightProgressData(
        startDate: effectiveStartDate,
        endDate: endDate,
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _weightData = weightData;
        });
      }

      // Debug logging to help users understand what's happening
      print('Filter applied: $range');
      print(
        'Date range: ${effectiveStartDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );
      print('Data found: ${weightData.length} entries');
    } catch (error) {
      print('Error loading weight data for range $range: $error');
      if (mounted) {
        _showErrorSnackBar(
          'Errore nel caricamento dei dati: ${error.toString()}',
        );
      }
    }
  }

  Widget _buildBasicMetricsCards() {
    return Column(
      children: [
        // Basic metrics (Peso and Altezza) - now separated from clinical indicators
        MetricInputCard(
          title: 'Peso Attuale',
          iconName: 'monitor_weight',
          value: _currentWeight,
          unit: _isWeightInLbs ? 'lbs' : 'kg',
          onTap: () => _showWeightInputDialog(),
          showUnitToggle: true,
          alternateUnit: _isWeightInLbs ? 'kg' : 'lbs',
          onUnitToggle: () {
            setState(() {
              _isWeightInLbs = !_isWeightInLbs;
              if (_currentWeight.isNotEmpty) {
                final weight = double.tryParse(_currentWeight);
                if (weight != null) {
                  _currentWeight = _isWeightInLbs
                      ? (weight * 2.20462).toStringAsFixed(1)
                      : (weight / 2.20462).toStringAsFixed(1);
                }
              }
            });
          },
        ),
        MetricInputCard(
          title: 'Altezza',
          iconName: 'height',
          value: _currentHeight,
          unit: _isHeightInFeet ? 'ft' : 'cm',
          onTap: () => _showHeightInputDialog(),
          showUnitToggle: true,
          alternateUnit: _isHeightInFeet ? 'cm' : 'ft',
          onUnitToggle: () {
            setState(() {
              _isHeightInFeet = !_isHeightInFeet;
            });
          },
        ),
      ],
    );
  }

  Widget _buildClinicalIndicatorsSection() {
    return Column(
      children: [
        // Clinical Nutritional Indicators in collapsible section
        ClinicalIndicatorsSection(
          currentWaistCircumference: _currentWaistCircumference,
          currentHipCircumference: _currentHipCircumference,
          currentLeanMass: _currentLeanMass,
          currentFatMass: _currentFatMass,
          currentCellularMass: _currentCellularMass,
          currentPhaseAngle: _currentPhaseAngle,
          currentHandGrip: _currentHandGrip,
          onWaistCircumferenceTap: () => _showWaistCircumferenceInputDialog(),
          onHipCircumferenceTap: () => _showHipCircumferenceInputDialog(),
          onLeanMassTap: () => _showLeanMassInputDialog(),
          onFatMassTap: () => _showFatMassInputDialog(),
          onCellularMassTap: () => _showCellularMassInputDialog(),
          onPhaseAngleTap: () => _showPhaseAngleInputDialog(),
          onHandGripTap: () => _showHandGripInputDialog(),
        ),
      ],
    );
  }

  // NEW: Input dialogs for new metrics
  void _showWaistCircumferenceInputDialog() {
    final controller = TextEditingController(text: _currentWaistCircumference);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Circonferenza vita',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Circonferenza vita (cm)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentWaistCircumference = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHipCircumferenceInputDialog() {
    final controller = TextEditingController(text: _currentHipCircumference);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Circonferenza fianchi',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Circonferenza fianchi (cm)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentHipCircumference = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLeanMassInputDialog() {
    final controller = TextEditingController(text: _currentLeanMass);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Massa magra',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Massa magra (kg)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentLeanMass = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFatMassInputDialog() {
    final controller = TextEditingController(text: _currentFatMass);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Massa grassa',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Massa grassa (kg)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentFatMass = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCellularMassInputDialog() {
    final controller = TextEditingController(text: _currentCellularMass);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Massa cellulare',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Massa cellulare (kg)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentCellularMass = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPhaseAngleInputDialog() {
    final controller = TextEditingController(text: _currentPhaseAngle);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Angolo di fase',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Angolo di fase (°)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentPhaseAngle = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHandGripInputDialog() {
    final controller = TextEditingController(text: _currentHandGrip);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Hand Grip',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Hand Grip (kg)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentHandGrip = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // FIXED: Updated "Come Ieri" handler to use the new service method
  Future<void> _handleSameAsYesterday() async {
    try {
      // Show loading feedback
      _showSuccessSnackBar('Ricerca peso del giorno precedente...');

      // Use the new service method to get specifically the previous day's weight
      final previousDayEntry = await _bodyMetricsService
          .getPreviousDayWeightEntry(currentDate: _selectedWeightDate);

      if (previousDayEntry != null) {
        final weightValue = (previousDayEntry['weight_kg'] as num?)?.toDouble();
        final waistCircumferenceValue =
            (previousDayEntry['waist_circumference_cm'] as num?)?.toDouble();
        final hipCircumferenceValue =
            (previousDayEntry['hip_circumference_cm'] as num?)?.toDouble();
        final leanMassValue =
            (previousDayEntry['lean_mass_kg'] as num?)?.toDouble();
        final fatMassValue =
            (previousDayEntry['fat_mass_kg'] as num?)?.toDouble();
        final cellularMassValue =
            (previousDayEntry['cellular_mass_kg'] as num?)?.toDouble();
        final phaseAngleValue =
            (previousDayEntry['phase_angle_degrees'] as num?)?.toDouble();
        final handGripValue =
            (previousDayEntry['hand_grip_strength_kg'] as num?)?.toDouble();
        final notesValue = previousDayEntry['notes']?.toString() ?? '';

        if (weightValue != null) {
          setState(() {
            _currentWeight = weightValue.toStringAsFixed(1);
            _currentWaistCircumference =
                waistCircumferenceValue?.toStringAsFixed(1) ?? '';
            _currentHipCircumference =
                hipCircumferenceValue?.toStringAsFixed(1) ?? '';
            _currentLeanMass = leanMassValue?.toStringAsFixed(1) ?? '';
            _currentFatMass = fatMassValue?.toStringAsFixed(1) ?? '';
            _currentCellularMass = cellularMassValue?.toStringAsFixed(1) ?? '';
            _currentPhaseAngle = phaseAngleValue?.toStringAsFixed(1) ?? '';
            _currentHandGrip = handGripValue?.toStringAsFixed(1) ?? '';
            _notes = notesValue;
          });

          // Show success with date information
          final previousDate = DateTime.parse(previousDayEntry['recorded_at']);
          final formattedDate = _formatDate(previousDate);

          _showSuccessSnackBar(
            'Valori impostati dal $formattedDate: ${weightValue.toStringAsFixed(1)} kg e altre metriche corporee',
          );
        } else {
          _showErrorSnackBar('Errore nei dati del peso precedente');
        }
      } else {
        _showErrorSnackBar('Nessun peso registrato nei giorni precedenti');
      }
    } catch (error) {
      print('Error in _handleSameAsYesterday: $error');
      _showErrorSnackBar(
        'Errore nel recupero del peso precedente: ${error.toString()}',
      );
    }
  }

  /// NEW: Helper method to format date for user display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'ieri';
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

    return '${weekdays[date.weekday]} ${date.day} ${months[date.month]}';
  }

  Future<void> _handleSaveEntry() async {
    // FIXED: Better validation and error handling
    if (_currentWeight.isEmpty) {
      _showErrorSnackBar('Inserisci il peso per salvare le metriche');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final weight = double.tryParse(_currentWeight.replaceAll(',', '.'));
      if (weight == null || weight <= 0) {
        throw Exception('Peso non valido: deve essere un numero positivo');
      }

      final weightInKg = _isWeightInLbs ? weight / 2.20462 : weight;

      // NEW: Parse new metrics
      final waistCircumference = _currentWaistCircumference.isNotEmpty
          ? double.tryParse(_currentWaistCircumference.replaceAll(',', '.'))
          : null;
      final hipCircumference = _currentHipCircumference.isNotEmpty
          ? double.tryParse(_currentHipCircumference.replaceAll(',', '.'))
          : null;
      final leanMass = _currentLeanMass.isNotEmpty
          ? double.tryParse(_currentLeanMass.replaceAll(',', '.'))
          : null;
      final fatMass = _currentFatMass.isNotEmpty
          ? double.tryParse(_currentFatMass.replaceAll(',', '.'))
          : null;
      final cellularMass = _currentCellularMass.isNotEmpty
          ? double.tryParse(_currentCellularMass.replaceAll(',', '.'))
          : null;
      final phaseAngle = _currentPhaseAngle.isNotEmpty
          ? double.tryParse(_currentPhaseAngle.replaceAll(',', '.'))
          : null;
      final handGrip = _currentHandGrip.isNotEmpty
          ? double.tryParse(_currentHandGrip.replaceAll(',', '.'))
          : null;

      print(
        'Saving weight entry for date: ${_selectedWeightDate.toIso8601String()}',
      );
      print('Weight value being saved: $weightInKg kg');

      // FIXED: Save weight entry with selected date using upsert to prevent duplicates
      await _bodyMetricsService.saveWeightEntry(
        weightKg: weightInKg,
        waistCircumferenceCm: waistCircumference,
        hipCircumferenceCm: hipCircumference,
        leanMassKg: leanMass,
        fatMassKg: fatMass,
        cellularMassKg: cellularMass,
        phaseAngleDegrees: phaseAngle,
        handGripStrengthKg: handGrip,
        notes: _notes.isNotEmpty ? _notes : null,
        recordedAt:
            _selectedWeightDate, // This will be normalized to date in the service
      );

      print('Weight entry saved successfully');

      // Update medical profile with new weight only
      // DO NOT update daily_caloric_intake - let the database trigger handle it
      // The trigger will preserve manual targets and auto-calculate only when needed
      try {
        await ProfileService.instance.updateMedicalProfile({
          'current_weight_kg': weightInKg,
        });
        print('Updated current_weight_kg to $weightInKg kg');
      } catch (error) {
        print('Failed to update weight in medical profile: $error');
      }

      // Update medical profile if height is provided
      if (_currentHeight.isNotEmpty) {
        final height = double.tryParse(_currentHeight.replaceAll(',', '.'));
        if (height != null && height > 0) {
          final heightInCm = _isHeightInFeet ? height * 30.48 : height;
          await _bodyMetricsService.updateMedicalProfile(
            heightCm: heightInCm,
            currentWeightKg: weightInKg,
          );
        }
      }

      // FIXED: Increased delay to ensure database sync completes before reload
      print('Waiting for database sync...');
      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadBodyMetricsData();

      // FIXED: Also refresh the current date range to include the new entry
      await _loadWeightDataForRange(_selectedDateRange);

      HapticFeedback.lightImpact();

      // FIXED: Show success message with selected date indicating upsert behavior
      final dateText = _formatWeightSelectedDate();
      final isToday = _selectedWeightDate.year == DateTime.now().year &&
          _selectedWeightDate.month == DateTime.now().month &&
          _selectedWeightDate.day == DateTime.now().day;

      _showSuccessSnackBar(
        isToday
            ? 'Metriche corporee salvate per oggi con successo!'
            : 'Metriche corporee salvate per $dateText con successo!',
      );

      // FIXED: Don't clear form fields - the reload from database will populate them
      // This allows users to see what they just saved and provides better UX
      // The _loadBodyMetricsData() call above already refreshed the data from database

      // REMOVED: Auto navigation to dashboard - let user stay on metrics screen
      // User can manually navigate using bottom navigation if desired
    } catch (error) {
      print('Error saving weight entry: $error');
      _showErrorSnackBar('Errore nel salvare le metriche: ${error.toString()}');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Widget _buildBMIDisplay() {
    double? bmi;
    String bmiCategory = 'Non Disponibile';

    if (_currentWeight.isNotEmpty && _currentHeight.isNotEmpty) {
      final weight = double.tryParse(_currentWeight);
      final height = double.tryParse(_currentHeight);

      if (weight != null && height != null && height > 0) {
        final weightInKg = _isWeightInLbs ? weight / 2.20462 : weight;
        final heightInCm = _isHeightInFeet ? height * 30.48 : height;

        bmi = _bodyMetricsService.calculateBMI(
          weightKg: weightInKg,
          heightCm: heightInCm,
        );

        if (bmi != null) {
          bmiCategory = _bodyMetricsService.getBMICategory(bmi);
        }
      }
    }

    return BMIDisplayCard(bmiValue: bmi, bmiCategory: bmiCategory);
  }

  Widget _buildSaveButton() {
    final canSave = _currentWeight.isNotEmpty;
    return GestureDetector(
      onTap: canSave && !_isSaving ? _handleSaveEntry : null,
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
          child: _isSaving
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
                      'Salvando...',
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
                      iconName: 'save',
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Salva Metriche',
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

  void _showWeightInputDialog() {
    final controller = TextEditingController(text: _currentWeight);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Peso',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Peso (${_isWeightInLbs ? 'lbs' : 'kg'})',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentWeight = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHeightInputDialog() {
    final controller = TextEditingController(text: _currentHeight);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Inserisci Altezza',
          style: TextStyle(
            fontSize: 16.sp,
            color: AppTheme.seaDeep,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: _isHeightInFeet ? 'Altezza (ft)' : 'Altezza (cm)',
                labelStyle: TextStyle(color: AppTheme.seaMid),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppTheme.seaMid, width: 2),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annulla',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seaMid,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              setState(() {
                _currentHeight = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Salva', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CustomIconWidget(
              iconName: 'check_circle',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CustomIconWidget(
              iconName: 'error',
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }
}
