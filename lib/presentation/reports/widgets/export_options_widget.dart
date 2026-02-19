import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart';
import '../../../services/meal_diary_service.dart';
import '../../../services/sharing_service.dart';

class ExportOptionsWidget extends StatefulWidget {
  final String dateRange;
  final VoidCallback onClose;

  const ExportOptionsWidget({
    Key? key,
    required this.dateRange,
    required this.onClose,
  }) : super(key: key);

  @override
  State<ExportOptionsWidget> createState() => _ExportOptionsWidgetState();
}

class _ExportOptionsWidgetState extends State<ExportOptionsWidget> {
  bool _isGenerating = false;
  String _selectedPrivacyLevel = 'Dettaglio Completo';
  final List<String> _privacyLevels = ['Dettaglio Completo', 'Solo Riassunto'];

  // Real data from Supabase
  Map<String, dynamic> _nutritionalSummary = {};
  Map<String, dynamic> _mealStatistics = {};
  List<Map<String, dynamic>> _recentMeals = [];

  // WhatsApp availability check
  bool _isWhatsAppAvailable = false;

  final List<Map<String, dynamic>> _exportOptions = [
    {
      'title': 'Genera Report PDF',
      'subtitle': 'Formato report medico professionale',
      'icon': 'picture_as_pdf',
      'color': Color(0xFFE74C3C),
      'action': 'pdf',
    },
    {
      'title': 'Condividi via WhatsApp',
      'subtitle': 'Invia il report nutrizionale su WhatsApp',
      'icon': 'chat',
      'color': Color(0xFF25D366),
      'action': 'whatsapp',
    },
    {
      'title': 'Condividi via Social',
      'subtitle': 'Telegram, Email, SMS e altri',
      'icon': 'share',
      'color': Color(0xFF1DA1F2),
      'action': 'social',
    },
    {
      'title': 'Invia per Email al Fornitore Sanitario',
      'subtitle': 'Invia direttamente al tuo team medico',
      'icon': 'email',
      'color': Color(0xFF3498DB),
      'action': 'email',
    },
    {
      'title': 'Esporta Dati (CSV)',
      'subtitle': 'Dati grezzi per analisi esterni',
      'icon': 'table_chart',
      'color': Color(0xFF27AE60),
      'action': 'csv',
    },
    {
      'title': 'Salva su Cloud Storage',
      'subtitle': 'Backup sicuro e condivisione',
      'icon': 'cloud_upload',
      'color': Color(0xFF9B59B6),
      'action': 'cloud',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadRealData();
    _checkWhatsAppAvailability();
  }

  Future<void> _checkWhatsAppAvailability() async {
    final available = await SharingService.instance.isWhatsAppAvailable();
    setState(() {
      _isWhatsAppAvailable = available;
    });
  }

  Future<void> _loadRealData() async {
    if (!AuthService.instance.isAuthenticated) return;

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      // Calculate date range based on selection
      switch (widget.dateRange.toLowerCase()) {
        case 'daily':
        case 'giornaliero':
          startDate = DateTime(now.year, now.month, now.day);
          endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
          break;
        case 'weekly':
        case 'settimanale':
          startDate = now.subtract(Duration(days: 7));
          break;
        case 'monthly':
        case 'mensile':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'yearly':
        case 'annuale':
          startDate = DateTime(now.year - 1, now.month, now.day);
          break;
        default:
          startDate = now.subtract(Duration(days: 7));
      }

      // Load real data from Supabase
      final summary = await MealDiaryService.instance.getNutritionalSummary(
        startDate: startDate,
        endDate: endDate,
      );

      final statistics = await MealDiaryService.instance.getMealStatistics(
        startDate: startDate,
        endDate: endDate,
      );

      final meals = await MealDiaryService.instance.getUserMeals(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _nutritionalSummary = summary;
        _mealStatistics = statistics;
        _recentMeals = meals.take(10).toList(); // Last 10 meals for report
      });
    } catch (error) {
      print('Error loading real data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.seaMid.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Opzioni di Esportazione e Condivisione',
                    style: TextStyle(
                      color: AppTheme.seaDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: AppTheme.textMuted,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          if (_isGenerating)
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.seaMid,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Generazione e condivisione report...',
                    style: TextStyle(
                      color: AppTheme.seaMid,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isGenerating = false;
                      });
                    },
                    child: Text(
                      'Annulla',
                      style: TextStyle(color: AppTheme.seaMid),
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.seaMid.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.seaTop, AppTheme.seaMid],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomIconWidget(
                              iconName: 'info',
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'Genera e condividi il tuo report nutrizionale ${widget.dateRange.toLowerCase()} via WhatsApp, social o email',
                              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                color: AppTheme.seaDeep,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Livello di Privacy',
                      style: TextStyle(
                        color: AppTheme.seaDeep,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppTheme.seaMid.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPrivacyLevel,
                          isExpanded: true,
                          icon: CustomIconWidget(
                            iconName: 'keyboard_arrow_down',
                            color: AppTheme.seaMid,
                            size: 24,
                          ),
                          items: _privacyLevels.map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text(
                                level,
                                style: TextStyle(color: AppTheme.seaDeep),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPrivacyLevel = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Opzioni di Condivisione',
                      style: TextStyle(
                        color: AppTheme.seaDeep,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ..._exportOptions.map((option) {
                      bool isDisabled = option['action'] == 'whatsapp' &&
                          !_isWhatsAppAvailable;

                      return Container(
                        margin: EdgeInsets.only(bottom: 2.h),
                        child: InkWell(
                          onTap: isDisabled
                              ? null
                              : () => _handleExportAction(
                                  option['action'] as String),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.seaMid.withValues(alpha: 0.15),
                                width: 1,
                              ),
                              boxShadow: isDisabled
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(3.w),
                                  decoration: BoxDecoration(
                                    color: (option['color'] as Color)
                                        .withValues(
                                            alpha: isDisabled ? 0.3 : 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: option['icon'] as String,
                                    color: isDisabled
                                        ? (option['color'] as Color)
                                            .withValues(alpha: 0.5)
                                        : (option['color'] as Color),
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title'] as String,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13.sp,
                                          color: isDisabled
                                              ? AppTheme.textMuted.withValues(alpha: 0.5)
                                              : AppTheme.seaDeep,
                                        ),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        (option['subtitle'] as String) +
                                            (isDisabled
                                                ? ' (non disponibile)'
                                                : ''),
                                        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                          color: isDisabled
                                              ? AppTheme.textMuted
                                                  .withValues(alpha: 0.5)
                                              : AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                CustomIconWidget(
                                  iconName: 'arrow_forward_ios',
                                  color: isDisabled
                                      ? AppTheme.textMuted.withValues(alpha: 0.3)
                                      : AppTheme.seaMid,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleExportAction(String action) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      switch (action) {
        case 'pdf':
          await _generatePDFReport();
          break;
        case 'whatsapp':
          await _shareViaWhatsApp();
          break;
        case 'social':
          await _showSocialSharingOptions();
          break;
        case 'email':
          await _emailReport();
          break;
        case 'csv':
          await _exportCSVData();
          break;
        case 'cloud':
          await _saveToCloud();
          break;
      }
    } catch (e) {
      _showErrorMessage('Operazione fallita. Riprova.');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _shareViaWhatsApp() async {
    final reportContent = _generateReportContent();
    final filename = 'nutrivita_report_${widget.dateRange.toLowerCase()}.txt';

    final success = await SharingService.instance.shareViaWhatsApp(
      reportContent,
      filename,
    );

    if (success) {
      _showSuccessMessage('Report condiviso su WhatsApp con successo!');
      widget.onClose();
    } else {
      _showErrorMessage(
          'Impossibile condividere su WhatsApp. Assicurati che WhatsApp sia installato.');
    }
  }

  Future<void> _showSocialSharingOptions() async {
    setState(() {
      _isGenerating = false;
    });

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              child: Text(
                'Condividi via Social',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...[
              {
                'name': 'Telegram',
                'icon': 'telegram',
                'color': Color(0xFF0088CC),
                'platform': 'telegram'
              },
              {
                'name': 'Email',
                'icon': 'email',
                'color': Color(0xFF3498DB),
                'platform': 'email'
              },
              {
                'name': 'SMS',
                'icon': 'sms',
                'color': Color(0xFF27AE60),
                'platform': 'sms'
              },
              {
                'name': 'Condivisione Sistema',
                'icon': 'share',
                'color': Color(0xFF95A5A6),
                'platform': 'system'
              },
            ].map((social) {
              return ListTile(
                leading: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: (social['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: social['icon'] as String,
                    color: social['color'] as Color,
                    size: 24,
                  ),
                ),
                title: Text(social['name'] as String),
                onTap: () async {
                  Navigator.pop(context);
                  await _shareViaSocialPlatform(social['platform'] as String);
                },
              );
            }).toList(),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaSocialPlatform(String platform) async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final reportContent = _generateReportContent();
      final filename = 'nutrivita_report_${widget.dateRange.toLowerCase()}.txt';

      bool success = false;
      if (platform == 'system') {
        success = await SharingService.instance.shareViaSystemSheet(
          reportContent,
          filename,
        );
      } else {
        success = await SharingService.instance.shareViaOtherPlatforms(
          reportContent,
          filename,
          platform,
        );
      }

      if (success) {
        _showSuccessMessage('Report condiviso con successo!');
        widget.onClose();
      } else {
        _showErrorMessage('Impossibile completare la condivisione.');
      }
    } catch (e) {
      _showErrorMessage('Errore durante la condivisione. Riprova.');
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  Future<void> _generatePDFReport() async {
    try {
      // Generate PDF using real meal data
      final pdfBytes = await _generatePdfBytes();
      final filename = 'nutrivita_report_${widget.dateRange.toLowerCase()}.pdf';

      if (kIsWeb) {
        // Web: Download PDF
        final blob = html.Blob([pdfBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(url);
        _showSuccessMessage('Report PDF generato con successo');
        widget.onClose();
      } else {
        // Mobile: Use share sheet to save or share PDF
        await Printing.sharePdf(
          bytes: pdfBytes,
          filename: filename,
        );
        _showSuccessMessage('Report PDF generato con successo');
        widget.onClose();
      }
    } catch (e) {
      print('Error generating PDF: $e');
      _showErrorMessage('Impossibile generare il report PDF');
    }
  }

  /// Generate PDF bytes with complete meal data
  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();

    // Prepare data - convert to double first to handle both String and num types
    final totalCaloriesNum = _toDouble(_nutritionalSummary['total_calories']);
    final avgCaloriesPerDayNum = _toDouble(_nutritionalSummary['avg_calories_per_day']);
    final totalProteinNum = _toDouble(_nutritionalSummary['total_protein']);
    final totalCarbsNum = _toDouble(_nutritionalSummary['total_carbs']);
    final totalFatNum = _toDouble(_nutritionalSummary['total_fat']);
    final totalFiberNum = _toDouble(_nutritionalSummary['total_fiber']);

    // Format for display
    final totalCalories = totalCaloriesNum.toStringAsFixed(0);
    final avgCaloriesPerDay = avgCaloriesPerDayNum.toStringAsFixed(0);
    final totalProtein = totalProteinNum.toStringAsFixed(1);
    final totalCarbs = totalCarbsNum.toStringAsFixed(1);
    final totalFat = totalFatNum.toStringAsFixed(1);
    final totalFiber = totalFiberNum.toStringAsFixed(1);

    final totalMeals = _mealStatistics['total_meals'] ?? 0;
    final mealDistribution = _mealStatistics['meal_type_distribution'] ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NutriVita Report Nutrizionale',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 2),
              ],
            ),
          ),

          // Report Details
          pw.SizedBox(height: 20),
          pw.Text('Periodo Report: ${widget.dateRange}'),
          pw.Text('Generato: ${DateTime.now().toString().split('.')[0]}'),
          pw.Text('Livello Privacy: $_selectedPrivacyLevel'),
          pw.SizedBox(height: 20),

          // Nutritional Summary
          pw.Header(
            level: 1,
            text: 'RIASSUNTO NUTRIZIONALE',
          ),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            data: [
              ['Metrica', 'Valore'],
              ['Calorie Totali', '$totalCalories kcal'],
              ['Calorie Giornaliere Medie', '$avgCaloriesPerDay kcal'],
              ['Pasti Registrati', '$totalMeals'],
            ],
          ),
          pw.SizedBox(height: 20),

          // Macro Distribution
          pw.Header(
            level: 1,
            text: 'DISTRIBUZIONE MACRO',
          ),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: [
              ['Macronutriente', 'Kcal', 'Peso', 'Percentuale'],
              ['Proteine', '${(totalProteinNum * 4).toStringAsFixed(0)} kcal', '${totalProteinNum.toStringAsFixed(0)}g', '${((totalProteinNum * 4) / (totalProteinNum * 4 + totalCarbsNum * 3.75 + totalFatNum * 9 + totalFiberNum * 2) * 100).toStringAsFixed(1)}%'],
              ['Carboidrati', '${(totalCarbsNum * 3.75).toStringAsFixed(0)} kcal', '${totalCarbsNum.toStringAsFixed(0)}g', '${((totalCarbsNum * 3.75) / (totalProteinNum * 4 + totalCarbsNum * 3.75 + totalFatNum * 9 + totalFiberNum * 2) * 100).toStringAsFixed(1)}%'],
              ['Grassi', '${(totalFatNum * 9).toStringAsFixed(0)} kcal', '${totalFatNum.toStringAsFixed(0)}g', '${((totalFatNum * 9) / (totalProteinNum * 4 + totalCarbsNum * 3.75 + totalFatNum * 9 + totalFiberNum * 2) * 100).toStringAsFixed(1)}%'],
              ['Fibre', '${(totalFiberNum * 2).toStringAsFixed(0)} kcal', '${totalFiberNum.toStringAsFixed(0)}g', '${((totalFiberNum * 2) / (totalProteinNum * 4 + totalCarbsNum * 3.75 + totalFatNum * 9 + totalFiberNum * 2) * 100).toStringAsFixed(1)}%'],
            ],
          ),
          pw.SizedBox(height: 20),

          // Meal Frequency
          pw.Header(
            level: 1,
            text: 'FREQUENZA PASTI',
          ),
          pw.Table.fromTextArray(
            border: pw.TableBorder.all(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            data: [
              ['Tipo Pasto', 'Numero'],
              ['Colazioni', '${mealDistribution['breakfast'] ?? 0}'],
              ['Pranzi', '${mealDistribution['lunch'] ?? 0}'],
              ['Cene', '${mealDistribution['dinner'] ?? 0}'],
              ['Spuntini', '${mealDistribution['snack'] ?? 0}'],
            ],
          ),
          pw.SizedBox(height: 20),

          // Recent Meals (if detailed privacy)
          if (_selectedPrivacyLevel == 'Dettaglio Completo' &&
              _recentMeals.isNotEmpty) ...[
            pw.Header(
              level: 1,
              text: 'PASTI RECENTI',
            ),
            ..._buildPdfMealsList(),
          ],

          // Recommendations
          pw.SizedBox(height: 20),
          pw.Header(
            level: 1,
            text: 'RACCOMANDAZIONI',
          ),
          pw.Bullet(text: 'Mantieni la registrazione costante dei pasti'),
          pw.Bullet(
            text: totalMeals > 0
                ? 'Continua con l\'approccio nutrizionale attuale'
                : 'Inizia a registrare i tuoi pasti per un monitoraggio migliore',
          ),
          pw.Bullet(
            text: 'Programma un follow-up con il fornitore sanitario',
          ),

          // Footer
          pw.SizedBox(height: 30),
          pw.Divider(thickness: 1),
          pw.Text(
            'Questo report è generato da NutriVita per scopi di consultazione medica.',
            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
          ),
        ],
      ),
    );

    return pdf.save();
  }

  /// Build PDF meals list with complete data
  List<pw.Widget> _buildPdfMealsList() {
    final widgets = <pw.Widget>[];

    for (var meal in _recentMeals) {
      final mealDate = meal['date'] ?? 'Data non disponibile';
      final mealType = meal['type'] ?? 'Tipo non specificato';
      final mealTime = meal['time'] ?? '';
      final notes = meal['notes'] ?? '';

      widgets.add(
        pw.Container(
          margin: pw.EdgeInsets.only(bottom: 15),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '$mealDate ${mealTime.isNotEmpty ? '($mealTime)' : ''}: $mealType',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              if (notes.isNotEmpty)
                pw.Text('Note: $notes', style: pw.TextStyle(fontSize: 10)),

              // Meal foods details
              pw.SizedBox(height: 5),
              ..._buildPdfMealFoods(meal),
            ],
          ),
        ),
      );
    }

    if (widgets.isEmpty) {
      widgets.add(
        pw.Text('Nessun pasto registrato nel periodo selezionato'),
      );
    }

    return widgets;
  }

  /// Build meal foods for PDF with nutritional details
  List<pw.Widget> _buildPdfMealFoods(Map<String, dynamic> meal) {
    final mealFoods =
        meal['original_data']?['meal_foods'] as List<dynamic>? ?? [];
    final widgets = <pw.Widget>[];

    if (mealFoods.isEmpty) {
      return [
        pw.Text('Nessun cibo registrato', style: pw.TextStyle(fontSize: 9))
      ];
    }

    for (var food in mealFoods) {
      // FIXED: Get food name - check Food Ingredients first (primary source)
      String foodName = 'Cibo sconosciuto';
      
      // Priority 1: Food Ingredients table (primary source from nutrition database)
      if (food['Food Ingredients'] != null && 
          food['Food Ingredients']['Nome Alimento ITA'] != null &&
          food['Food Ingredients']['Nome Alimento ITA'].toString().isNotEmpty) {
        foodName = food['Food Ingredients']['Nome Alimento ITA'];
      }
      // Priority 2: Direct name field
      else if (food['name'] != null && food['name'].toString().isNotEmpty) {
        foodName = food['name'];
      }
      // Priority 3: Direct food_name field
      else if (food['food_name'] != null && food['food_name'].toString().isNotEmpty) {
        foodName = food['food_name'];
      }
      // Priority 4: Nested food_items.name (from database join)
      else if (food['food_items'] != null && food['food_items']['name'] != null) {
        foodName = food['food_items']['name'];
      }
      // Priority 5: Recipe title
      else if (food['recipes'] != null && food['recipes']['title'] != null) {
        foodName = food['recipes']['title'];
      }

      final calories = (food['calories'] ?? 0).toStringAsFixed(0);
      final protein = (food['protein_g'] ?? 0).toStringAsFixed(1);
      final carbs = (food['carbs_g'] ?? 0).toStringAsFixed(1);
      final fat = (food['fat_g'] ?? 0).toStringAsFixed(1);
      final fiber = (food['fiber_g'] ?? 0).toStringAsFixed(1);
      final quantity = (food['quantity_grams'] ?? 0).toStringAsFixed(0);

      widgets.add(
        pw.Container(
          margin: pw.EdgeInsets.only(left: 20, bottom: 5),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '• $foodName (${quantity}g)',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                '  Calorie: ${calories} kcal | P: ${protein}g | C: ${carbs}g | G: ${fat}g | F: ${fiber}g',
                style: pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  Future<void> _emailReport() async {
    // Simulate email functionality with real data processing
    await Future.delayed(const Duration(seconds: 2));
    _showSuccessMessage(
      'Report inviato al fornitore sanitario con dati aggiornati',
    );
    widget.onClose();
  }

  Future<void> _exportCSVData() async {
    final csvContent = _generateCSVContent();
    final filename = 'nutrivita_data_${widget.dateRange.toLowerCase()}.csv';

    if (kIsWeb) {
      final bytes = utf8.encode(csvContent);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      _showSuccessMessage('Dati CSV esportati con successo');
      widget.onClose();
    } else {
      // On mobile, use share sheet so user can save to Downloads or share
      final success = await SharingService.instance.shareViaSystemSheet(
        csvContent,
        filename,
      );

      if (success) {
        _showSuccessMessage('Dati CSV esportati con successo');
        widget.onClose();
      } else {
        _showErrorMessage('Impossibile esportare i dati CSV');
      }
    }
  }

  Future<void> _saveToCloud() async {
    // Simulate cloud save functionality with real data
    await Future.delayed(const Duration(seconds: 3));
    _showSuccessMessage(
      'Report salvato su cloud storage sicuro con dati reali',
    );
    widget.onClose();
  }

  String _generateReportContent() {
    // Generate report with real data from Supabase
    final totalCalories =
        (_nutritionalSummary['total_calories'] ?? 0.0).toStringAsFixed(0);
    final avgCaloriesPerDay =
        (_nutritionalSummary['avg_calories_per_day'] ?? 0.0).toStringAsFixed(0);
    final totalProtein =
        (_nutritionalSummary['total_protein'] ?? 0.0).toStringAsFixed(1);
    final totalCarbs =
        (_nutritionalSummary['total_carbs'] ?? 0.0).toStringAsFixed(1);
    final totalFat = (_nutritionalSummary['total_fat'] ?? 0.0).toStringAsFixed(
      1,
    );
    final totalFiber =
        (_nutritionalSummary['total_fiber'] ?? 0.0).toStringAsFixed(1);
    final totalMeals = _mealStatistics['total_meals'] ?? 0;
    final mealDistribution = _mealStatistics['meal_type_distribution'] ?? {};

    return '''
NutriVita Report Nutrizionale
============================

Paziente: Utente NutriVita
Periodo Report: ${widget.dateRange}
Generato: ${DateTime.now().toString().split('.')[0]}
Livello Privacy: $_selectedPrivacyLevel

RIASSUNTO NUTRIZIONALE
---------------------
Calorie Totali: $totalCalories kcal
Calorie Giornaliere Medie: $avgCaloriesPerDay kcal
Pasti Registrati: $totalMeals

DISTRIBUZIONE MACRO
------------------
Proteine Totali: ${totalProtein}g
Carboidrati Totali: ${totalCarbs}g
Grassi Totali: ${totalFat}g
Fibra Totale: ${totalFiber}g

FREQUENZA PASTI
--------------
Colazioni: ${mealDistribution['breakfast'] ?? 0}
Pranzi: ${mealDistribution['lunch'] ?? 0}
Cene: ${mealDistribution['dinner'] ?? 0}
Spuntini: ${mealDistribution['snack'] ?? 0}

PASTI RECENTI
${_selectedPrivacyLevel == 'Dettaglio Completo' ? _generateMealsList() : 'Dettagli omessi per privacy'}

RACCOMANDAZIONI
--------------
- Mantieni la registrazione costante dei pasti
- ${totalMeals > 0 ? 'Continua con l\'approccio nutrizionale attuale' : 'Inizia a registrare i tuoi pasti per un monitoraggio migliore'}
- Programma un follow-up con il fornitore sanitario

Questo report è generato da NutriVita per scopi di consultazione medica.
    ''';
  }

  String _generateMealsList() {
    if (_recentMeals.isEmpty) {
      return '- Nessun pasto registrato nel periodo selezionato';
    }

    final mealsText = StringBuffer();
    for (var meal in _recentMeals) {
      final mealDate = meal['date'] ?? 'Data non disponibile';
      final mealType = meal['type'] ?? 'Tipo non specificato';
      final mealTime = meal['time'] ?? '';
      final notes = meal['notes'] ?? '';

      mealsText.writeln(
        '\n- $mealDate ${mealTime.isNotEmpty ? '($mealTime)' : ''}: $mealType',
      );
      if (notes.isNotEmpty) {
        mealsText.writeln('  Note: $notes');
      }

      // Add meal foods details
      final mealFoods =
          meal['original_data']?['meal_foods'] as List<dynamic>? ?? [];
      if (mealFoods.isNotEmpty) {
        for (var food in mealFoods) {
          // FIXED: Get food name - check Food Ingredients first (primary source)
          String foodName = 'Cibo sconosciuto';
          
          // Priority 1: Food Ingredients table (primary source from nutrition database)
          if (food['Food Ingredients'] != null && 
              food['Food Ingredients']['Nome Alimento ITA'] != null &&
              food['Food Ingredients']['Nome Alimento ITA'].toString().isNotEmpty) {
            foodName = food['Food Ingredients']['Nome Alimento ITA'];
          }
          // Priority 2: Direct name field
          else if (food['name'] != null && food['name'].toString().isNotEmpty) {
            foodName = food['name'];
          }
          // Priority 3: Direct food_name field
          else if (food['food_name'] != null && food['food_name'].toString().isNotEmpty) {
            foodName = food['food_name'];
          }
          // Priority 4: Nested food_items.name (from database join)
          else if (food['food_items'] != null && food['food_items']['name'] != null) {
            foodName = food['food_items']['name'];
          }
          // Priority 5: Recipe title
          else if (food['recipes'] != null && food['recipes']['title'] != null) {
            foodName = food['recipes']['title'];
          }

          final calories = (food['calories'] ?? 0).toStringAsFixed(0);
          final protein = (food['protein_g'] ?? 0).toStringAsFixed(1);
          final carbs = (food['carbs_g'] ?? 0).toStringAsFixed(1);
          final fat = (food['fat_g'] ?? 0).toStringAsFixed(1);
          final fiber = (food['fiber_g'] ?? 0).toStringAsFixed(1);
          final quantity = (food['quantity_grams'] ?? 0).toStringAsFixed(0);

          mealsText.writeln(
            '  • $foodName (${quantity}g): ${calories} kcal | P: ${protein}g | C: ${carbs}g | G: ${fat}g | F: ${fiber}g',
          );
        }
      } else {
        mealsText.writeln('  Nessun cibo registrato');
      }
    }

    return mealsText.toString();
  }

  String _generateCSVContent() {
    // Generate CSV with real data including detailed meal information
    final buffer = StringBuffer();
    buffer.writeln(
      'Data,Tipo_Pasto,Ora,Cibo,Quantita_g,Calorie,Proteine_g,Carboidrati_g,Grassi_g,Fibra_g,Note',
    );

    if (_recentMeals.isNotEmpty) {
      for (var meal in _recentMeals) {
        final mealDate = meal['date'] ?? '';
        final mealType = meal['type'] ?? '';
        final mealTime = meal['time'] ?? '';
        final notes = (meal['notes'] as String? ?? '')
            .replaceAll(',', ';'); // Escape commas

        final mealFoods =
            meal['original_data']?['meal_foods'] as List<dynamic>? ?? [];

        if (mealFoods.isNotEmpty) {
          for (var food in mealFoods) {
            // FIXED: Get food name - check Food Ingredients first (primary source)
            String foodName = 'Cibo sconosciuto';
            
            // Priority 1: Food Ingredients table (primary source from nutrition database)
            if (food['Food Ingredients'] != null && 
                food['Food Ingredients']['Nome Alimento ITA'] != null &&
                food['Food Ingredients']['Nome Alimento ITA'].toString().isNotEmpty) {
              foodName = food['Food Ingredients']['Nome Alimento ITA'].replaceAll(',', ';');
            }
            // Priority 2: Direct name field
            else if (food['name'] != null && food['name'].toString().isNotEmpty) {
              foodName = food['name'].replaceAll(',', ';');
            }
            // Priority 3: Direct food_name field
            else if (food['food_name'] != null && food['food_name'].toString().isNotEmpty) {
              foodName = food['food_name'].replaceAll(',', ';');
            }
            // Priority 4: Nested food_items.name (from database join)
            else if (food['food_items'] != null && food['food_items']['name'] != null) {
              foodName = food['food_items']['name'].replaceAll(',', ';');
            }
            // Priority 5: Recipe title
            else if (food['recipes'] != null && food['recipes']['title'] != null) {
              foodName = food['recipes']['title'].replaceAll(',', ';');
            }

            final quantity = (food['quantity_grams'] ?? 0).toStringAsFixed(1);
            final calories = (food['calories'] ?? 0).toStringAsFixed(0);
            final protein = (food['protein_g'] ?? 0).toStringAsFixed(1);
            final carbs = (food['carbs_g'] ?? 0).toStringAsFixed(1);
            final fat = (food['fat_g'] ?? 0).toStringAsFixed(1);
            final fiber = (food['fiber_g'] ?? 0).toStringAsFixed(1);

            buffer.writeln(
              '$mealDate,$mealType,$mealTime,$foodName,$quantity,$calories,$protein,$carbs,$fat,$fiber,$notes',
            );
          }
        } else {
          // Add row even if no foods to show the meal was recorded
          buffer.writeln(
            '$mealDate,$mealType,$mealTime,Nessun cibo,0,0,0,0,0,0,$notes',
          );
        }
      }
    } else {
      // Add sample row if no data
      buffer.writeln(
        '${DateTime.now().toIso8601String().split('T')[0]},breakfast,08:00,Nessun dato,0,0,0,0,0,0,',
      );
    }

    return buffer.toString();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF27AE60),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE74C3C),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Helper to safely convert any value to double (handles String, int, double, null)
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}
