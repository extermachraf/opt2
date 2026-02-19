import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/nutrition_database_service.dart';

class NutritionBreakdownWidget extends StatefulWidget {
  final Map<String, dynamic> foodDetails;

  const NutritionBreakdownWidget({Key? key, required this.foodDetails})
    : super(key: key);

  @override
  State<NutritionBreakdownWidget> createState() =>
      _NutritionBreakdownWidgetState();
}

class _NutritionBreakdownWidgetState extends State<NutritionBreakdownWidget> {
  final NutritionDatabaseService _nutritionService =
      NutritionDatabaseService.instance;

  double _portionSize = 100.0;
  Map<String, dynamic>? _nutritionalBreakdown;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNutritionalBreakdown();
  }

  Future<void> _loadNutritionalBreakdown() async {
    setState(() => _isLoading = true);
    try {
      final breakdown = await _nutritionService.getNutritionalBreakdown(
        widget.foodDetails['id'],
        portionGrams: _portionSize,
      );
      setState(() => _nutritionalBreakdown = breakdown);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load nutritional breakdown: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food header
          _buildFoodHeader(),
          const SizedBox(height: 24),

          // Portion size selector
          _buildPortionSelector(),
          const SizedBox(height: 24),

          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_nutritionalBreakdown != null) ...[
            // Macronutrients chart
            _buildMacronutrientsChart(),
            const SizedBox(height: 24),

            // Detailed breakdown
            _buildDetailedBreakdown(),
            const SizedBox(height: 24),

            // Vitamins section
            _buildVitaminsSection(),
            const SizedBox(height: 24),

            // Minerals section
            _buildMineralsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.foodDetails['english_name'] ??
                  widget.foodDetails['italian_name'] ??
                  'Unknown Food',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            if (widget.foodDetails['italian_name'] != null &&
                widget.foodDetails['english_name'] !=
                    widget.foodDetails['italian_name']) ...[
              const SizedBox(height: 4),
              Text(
                widget.foodDetails['italian_name'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (widget.foodDetails['scientific_name'] != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.foodDetails['scientific_name'],
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  'Codice',
                  widget.foodDetails['food_code'] ?? 'N/A',
                ),
                const SizedBox(width: 12),
                _buildInfoChip(
                  'Edibile',
                  '${widget.foodDetails['edible_portion_percent'] ?? 100}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildPortionSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dimensione Porzione',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _portionSize,
                    min: 10,
                    max: 500,
                    divisions: 49,
                    label: '${_portionSize.round()}g',
                    onChanged: (value) {
                      setState(() => _portionSize = value);
                      _loadNutritionalBreakdown();
                    },
                  ),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_portionSize.round()}g',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickPortionButton('50g', 50),
                _buildQuickPortionButton('100g', 100),
                _buildQuickPortionButton('200g', 200),
                _buildQuickPortionButton('300g', 300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPortionButton(String label, double grams) {
    return GestureDetector(
      onTap: () {
        setState(() => _portionSize = grams);
        _loadNutritionalBreakdown();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:
              _portionSize == grams
                  ? Theme.of(context).primaryColor
                  : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _portionSize == grams ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildMacronutrientsChart() {
    if (_nutritionalBreakdown == null ||
        _nutritionalBreakdown!['macronutrients'] == null) {
      return const SizedBox.shrink();
    }

    final macros = _nutritionalBreakdown!['macronutrients'];
    final protein = (macros['protein_g'] ?? 0.0).toDouble();
    final carbs = (macros['carbs_g'] ?? 0.0).toDouble();
    final fat = (macros['fat_g'] ?? 0.0).toDouble();

    final total = protein + carbs + fat;
    if (total == 0) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribuzione Macronutrienti',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: protein,
                      title: '${(protein / total * 100).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: carbs,
                      title: '${(carbs / total * 100).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: fat,
                      title: '${(fat / total * 100).toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(
                  'Proteine',
                  '${protein.toStringAsFixed(1)}g',
                  Colors.blue,
                ),
                _buildLegendItem(
                  'Carboidrati',
                  '${carbs.toStringAsFixed(1)}g',
                  Colors.orange,
                ),
                _buildLegendItem(
                  'Grassi',
                  '${fat.toStringAsFixed(1)}g',
                  Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildDetailedBreakdown() {
    if (_nutritionalBreakdown == null ||
        _nutritionalBreakdown!['macronutrients'] == null) {
      return const SizedBox.shrink();
    }

    final macros = _nutritionalBreakdown!['macronutrients'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informazioni Nutrizionali Dettagliate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildNutrientRow(
              'Calorie',
              '${macros['calories']?.toStringAsFixed(0) ?? '0'} kcal',
              Icons.local_fire_department,
            ),
            _buildNutrientRow(
              'Proteine',
              '${macros['protein_g']?.toStringAsFixed(1) ?? '0'}g',
              Icons.fitness_center,
            ),
            _buildNutrientRow(
              'Carboidrati',
              '${macros['carbs_g']?.toStringAsFixed(1) ?? '0'}g',
              Icons.grain,
            ),
            _buildNutrientRow(
              'Grassi',
              '${macros['fat_g']?.toStringAsFixed(1) ?? '0'}g',
              Icons.opacity,
            ),
            _buildNutrientRow(
              'Fibre',
              '${macros['fiber_g']?.toStringAsFixed(1) ?? '0'}g',
              Icons.eco,
            ),
            _buildNutrientRow(
              'Acqua',
              '${macros['water_g']?.toStringAsFixed(1) ?? '0'}g',
              Icons.water_drop,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(String nutrient, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nutrient,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitaminsSection() {
    if (_nutritionalBreakdown == null ||
        _nutritionalBreakdown!['vitamins'] == null) {
      return const SizedBox.shrink();
    }

    final vitamins = _nutritionalBreakdown!['vitamins'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vitamine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              children: [
                _buildVitaminTile(
                  'Vitamina A',
                  '${vitamins['vitamin_a_mcg']?.toStringAsFixed(1) ?? '0'} mcg',
                ),
                _buildVitaminTile(
                  'Vitamina B1',
                  '${vitamins['vitamin_b1_mg']?.toStringAsFixed(2) ?? '0'} mg',
                ),
                _buildVitaminTile(
                  'Vitamina B2',
                  '${vitamins['vitamin_b2_mg']?.toStringAsFixed(2) ?? '0'} mg',
                ),
                _buildVitaminTile(
                  'Vitamina C',
                  '${vitamins['vitamin_c_mg']?.toStringAsFixed(1) ?? '0'} mg',
                ),
                _buildVitaminTile(
                  'Vitamina D',
                  '${vitamins['vitamin_d_mcg']?.toStringAsFixed(1) ?? '0'} mcg',
                ),
                _buildVitaminTile(
                  'Folato',
                  '${vitamins['folate_mcg']?.toStringAsFixed(1) ?? '0'} mcg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitaminTile(String name, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMineralsSection() {
    if (_nutritionalBreakdown == null ||
        _nutritionalBreakdown!['minerals'] == null) {
      return const SizedBox.shrink();
    }

    final minerals = _nutritionalBreakdown!['minerals'];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Minerali',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
              children: [
                _buildMineralTile(
                  'Calcio',
                  '${minerals['calcium_mg']?.toStringAsFixed(1) ?? '0'} mg',
                ),
                _buildMineralTile(
                  'Ferro',
                  '${minerals['iron_mg']?.toStringAsFixed(1) ?? '0'} mg',
                ),
                _buildMineralTile(
                  'Potassio',
                  '${minerals['potassium_mg']?.toStringAsFixed(0) ?? '0'} mg',
                ),
                _buildMineralTile(
                  'Sodio',
                  '${minerals['sodium_mg']?.toStringAsFixed(0) ?? '0'} mg',
                ),
                _buildMineralTile(
                  'Zinco',
                  '${minerals['zinc_mg']?.toStringAsFixed(1) ?? '0'} mg',
                ),
                _buildMineralTile(
                  'Fosforo',
                  '${minerals['phosphorus_mg']?.toStringAsFixed(1) ?? '0'} mg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMineralTile(String name, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            name,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue[700],
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
