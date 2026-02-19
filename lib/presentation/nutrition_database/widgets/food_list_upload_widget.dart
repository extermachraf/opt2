import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/food_data_management_service.dart';

class FoodListUploadWidget extends StatefulWidget {
  const FoodListUploadWidget({Key? key}) : super(key: key);

  @override
  State<FoodListUploadWidget> createState() => _FoodListUploadWidgetState();
}

class _FoodListUploadWidgetState extends State<FoodListUploadWidget> {
  final TextEditingController _jsonController = TextEditingController();
  bool _isProcessing = false;
  Map<String, dynamic>? _crossCheckResults;
  Map<String, dynamic>? _insertResults;
  Map<String, dynamic>? _databaseStats;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDatabaseStats();
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabaseStats() async {
    try {
      final stats = await FoodDataManagementService.instance.getDatabaseStats();
      if (mounted) {
        setState(() {
          _databaseStats = stats;
        });
      }
    } catch (e) {
      print('Error loading database stats: ${e.toString()}');
      if (mounted) {
        setState(() {
          _databaseStats = {
            'total_foods': 0,
            'sample_foods': <String>[],
            'database_status': 'error',
            'error': e.toString(),
          };
        });
      }
    }
  }

  Future<void> _processJsonFoodList() async {
    if (_jsonController.text.trim().isEmpty) {
      _showError('Inserisci la lista di alimenti in formato JSON');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _crossCheckResults = null;
      _insertResults = null;
    });

    try {
      // Parse JSON with better error handling
      late final dynamic jsonData;
      try {
        jsonData = json.decode(_jsonController.text.trim());
      } catch (e) {
        throw FormatException('JSON non valido: ${e.toString()}');
      }

      List<Map<String, dynamic>> foodList;
      if (jsonData is List) {
        foodList = [];
        for (final item in jsonData) {
          if (item != null && item is Map<String, dynamic>) {
            foodList.add(item);
          }
        }
      } else {
        throw FormatException('Il JSON deve essere una lista di oggetti');
      }

      if (foodList.isEmpty) {
        throw FormatException(
            'La lista di alimenti è vuota o non contiene oggetti validi');
      }

      // Step 1: Cross-check against existing database
      final crossCheckResults =
          await FoodDataManagementService.instance.crossCheckFoods(foodList);

      if (mounted) {
        setState(() {
          _crossCheckResults = crossCheckResults;
        });

        // Show results to user before inserting
        _showCrossCheckDialog(crossCheckResults);
      }
    } catch (e) {
      final errorMsg = 'Errore nell\'elaborazione: ${e.toString()}';
      _showError(errorMsg);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showCrossCheckDialog(Map<String, dynamic> results) {
    // Validate results object
    final missingFoods =
        results['missing_foods'] as List<Map<String, dynamic>>? ?? [];
    final existingCount = results['existing_count'] as int? ?? 0;
    final missingCount = results['missing_count'] as int? ?? 0;
    final errors = results['errors'] as List<String>? ?? [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Risultati verifica alimenti',
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: 80.w,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('✅ Alimenti già presenti:', '$existingCount'),
              _buildStatRow('➕ Alimenti mancanti:', '$missingCount'),
              _buildStatRow(
                '📊 Totale elaborati:',
                '${existingCount + missingCount}',
              ),
              if (errors.isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  '⚠️ Errori: ${errors.length}',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              if (missingCount > 0) ...[
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          AppTheme.lightTheme.colorScheme.primary.withAlpha(77),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vuoi aggiungere i $missingCount alimenti mancanti al database?',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Questo renderà tutti gli alimenti cercabili nella sezione "Aggiungi pasto".',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Annulla',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(
                  179,
                ),
              ),
            ),
          ),
          if (missingCount > 0 && missingFoods.isNotEmpty)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _addMissingFoodsToDatabase(missingFoods);
              },
              icon: CustomIconWidget(
                iconName: 'add_circle',
                color: Colors.white,
                size: 16,
              ),
              label: Text(
                'Aggiungi $missingCount alimenti',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
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

  Future<void> _addMissingFoodsToDatabase(
    List<Map<String, dynamic>> missingFoods,
  ) async {
    if (missingFoods.isEmpty) {
      _showError('Nessun alimento da aggiungere');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final insertResults = await FoodDataManagementService.instance
          .addMissingFoodsToDatabase(missingFoods);

      if (mounted) {
        setState(() {
          _insertResults = insertResults;
          _isProcessing = false;
        });

        // Refresh database stats
        await _loadDatabaseStats();

        _showInsertResultsDialog(insertResults);
      }
    } catch (e) {
      final errorMsg = 'Errore nell\'aggiunta al database: ${e.toString()}';
      _showError(errorMsg);
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showInsertResultsDialog(Map<String, dynamic> results) {
    // Validate results object
    final successCount = results['success_count'] as int? ?? 0;
    final errorCount = results['error_count'] as int? ?? 0;
    final isSuccess = errorCount == 0 && successCount > 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: isSuccess ? 'check_circle' : 'error',
              color: isSuccess
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                isSuccess ? 'Aggiunta completata!' : 'Aggiunta parziale',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: isSuccess
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (successCount > 0)
              _buildStatRow('✅ Alimenti aggiunti:', '$successCount'),
            if (errorCount > 0) _buildStatRow('❌ Errori:', '$errorCount'),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer
                    .withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isSuccess
                    ? 'Tutti gli alimenti sono ora disponibili nella ricerca!'
                    : 'Alcuni alimenti potrebbero non essere stati aggiunti. Controlla i log per dettagli.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: isSuccess
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(4.w),
        ),
      );
    }
  }

  void _clearResults() {
    setState(() {
      _crossCheckResults = null;
      _insertResults = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'upload_file',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'Gestione lista alimenti',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'Carica una lista di alimenti JSON per verificare quali sono già nel database e aggiungere quelli mancanti.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(179),
            ),
          ),

          // Database Stats
          if (_databaseStats != null) ...[
            SizedBox(height: 2.h),
            _buildDatabaseStatsCard(),
          ],

          SizedBox(height: 3.h),

          // JSON Input
          Text(
            'Lista alimenti (formato JSON):',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
              ),
            ),
            child: TextField(
              controller: _jsonController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText:
                    'Incolla qui la lista JSON degli alimenti...\n\nEsempio:\n[{"food_name":"PATATE","name_it":"PATATE","Energia_Ric_con_fibra_(kcal)":80,...}]',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(3.w),
              ),
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),

          SizedBox(height: 2.h),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _processJsonFoodList,
              icon: _isProcessing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : CustomIconWidget(
                      iconName: 'search',
                      color: Colors.white,
                      size: 18,
                    ),
              label: Text(
                _isProcessing
                    ? 'Elaborazione...'
                    : 'Verifica e aggiungi alimenti',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
              ),
            ),
          ),

          // Clear Button
          if (_crossCheckResults != null || _insertResults != null) ...[
            SizedBox(height: 1.h),
            TextButton.icon(
              onPressed: _clearResults,
              icon: CustomIconWidget(
                iconName: 'clear',
                color: AppTheme.lightTheme.colorScheme.outline,
                size: 16,
              ),
              label: Text(
                'Cancella risultati',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
              ),
            ),
          ],

          // Results Display
          if (_crossCheckResults != null) ...[
            SizedBox(height: 3.h),
            _buildResultsCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildDatabaseStatsCard() {
    final stats = _databaseStats!;
    final isConnected = stats['database_status'] == 'connected';

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.lightTheme.colorScheme.primaryContainer.withAlpha(26)
            : AppTheme.lightTheme.colorScheme.errorContainer.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected
              ? AppTheme.lightTheme.colorScheme.primary.withAlpha(77)
              : AppTheme.lightTheme.colorScheme.error.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: isConnected ? 'database' : 'error',
                color: isConnected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Stato database',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          if (isConnected) ...[
            Text(
              'Alimenti disponibili: ${stats['total_foods']}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (stats['sample_foods'].isNotEmpty) ...[
              SizedBox(height: 0.5.h),
              Text(
                'Esempi: ${(stats['sample_foods'] as List).take(3).join(', ')}...',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withAlpha(
                    179,
                  ),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ] else
            Text(
              'Errore connessione: ${stats['error']}',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    final results = _crossCheckResults!;
    final hasInsertResults = _insertResults != null;

    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Risultati elaborazione',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 1.5.h),
          _buildStatRow(
            '✅ Alimenti già presenti:',
            '${results['existing_count']}',
          ),
          _buildStatRow('➕ Alimenti mancanti:', '${results['missing_count']}'),
          _buildStatRow(
            '📊 Totale elaborati:',
            '${results['total_processed']}',
          ),
          if (results['errors'].isNotEmpty)
            _buildStatRow('⚠️ Errori:', '${results['errors'].length}'),
          if (hasInsertResults) ...[
            SizedBox(height: 1.h),
            Divider(
              color: AppTheme.lightTheme.colorScheme.outline.withAlpha(77),
            ),
            SizedBox(height: 1.h),
            Text(
              'Risultati aggiunta al database',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            _buildStatRow(
              '✅ Aggiunti con successo:',
              '${_insertResults!['success_count']}',
            ),
            if (_insertResults!['error_count'] > 0)
              _buildStatRow('❌ Errori:', '${_insertResults!['error_count']}'),
          ],
        ],
      ),
    );
  }
}
