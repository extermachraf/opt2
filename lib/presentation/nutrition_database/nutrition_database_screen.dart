import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/nutrition_database_service.dart';
import './widgets/food_categories_widget.dart';
import './widgets/food_comparison_widget.dart';
import './widgets/food_search_widget.dart';
import './widgets/nutrition_breakdown_widget.dart';

class NutritionDatabaseScreen extends StatefulWidget {
  const NutritionDatabaseScreen({Key? key}) : super(key: key);

  @override
  State<NutritionDatabaseScreen> createState() =>
      _NutritionDatabaseScreenState();
}

class _NutritionDatabaseScreenState extends State<NutritionDatabaseScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final NutritionDatabaseService _nutritionService =
      NutritionDatabaseService.instance;

  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _foodCategories = [];
  List<Map<String, dynamic>> _recentFoods = [];
  Map<String, dynamic>? _selectedFoodDetails;
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _nutritionService.getFoodCategories();
      final recentFoods = await _nutritionService.getRecentlyUsedFoods();
      final initialSearch = await _nutritionService.searchFoods(limit: 20);

      setState(() {
        _foodCategories = categories;
        _recentFoods = recentFoods;
        _searchResults = initialSearch;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load nutrition database: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _performSearch(String query, {String? category}) async {
    if (query.trim().isEmpty && category == null) return;

    setState(() => _isLoading = true);
    try {
      final results = await _nutritionService.searchFoods(
        searchQuery: query,
        categoryFilter: category,
        limit: 50,
      );

      setState(() {
        _searchResults = results;
        _searchQuery = query;
      });
    } catch (e) {
      _showErrorSnackBar('Search failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFoodDetails(String foodId) async {
    try {
      final details = await _nutritionService.getFoodDetails(foodId);
      setState(() => _selectedFoodDetails = details);
    } catch (e) {
      _showErrorSnackBar('Failed to load food details: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Database Nutrizionale',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.search), text: 'Ricerca'),
            Tab(icon: Icon(Icons.category), text: 'Categorie'),
            Tab(icon: Icon(Icons.analytics), text: 'Analisi'),
            Tab(icon: Icon(Icons.compare), text: 'Confronta'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSearchTab(),
                    _buildCategoriesTab(),
                    _buildAnalysisTab(),
                    _buildComparisonTab(),
                  ],
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[50],
          child: FoodSearchWidget(
            onSearch: _performSearch,
            recentFoods: _recentFoods,
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final food = _searchResults[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    food['english_name'] ??
                        food['italian_name'] ??
                        'Unknown Food',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (food['italian_name'] != null &&
                          food['english_name'] != food['italian_name'])
                        Text(
                          food['italian_name'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildNutrientChip(
                            '${food['calories_per_100g']} kcal',
                            Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          _buildNutrientChip(
                            '${food['protein_per_100g']}g proteine',
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                  onTap: () => _showFoodDetailsDialog(food),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriesTab() {
    return FoodCategoriesWidget(
      categories: _foodCategories,
      onCategorySelected: (categoryCode) {
        _performSearch('', category: categoryCode);
        _tabController.animateTo(0); // Switch to search tab
      },
    );
  }

  Widget _buildAnalysisTab() {
    return _selectedFoodDetails != null
        ? NutritionBreakdownWidget(foodDetails: _selectedFoodDetails!)
        : const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Seleziona un alimento per vedere\nl\'analisi nutrizionale dettagliata',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        );
  }

  Widget _buildComparisonTab() {
    return const FoodComparisonWidget();
  }

  Widget _buildNutrientChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _showFoodDetailsDialog(Map<String, dynamic> food) async {
    await _loadFoodDetails(food['id']);

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 600, maxWidth: 400),
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food['english_name'] ??
                              food['italian_name'] ??
                              'Food Details',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedFoodDetails != null) ...[
                    _buildDetailRow(
                      'Codice Alimento',
                      _selectedFoodDetails!['food_code'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Nome Scientifico',
                      _selectedFoodDetails!['scientific_name'] ?? 'N/A',
                    ),
                    _buildDetailRow(
                      'Parte Edibile',
                      '${_selectedFoodDetails!['edible_portion_percent'] ?? 100}%',
                    ),
                    const Divider(height: 24),
                    const Text(
                      'Valori Nutrizionali (per 100g)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildNutrientGrid(),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(
                              () => _selectedFoodDetails = _selectedFoodDetails,
                            );
                            Navigator.pop(context);
                            _tabController.animateTo(2); // Go to analysis tab
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Analisi Dettagliata',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientGrid() {
    if (_selectedFoodDetails == null) return const SizedBox.shrink();

    final nutrients = [
      {
        'label': 'Calorie',
        'value': '${_selectedFoodDetails!['calories_per_100g']} kcal',
      },
      {
        'label': 'Proteine',
        'value': '${_selectedFoodDetails!['protein_per_100g']}g',
      },
      {
        'label': 'Carboidrati',
        'value': '${_selectedFoodDetails!['carbs_per_100g']}g',
      },
      {'label': 'Grassi', 'value': '${_selectedFoodDetails!['fat_per_100g']}g'},
      {
        'label': 'Fibre',
        'value': '${_selectedFoodDetails!['fiber_per_100g']}g',
      },
      {
        'label': 'Sodio',
        'value': '${_selectedFoodDetails!['sodium_per_100g']}mg',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: nutrients.length,
      itemBuilder: (context, index) {
        final nutrient = nutrients[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                nutrient['label']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                nutrient['value']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
