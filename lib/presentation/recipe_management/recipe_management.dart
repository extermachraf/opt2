import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/recipe_service.dart';
import '../dashboard/widgets/quick_action_sheet_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chips_widget.dart';
import './widgets/recipe_card_widget.dart';
import './widgets/search_bar_widget.dart';

class RecipeManagement extends StatefulWidget {
  const RecipeManagement({Key? key}) : super(key: key);

  @override
  State<RecipeManagement> createState() => _RecipeManagementState();
}

class _RecipeManagementState extends State<RecipeManagement>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();

  List<String> _activeFilters = [];
  bool _isRefreshing = false;
  bool _isVoiceSearchActive = false;
  bool _isLoading = true;
  String _searchQuery = '';
  String? _currentUserId;

  List<Map<String, dynamic>> _allRecipes = [];
  List<Map<String, dynamic>> _filteredRecipes = [];
  List<String> _favoriteRecipeIds = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _requestPermissions();
    _getCurrentUser();
    _loadRecipes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _getCurrentUser() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user != null) {
        _currentUserId = user.id;
        await _loadFavorites();
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  Future<void> _loadFavorites() async {
    if (_currentUserId == null) return;

    try {
      final favoriteRecipes = await RecipeService.instance.getFavoriteRecipes(
        _currentUserId!,
      );
      setState(() {
        _favoriteRecipeIds =
            favoriteRecipes.map((recipe) => recipe['id'] as String).toList();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      await Permission.camera.request();
      await Permission.microphone.request();
    }
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // CRITICAL FIX: Increased limit from 100 to 500
      // Database has 175 public recipes but app was only loading 100
      // 75 recipes were missing! Now loads all recipes with margin for future additions
      final recipes = await RecipeService.instance.getRecipes(limit: 500);
      setState(() {
        _allRecipes = recipes.map((recipe) {
          // Transform database recipe to match existing UI structure
          final tags = (recipe['recipe_tags'] as List?)
                  ?.map((tag) => tag['tag_name'] as String)
                  .toList() ??
              [];

          return {
            'id': recipe['id'],
            'title': recipe['title'] ?? 'Ricetta Senza Nome',
            'imageUrl': recipe['image_url'],
            'image_url': recipe['image_url'],
            'prepTime': recipe['prep_time_minutes'] ?? 0,
            'prep_time_minutes': recipe['prep_time_minutes'] ?? 0,
            'cookTime': recipe['cook_time_minutes'] ?? 0,
            'cook_time_minutes': recipe['cook_time_minutes'] ?? 0,
            'servings': recipe['servings'] ?? 1,
            'difficulty': _formatDifficulty(recipe['difficulty']),
            'raw_difficulty':
                recipe['difficulty'], // Keep original for filtering
            'isFavorite': _favoriteRecipeIds.contains(recipe['id']),
            'category': _formatCategory(recipe['category']),
            'raw_category': recipe['category'], // Keep original for filtering
            'tags': tags,
            'author': 'Public', // All database recipes are public for now
            'lastUsed': DateTime.parse(recipe['created_at']),
            'ingredients': [], // Can be loaded separately when needed
            'calories': recipe['total_calories'] ?? 0,
            'total_calories': recipe['total_calories'] ?? 0,
            'protein': (recipe['total_protein_g'] ?? 0.0).toDouble(),
            'total_protein_g': recipe['total_protein_g'] ?? 0.0,
            'total_carbs_g': recipe['total_carbs_g'] ?? 0.0,
            'total_fat_g': recipe['total_fat_g'] ?? 0.0,
            'total_fiber_g': recipe['total_fiber_g'] ?? 0.0,
            'description': recipe['description'] ?? '',
            'instructions': recipe['instructions'] ?? '',
            'created_at': recipe['created_at'],
            'is_public': recipe['is_public'] ?? true,
            'is_verified': recipe['is_verified'] ?? false,
            'total_weight_g': recipe['total_weight_g'],
            'calories_per_100g': recipe['calories_per_100g'],
          };
        }).toList();
        _filteredRecipes = List.from(_allRecipes);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel caricamento ricette: $e')),
        );
      }
    }
  }

  String _formatDifficulty(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return 'Facile';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Difficile';
      default:
        return 'Facile';
    }
  }

  String _formatCategory(String? category) {
    switch (category?.toLowerCase()) {
      case 'breakfast':
        return 'Colazione';
      case 'lunch':
        return 'Pranzo';
      case 'dinner':
        return 'Cena';
      case 'snack':
        return 'Spuntino';
      case 'dessert':
        return 'Dolce';
      case 'beverage':
        return 'Bevanda';
      case 'supplement':
        return 'Integratore';
      default:
        return 'Spuntino';
    }
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final title = (recipe['title'] as String).toLowerCase();
          final tags = (recipe['tags'] as List).join(' ').toLowerCase();
          final description = (recipe['description'] as String).toLowerCase();

          if (!title.contains(query) &&
              !tags.contains(query) &&
              !description.contains(query)) {
            return false;
          }
        }

        // Active filters
        if (_activeFilters.isNotEmpty) {
          for (String filter in _activeFilters) {
            switch (filter) {
              // Source filters
              case 'Le Mie Ricette':
                if (recipe['author'] != 'Personal') return false;
                break;
              case 'Preferiti':
                if (!(recipe['isFavorite'] as bool)) return false;
                break;
              case 'Biblioteca Pubblica':
                if (recipe['author'] != 'Public') return false;
                break;
              case 'Usate di Recente':
                final lastUsed = recipe['lastUsed'] as DateTime;
                if (DateTime.now().difference(lastUsed).inDays > 7)
                  return false;
                break;

              // Collection filters (from Collections tab)
              case 'I Miei Preferiti':
                if (!(recipe['isFavorite'] as bool)) return false;
                break;
              case 'Italiane':
                final tags = recipe['tags'] as List<String>;
                if (!tags.contains('Italian')) return false;
                break;
              case 'Pasti Veloci':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime > 15) return false;
                break;
              case 'Grigliate':
                final tags = recipe['tags'] as List<String>;
                if (!tags.contains('Grilled')) return false;
                break;
              case 'Dolci':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'dessert') return false;
                break;

              // Meal type filters (match database enum values)
              case 'Colazione':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'breakfast') return false;
                break;
              case 'Pranzo':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'lunch') return false;
                break;
              case 'Cena':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'dinner') return false;
                break;
              case 'Spuntino':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'snack') return false;
                break;
              case 'Frullato':
              case 'Integratore':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != filter.toLowerCase())
                  return false;
                break;

              // Difficulty filters (match database enum values)
              case 'Facile':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'easy') return false;
                break;
              case 'Medio':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'medium') return false;
                break;
              case 'Difficile':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'hard') return false;
                break;

              // Time-based filters
              case 'Sotto i 15 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime >= 15) return false;
                break;
              case '15-30 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime < 15 || prepTime > 30) return false;
                break;
              case '30-60 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime < 30 || prepTime > 60) return false;
                break;
              case 'Oltre 1 ora':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime <= 60) return false;
                break;

              // Dietary restriction filters (tag-based)
              case 'Poco Sodio':
              case 'Ricche di Proteine':
              case 'Cibi Morbidi':
              case 'Anti-Nausea':
              case 'Senza Latticini':
              case 'Senza Glutine':
                final tags = recipe['tags'] as List<String>;
                // Check if tag exists (can be enhanced with proper tag mapping)
                final tagFound = tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(filter.toLowerCase()) ||
                      _mapDietaryFilter(filter).any(
                        (mappedTag) => tags.any(
                          (recipeTag) => recipeTag.toLowerCase().contains(
                                mappedTag.toLowerCase(),
                              ),
                        ),
                      ),
                );
                if (!tagFound) return false;
                break;

              default:
                // Check if filter matches category or tags directly
                final tags = recipe['tags'] as List<String>;
                final category = recipe['category'] as String;
                if (!tags.contains(filter) && category != filter) return false;
                break;
            }
          }
        }

        return true;
      }).toList();
    });
  }

  // Helper method to map dietary filters to potential tag names
  List<String> _mapDietaryFilter(String filter) {
    switch (filter) {
      case 'Poco Sodio':
        return ['Low Sodium', 'Healthy', 'Heart Friendly'];
      case 'Ricche di Proteine':
        return ['High Protein', 'Protein', 'Fitness'];
      case 'Senza Latticini':
        return ['Dairy Free', 'Lactose Free', 'Vegan'];
      case 'Senza Glutine':
        return ['Gluten Free', 'Celiac', 'GF'];
      default:
        return [filter];
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await _loadRecipes();
      if (_currentUserId != null) {
        await _loadFavorites();
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database ricette aggiornato'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Aggiornamento fallito: $e')));
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => FilterBottomSheetWidget(
          selectedFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _filterRecipes();
          },
        ),
      ),
    );
  }

  Future<void> _handleVoiceSearch() async {
    // TODO: Voice search functionality disabled for now
    // Will be implemented in a future update
  }

  Future<void> _handleBarcodeSearch() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Scansiona Codice a Barre'),
            backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
            foregroundColor: AppTheme.textPrimaryLight,
          ),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final String code = barcodes.first.rawValue ?? '';
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Codice a barre scansionato: $code'),
                  ),
                );
                setState(() {
                  _searchController.text = 'Italian';
                  _searchQuery = 'Italian';
                });
                _filterRecipes();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _createRecipe() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crea Nuova Ricetta',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: const Text('Scatta Foto'),
              subtitle: const Text(
                'Cattura i passaggi della ricetta con la fotocamera',
              ),
              onTap: () async {
                Navigator.pop(context);
                await _captureRecipePhoto();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'photo_library',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: const Text('Scegli dalla Galleria'),
              subtitle: const Text('Seleziona foto esistenti'),
              onTap: () async {
                Navigator.pop(context);
                await _selectFromGallery();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'edit',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: const Text('Inserimento Manuale'),
              subtitle: const Text('Crea ricetta senza foto'),
              onTap: () {
                Navigator.pop(context);
                _showManualRecipeEntry();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _captureRecipePhoto() async {
    if (!await Permission.camera.isGranted) {
      await Permission.camera.request();
    }
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (photo != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto catturata! Apertura editor ricette...'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile catturare la foto')),
      );
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 80,
      );
      if (images.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selezionate ${images.length} foto')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossibile selezionare le foto')),
      );
    }
  }

  void _showManualRecipeEntry() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funzionalità disponibile a breve')),
    );
  }

  Future<void> _toggleFavorite(Map<String, dynamic> recipe) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accedi per salvare i preferiti')),
      );
      return;
    }

    try {
      final recipeId = recipe['id'] as String;
      final isFavorite = recipe['isFavorite'] as bool;

      if (isFavorite) {
        await RecipeService.instance.removeFromFavorites(
          recipeId,
          _currentUserId!,
        );
        setState(() {
          recipe['isFavorite'] = false;
          _favoriteRecipeIds.remove(recipeId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Rimossa dai preferiti')));
      } else {
        await RecipeService.instance.addToFavorites(recipeId, _currentUserId!);
        setState(() {
          recipe['isFavorite'] = true;
          _favoriteRecipeIds.add(recipeId);
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Aggiunta ai preferiti')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore: $e')));
    }
  }

  void _shareRecipe(Map<String, dynamic> recipe) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Condivisione "${recipe['title']}"')),
    );
  }

  void _showRecipeContextMenu(Map<String, dynamic> recipe) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              recipe['title'],
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            SizedBox(height: 3.h),
            if (recipe['author'] == 'Personal') ...[
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'edit',
                  color: AppTheme.primaryLight,
                  size: 6.w,
                ),
                title: const Text('Modifica Ricetta'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apertura editor ricette...'),
                    ),
                  );
                },
              ),
            ],
            ListTile(
              leading: CustomIconWidget(
                iconName: recipe['isFavorite'] ? 'favorite' : 'favorite_border',
                color: AppTheme.errorLight,
                size: 6.w,
              ),
              title: Text(
                recipe['isFavorite']
                    ? 'Rimuovi dai Preferiti'
                    : 'Aggiungi ai Preferiti',
              ),
              onTap: () {
                Navigator.pop(context);
                _toggleFavorite(recipe);
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.primaryLight,
                size: 6.w,
              ),
              title: const Text('Condividi Ricetta'),
              onTap: () {
                Navigator.pop(context);
                _shareRecipe(recipe);
              },
            ),
            if (recipe['author'] == 'Personal') ...[
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'delete',
                  color: AppTheme.errorLight,
                  size: 6.w,
                ),
                title: const Text('Elimina Ricetta'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(recipe);
                },
              ),
            ],
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> recipe) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Elimina Ricetta'),
        content: Text(
          'Sei sicuro di voler eliminare "${recipe['title']}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allRecipes.removeWhere((r) => r['id'] == recipe['id']);
              });
              _filterRecipes();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ricetta eliminata')),
              );
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  Future<void> _viewRecipeDetail(Map<String, dynamic> recipe) async {
    await Navigator.pushNamed(context, AppRoutes.recipeDetail, arguments: recipe);
    
    // Refresh favorites when returning from detail view to ensure sync
    if (mounted) {
      await _loadFavorites();
      setState(() {
        // Update isFavorite flag for all recipes based on the refreshed IDs
        for (var r in _allRecipes) {
          r['isFavorite'] = _favoriteRecipeIds.contains(r['id']);
        }
        // Force list rebuild
        _filterRecipes();
      });
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
            colors: [AppTheme.seaTop, AppTheme.seaMid, AppTheme.seaDeep],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar
              _buildOceanAppBar(),
              // Tab Bar
              _buildOceanTabBar(),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_buildRecipesTab(), _buildSavedRecipesTab()],
                ),
              ),
              // Bottom Navigation
              _buildOceanBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOceanAppBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
              'Gestione Ricette',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: _createRecipe,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOceanTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Ricette'), Tab(text: 'Ricette salvate')],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15.sp,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 15.sp,
        ),
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
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: CustomIconWidget(
        iconName: iconName,
        color: const Color(0xFFB0BEC5),
        size: 26,
      ),
    );
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, AppRoutes.dashboard);
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
          _createRecipe();
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

  Widget _buildRecipesTab() {
    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        children: [
          SearchBarWidget(
            controller: _searchController,
            onFilterTap: _showFilterBottomSheet,
            onVoiceSearch: _handleVoiceSearch,
            onBarcodeSearch: _handleBarcodeSearch,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _filterRecipes();
            },
          ),
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onRemoveFilter: (filter) {
              setState(() {
                _activeFilters.remove(filter);
              });
              _filterRecipes();
            },
            onClearAll: () {
              setState(() {
                _activeFilters.clear();
              });
              _filterRecipes();
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : _filteredRecipes.isEmpty
                    ? EmptyStateWidget(
                        title:
                            _searchQuery.isNotEmpty || _activeFilters.isNotEmpty
                                ? 'Nessuna ricetta trovata'
                                : 'Nessuna ricetta ancora',
                        subtitle: _searchQuery.isNotEmpty ||
                                _activeFilters.isNotEmpty
                            ? 'Prova ad aggiustare la tua ricerca o i filtri per trovare più ricette.'
                            : 'Inizia a costruire la tua collezione di ricette creando la tua prima ricetta o esplorando il nostro dataset di esempio.',
                        buttonText: 'Crea Ricetta',
                        onButtonPressed: _createRecipe,
                        iconName: 'restaurant_menu',
                      )
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Colors.white,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.h,
                          ),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 2.w,
                            mainAxisSpacing: 2.h,
                          ),
                          itemCount: _filteredRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _filteredRecipes[index];
                            return RecipeCardWidget(
                              recipe: recipe,
                              onTap: () => _viewRecipeDetail(recipe),
                              onFavorite: () => _toggleFavorite(recipe),
                              onShare: () => _shareRecipe(recipe),
                              onLongPress: () => _showRecipeContextMenu(recipe),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedRecipesTab() {
    // Filter to show only favorite/saved recipes
    final savedRecipes =
        _allRecipes.where((recipe) => recipe['isFavorite'] == true).toList();

    // Apply search and additional filters if any are active
    List<Map<String, dynamic>> filteredSavedRecipes = savedRecipes;

    if (_searchQuery.isNotEmpty || _activeFilters.isNotEmpty) {
      filteredSavedRecipes = savedRecipes.where((recipe) {
        // Search query filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final title = (recipe['title'] as String).toLowerCase();
          final tags = (recipe['tags'] as List).join(' ').toLowerCase();
          final description = (recipe['description'] as String).toLowerCase();

          if (!title.contains(query) &&
              !tags.contains(query) &&
              !description.contains(query)) {
            return false;
          }
        }

        // Active filters (excluding the 'Preferiti' or 'I Miei Preferiti' filter since we're already showing only favorites)
        if (_activeFilters.isNotEmpty) {
          for (String filter in _activeFilters) {
            // Skip favorite filters since we're already showing only favorites
            if (filter == 'Preferiti' || filter == 'I Miei Preferiti') {
              continue;
            }

            switch (filter) {
              // Source filters
              case 'Le Mie Ricette':
                if (recipe['author'] != 'Personal') return false;
                break;
              case 'Biblioteca Pubblica':
                if (recipe['author'] != 'Public') return false;
                break;
              case 'Usate di Recente':
                final lastUsed = recipe['lastUsed'] as DateTime;
                if (DateTime.now().difference(lastUsed).inDays > 7)
                  return false;
                break;

              // Category filters
              case 'Italiane':
                final tags = recipe['tags'] as List<String>;
                if (!tags.contains('Italian')) return false;
                break;
              case 'Pasti Veloci':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime > 15) return false;
                break;
              case 'Grigliate':
                final tags = recipe['tags'] as List<String>;
                if (!tags.contains('Grilled')) return false;
                break;
              case 'Dolci':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'dessert') return false;
                break;

              // Meal type filters
              case 'Colazione':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'breakfast') return false;
                break;
              case 'Pranzo':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'lunch') return false;
                break;
              case 'Cena':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'dinner') return false;
                break;
              case 'Spuntino':
                final category = recipe['raw_category'] as String;
                if (category.toLowerCase() != 'snack') return false;
                break;

              // Difficulty filters
              case 'Facile':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'easy') return false;
                break;
              case 'Medio':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'medium') return false;
                break;
              case 'Difficile':
                final difficulty = recipe['raw_difficulty'] as String;
                if (difficulty.toLowerCase() != 'hard') return false;
                break;

              // Time-based filters
              case 'Sotto i 15 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime >= 15) return false;
                break;
              case '15-30 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime < 15 || prepTime > 30) return false;
                break;
              case '30-60 min':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime < 30 || prepTime > 60) return false;
                break;
              case 'Oltre 1 ora':
                final prepTime = recipe['prepTime'] as int;
                if (prepTime <= 60) return false;
                break;

              // Dietary restriction filters
              case 'Poco Sodio':
              case 'Ricche di Proteine':
              case 'Cibi Morbidi':
              case 'Anti-Nausea':
              case 'Senza Latticini':
              case 'Senza Glutine':
                final tags = recipe['tags'] as List<String>;
                final tagFound = tags.any(
                  (tag) =>
                      tag.toLowerCase().contains(filter.toLowerCase()) ||
                      _mapDietaryFilter(filter).any(
                        (mappedTag) => tags.any(
                          (recipeTag) => recipeTag.toLowerCase().contains(
                                mappedTag.toLowerCase(),
                              ),
                        ),
                      ),
                );
                if (!tagFound) return false;
                break;

              default:
                // Check if filter matches category or tags directly
                final tags = recipe['tags'] as List<String>;
                final category = recipe['category'] as String;
                if (!tags.contains(filter) && category != filter) return false;
                break;
            }
          }
        }

        return true;
      }).toList();
    }

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      child: Column(
        children: [
          // Search and Filter UI (reuse from recipes tab)
          SearchBarWidget(
            controller: _searchController,
            onFilterTap: _showFilterBottomSheet,
            onVoiceSearch: _handleVoiceSearch,
            onBarcodeSearch: _handleBarcodeSearch,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          FilterChipsWidget(
            activeFilters: _activeFilters,
            onRemoveFilter: (filter) {
              setState(() {
                _activeFilters.remove(filter);
              });
            },
            onClearAll: () {
              setState(() {
                _activeFilters.clear();
              });
            },
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  )
                : filteredSavedRecipes.isEmpty
                    ? EmptyStateWidget(
                        title: savedRecipes.isEmpty
                            ? 'Nessuna ricetta salvata'
                            : 'Nessuna ricetta trovata',
                        subtitle: savedRecipes.isEmpty
                            ? 'Aggiungi ricette ai preferiti per visualizzarle qui. Vai alla scheda "Ricette" e tocca il cuore su una ricetta per salvarla.'
                            : 'Prova ad aggiustare la tua ricerca o i filtri per trovare più ricette salvate.',
                        buttonText: savedRecipes.isEmpty
                            ? 'Esplora Ricette'
                            : 'Cancella Filtri',
                        onButtonPressed: savedRecipes.isEmpty
                            ? () => _tabController
                                .animateTo(0) // Switch to recipes tab
                            : () {
                                setState(() {
                                  _activeFilters.clear();
                                  _searchQuery = '';
                                  _searchController.clear();
                                });
                              },
                        iconName:
                            savedRecipes.isEmpty ? 'favorite_border' : 'clear',
                      )
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        color: Colors.white,
                        child: GridView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 2.h,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 2.5,
                            crossAxisSpacing: 2.w,
                            mainAxisSpacing: 2.h,
                          ),
                          itemCount: filteredSavedRecipes.length,
                          itemBuilder: (context, index) {
                            final recipe = filteredSavedRecipes[index];
                            return RecipeCardWidget(
                              recipe: recipe,
                              onTap: () => _viewRecipeDetail(recipe),
                              onFavorite: () => _toggleFavorite(recipe),
                              onShare: () => _shareRecipe(recipe),
                              onLongPress: () => _showRecipeContextMenu(recipe),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
