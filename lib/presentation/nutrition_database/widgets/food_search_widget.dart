import 'package:flutter/material.dart';

import '../../../services/nutrition_database_service.dart';

class FoodSearchWidget extends StatefulWidget {
  final Function(String, {String? category}) onSearch;
  final List<Map<String, dynamic>> recentFoods;

  const FoodSearchWidget({
    Key? key,
    required this.onSearch,
    required this.recentFoods,
  }) : super(key: key);

  @override
  State<FoodSearchWidget> createState() => _FoodSearchWidgetState();
}

class _FoodSearchWidgetState extends State<FoodSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final NutritionDatabaseService _nutritionService =
      NutritionDatabaseService.instance;

  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty || _selectedCategory != null) {
      widget.onSearch(query, category: _selectedCategory);
      setState(() => _showSuggestions = false);
    }
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    try {
      final suggestions = await _nutritionService.searchFoods(
        searchQuery: query,
        limit: 8,
      );

      setState(() {
        _suggestions = suggestions;
        _showSuggestions = true;
      });
    } catch (e) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input field
        Container(
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
            controller: _searchController,
            onChanged: _getSuggestions,
            onSubmitted: (_) => _performSearch(),
            decoration: InputDecoration(
              hintText: 'Cerca alimenti, ingredienti o ricette...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _suggestions = [];
                            _showSuggestions = false;
                          });
                        },
                        icon: Icon(Icons.clear, color: Colors.grey[600]),
                      )
                      : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),

        // Category filter chips
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryChip('Tutti', null),
              const SizedBox(width: 8),
              _buildCategoryChip('Verdure', '2001'),
              const SizedBox(width: 8),
              _buildCategoryChip('Frutta', '4001'),
              const SizedBox(width: 8),
              _buildCategoryChip('Cereali', '1001'),
              const SizedBox(width: 8),
              _buildCategoryChip('Legumi', '3001'),
              const SizedBox(width: 8),
              _buildCategoryChip('Noci', '4003'),
            ],
          ),
        ),

        // Search suggestions
        if (_showSuggestions && _suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
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
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];
                return ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.food_bank_outlined,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  title: Text(
                    suggestion['english_name'] ??
                        suggestion['italian_name'] ??
                        'Unknown',
                    style: const TextStyle(fontSize: 14),
                  ),
                  subtitle:
                      suggestion['italian_name'] != null &&
                              suggestion['english_name'] !=
                                  suggestion['italian_name']
                          ? Text(
                            suggestion['italian_name'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          )
                          : null,
                  onTap: () {
                    _searchController.text =
                        suggestion['english_name'] ??
                        suggestion['italian_name'] ??
                        '';
                    _performSearch();
                  },
                );
              },
            ),
          ),
        ],

        // Recent foods section
        if (widget.recentFoods.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Alimenti Recenti',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  widget.recentFoods
                      .map((food) => _buildRecentFoodChip(food))
                      .toList(),
            ),
          ),
        ],

        // Quick search buttons
        const SizedBox(height: 16),
        Text(
          'Ricerca Rapida',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickSearchButton('Proteine Alte', Icons.fitness_center, () {
              _searchController.text = 'proteine';
              widget.onSearch('proteine');
            }),
            _buildQuickSearchButton(
              'Poche Calorie',
              Icons.local_fire_department,
              () {
                _searchController.text = 'basso calorico';
                widget.onSearch('basso calorico');
              },
            ),
            _buildQuickSearchButton('Ricco di Fibre', Icons.eco, () {
              _searchController.text = 'fibre';
              widget.onSearch('fibre');
            }),
            _buildQuickSearchButton('Vitamina C', Icons.local_pharmacy, () {
              _searchController.text = 'vitamina c';
              widget.onSearch('vitamina c');
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String? categoryCode) {
    final isSelected = _selectedCategory == categoryCode;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = isSelected ? null : categoryCode;
        });
        _performSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoodChip(Map<String, dynamic> food) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          _searchController.text =
              food['english_name'] ?? food['italian_name'] ?? '';
          _performSearch();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.history, size: 16, color: Colors.blue[700]),
              const SizedBox(width: 4),
              Text(
                food['english_name'] ?? food['italian_name'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSearchButton(
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
