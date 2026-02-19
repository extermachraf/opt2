import 'package:flutter/material.dart';

class FoodCategoriesWidget extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String) onCategorySelected;

  const FoodCategoriesWidget({
    Key? key,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categorie Alimentari',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Esplora gli alimenti per categoria nutrizionale',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(
                  context,
                  category['code'],
                  category['description'],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String code,
    String description,
  ) {
    final categoryInfo = _getCategoryInfo(code);

    return GestureDetector(
      onTap: () => onCategorySelected(code),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryInfo['color']!.withAlpha(204),
                categoryInfo['color']!,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(categoryInfo['icon'], size: 40, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Codice: $code',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(String code) {
    switch (code) {
      case '1001':
        return {'icon': Icons.eco, 'color': Colors.brown};
      case '2001':
        return {'icon': Icons.local_florist, 'color': Colors.green};
      case '2003':
        return {'icon': Icons.grass, 'color': Colors.orange};
      case '2004':
        return {'icon': Icons.local_grocery_store, 'color': Colors.lightGreen};
      case '2005':
        return {'icon': Icons.help_outline, 'color': Colors.purple};
      case '2006':
        return {'icon': Icons.local_drink, 'color': Colors.teal};
      case '2007':
        return {'icon': Icons.forest, 'color': Colors.brown[600]!};
      case '2008':
        return {'icon': Icons.help_outline, 'color': Colors.green[700]!};
      case '2009':
        return {'icon': Icons.agriculture, 'color': Colors.red};
      case '2010':
        return {'icon': Icons.storage, 'color': Colors.amber};
      case '2011':
        return {'icon': Icons.waves, 'color': Colors.teal[800]!};
      case '3000':
        return {'icon': Icons.help_outline, 'color': Colors.green[500]!};
      case '3001':
        return {'icon': Icons.grain, 'color': Colors.brown[400]!};
      case '3002':
        return {'icon': Icons.help_outline, 'color': Colors.yellow[800]!};
      case '3004':
        return {'icon': Icons.help_outline, 'color': Colors.yellow[700]!};
      case '4001':
        return {'icon': Icons.apple, 'color': Colors.red[400]!};
      case '4002':
        return {'icon': Icons.food_bank, 'color': Colors.orange[600]!};
      case '4003':
        return {'icon': Icons.help_outline, 'color': Colors.brown[500]!};
      default:
        return {'icon': Icons.food_bank_outlined, 'color': Colors.grey[600]!};
    }
  }
}

// Custom icon for nuts since it doesn't exist in Material Icons
extension CustomIcons on Icons {
  static const IconData nuts_outlined = Icons.scatter_plot_outlined;
  static const IconData soy_outlined = Icons.scatter_plot;
  static const IconData baking_outlined = Icons.bakery_dining_outlined;
  static const IconData salad_outlined = Icons.local_dining;
  static const IconData onion_outlined = Icons.circle_outlined;
  static const IconData mix_outlined = Icons.blender;
}
