import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../services/nutrition_database_service.dart';

class FoodComparisonWidget extends StatefulWidget {
  const FoodComparisonWidget({Key? key}) : super(key: key);

  @override
  State<FoodComparisonWidget> createState() => _FoodComparisonWidgetState();
}

class _FoodComparisonWidgetState extends State<FoodComparisonWidget> {
  final NutritionDatabaseService _nutritionService =
      NutritionDatabaseService.instance;

  List<Map<String, dynamic>> _selectedFoods = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _comparisonData;
  bool _isLoading = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Confronta Alimenti',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Seleziona fino a 4 alimenti per confrontare i loro valori nutrizionali',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Search bar
          _buildSearchBar(),
          const SizedBox(height: 16),

          // Search results
          if (_isSearching && _searchResults.isNotEmpty) _buildSearchResults(),

          // Selected foods
          if (_selectedFoods.isNotEmpty) ...[
            _buildSelectedFoods(),
            const SizedBox(height: 20),
          ],

          // Comparison chart and data
          if (_selectedFoods.length >= 2) ...[
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildComparisonView(),
            ),
          ] else
            Expanded(child: _buildEmptyState()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: _searchFoods,
        decoration: InputDecoration(
          hintText: 'Cerca alimenti da confrontare...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final food = _searchResults[index];
          final isSelected = _selectedFoods.any((f) => f['id'] == food['id']);

          return ListTile(
            title: Text(
              food['english_name'] ?? food['italian_name'] ?? 'Unknown',
              style: const TextStyle(fontSize: 14),
            ),
            subtitle: Text(
              '${food['calories_per_100g']} kcal, ${food['protein_per_100g']}g proteine',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing:
                isSelected
                    ? Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    )
                    : const Icon(Icons.add_circle_outline, color: Colors.grey),
            onTap: isSelected ? null : () => _addFoodToComparison(food),
            enabled: !isSelected && _selectedFoods.length < 4,
          );
        },
      ),
    );
  }

  Widget _buildSelectedFoods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Alimenti Selezionati',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (_selectedFoods.length >= 2)
              ElevatedButton.icon(
                onPressed: _performComparison,
                icon: const Icon(Icons.compare_arrows, size: 18),
                label: const Text('Confronta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedFoods.map((food) => _buildFoodChip(food)).toList(),
        ),
      ],
    );
  }

  Widget _buildFoodChip(Map<String, dynamic> food) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            food['english_name'] ?? food['italian_name'] ?? 'Unknown',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _removeFoodFromComparison(food),
            child: Icon(
              Icons.close,
              size: 16,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonView() {
    if (_comparisonData == null) return const SizedBox.shrink();

    final foods = _comparisonData!['foods'] as List<dynamic>;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calories comparison chart
          _buildComparisonChart(
            'Confronto Calorie (per 100g)',
            foods,
            'calories_per_100g',
            'kcal',
            Colors.orange,
          ),
          const SizedBox(height: 24),

          // Protein comparison chart
          _buildComparisonChart(
            'Confronto Proteine (per 100g)',
            foods,
            'protein_per_100g',
            'g',
            Colors.blue,
          ),
          const SizedBox(height: 24),

          // Detailed comparison table
          _buildComparisonTable(foods),
        ],
      ),
    );
  }

  Widget _buildComparisonChart(
    String title,
    List<dynamic> foods,
    String nutrientKey,
    String unit,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxValue(foods, nutrientKey) * 1.2,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final food = foods[groupIndex];
                        final value =
                            food[nutrientKey]?.toStringAsFixed(1) ?? '0';
                        return BarTooltipItem(
                          '${food['english_name'] ?? food['italian_name']}\n$value $unit',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < foods.length) {
                            final food = foods[value.toInt()];
                            final name =
                                food['english_name'] ??
                                food['italian_name'] ??
                                'Unknown';
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                name.length > 10
                                    ? '${name.substring(0, 10)}...'
                                    : name,
                                style: const TextStyle(fontSize: 10),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups:
                      foods.asMap().entries.map((entry) {
                        final index = entry.key;
                        final food = entry.value;
                        final value = (food[nutrientKey] ?? 0).toDouble();

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: value,
                              color: color,
                              width: 20,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(List<dynamic> foods) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tabella di Confronto Dettagliata',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns:
                    [
                      const DataColumn(label: Text('Nutriente')),
                      ...foods.map(
                        (food) => DataColumn(
                          label: SizedBox(
                            width: 80,
                            child: Text(
                              food['english_name'] ??
                                  food['italian_name'] ??
                                  'Unknown',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ].toList(),
                rows: [
                  _buildTableRow('Calorie (kcal)', foods, 'calories_per_100g'),
                  _buildTableRow('Proteine (g)', foods, 'protein_per_100g'),
                  _buildTableRow('Carboidrati (g)', foods, 'carbs_per_100g'),
                  _buildTableRow('Grassi (g)', foods, 'fat_per_100g'),
                  _buildTableRow('Fibre (g)', foods, 'fiber_per_100g'),
                  _buildTableRow('Calcio (mg)', foods, 'calcium_mg'),
                  _buildTableRow('Ferro (mg)', foods, 'iron_mg'),
                  _buildTableRow('Potassio (mg)', foods, 'potassium_mg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildTableRow(String nutrientName, List<dynamic> foods, String key) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            nutrientName,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ...foods.map(
          (food) => DataCell(
            Text(
              (food[key] ?? 0).toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.compare_arrows, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Confronta Alimenti',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Seleziona almeno 2 alimenti\nper iniziare il confronto',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  double _getMaxValue(List<dynamic> foods, String key) {
    double max = 0;
    for (var food in foods) {
      final value = (food[key] ?? 0).toDouble();
      if (value > max) max = value;
    }
    return max;
  }

  Future<void> _searchFoods(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _nutritionService.searchFoods(
        searchQuery: query,
        limit: 20,
      );

      setState(() {
        _searchResults = results;
        _searchQuery = query;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      setState(() {
        _searchResults = [];
      });
    }
  }

  void _addFoodToComparison(Map<String, dynamic> food) {
    if (_selectedFoods.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puoi confrontare al massimo 4 alimenti')),
      );
      return;
    }

    setState(() {
      _selectedFoods.add(food);
      _isSearching = false;
      _searchResults = [];
    });

    if (_selectedFoods.length >= 2) {
      _performComparison();
    }
  }

  void _removeFoodFromComparison(Map<String, dynamic> food) {
    setState(() {
      _selectedFoods.removeWhere((f) => f['id'] == food['id']);
      if (_selectedFoods.length < 2) {
        _comparisonData = null;
      } else {
        _performComparison();
      }
    });
  }

  Future<void> _performComparison() async {
    if (_selectedFoods.length < 2) return;

    setState(() => _isLoading = true);

    try {
      final foodIds = _selectedFoods.map((f) => f['id'].toString()).toList();
      final comparison = await _nutritionService.compareFoods(foodIds);

      setState(() => _comparisonData = comparison);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comparison failed: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
