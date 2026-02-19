import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class TutorialSlideWidget extends StatelessWidget {
  final String title;
  final String description;
  final String? image;
  final List<String> features;
  final int currentPage;
  final int totalPages;

  const TutorialSlideWidget({
    Key? key,
    required this.title,
    required this.description,
    this.image,
    required this.features,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),

          // Page Counter
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
                ),
              ),
              child: Text(
                '$currentPage di $totalPages completato',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Main Image (only show if image is provided and not null)
          if (image != null && image!.isNotEmpty) ...[
            _buildImage(),
            SizedBox(height: 4.h),
          ],

          // Title
          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),

          SizedBox(height: 3.h),

          // Description
          Center(
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                height: 1.5,
                fontSize: 16.sp,
              ),
            ),
          ),

          SizedBox(height: 4.h),

          // Features List
          // _buildFeaturesList(),

          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4.w),
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Return empty container if image is null or empty
    if (image == null || image!.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if it's a local asset or network image
    if (image!.startsWith('assets/')) {
      return Image.asset(
        image!,
        fit: BoxFit.contain,
        semanticLabel: _getSemanticLabel(),
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      return CachedNetworkImage(
        imageUrl: image!,
        fit: BoxFit.contain,
        placeholder: (context, url) => _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorPlaceholder(),
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.grey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
              strokeWidth: 3,
            ),
            SizedBox(height: 2.h),
            Text(
              'Caricamento immagine...',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey.shade50,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_outlined, size: 12.w, color: Colors.grey.shade400),
            SizedBox(height: 2.h),
            Text(
              'Immagine non disponibile',
              style: TextStyle(color: Colors.white, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildFeaturesList() {
  //   return Container(
  //     padding: EdgeInsets.all(4.w),
  //     decoration: BoxDecoration(
  //       color: AppTheme.lightTheme.colorScheme.primaryContainer.withAlpha(77),
  //       borderRadius: BorderRadius.circular(3.w),
  //       border: Border.all(
  //         color: AppTheme.lightTheme.colorScheme.primary.withAlpha(51),
  //       ),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             Icon(
  //               Icons.star,
  //               color: AppTheme.lightTheme.colorScheme.primary,
  //               size: 5.w,
  //             ),
  //             SizedBox(width: 2.w),
  //             Text(
  //               'Funzionalità principali:',
  //               style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 2.h),
  //         ...features
  //             .map(
  //               (feature) => Padding(
  //                 padding: EdgeInsets.only(bottom: 1.5.h),
  //                 child: Row(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Container(
  //                       margin: EdgeInsets.only(top: 0.5.h),
  //                       child: Icon(
  //                         Icons.check_circle,
  //                         color: AppTheme.lightTheme.colorScheme.primary,
  //                         size: 4.w,
  //                       ),
  //                     ),
  //                     SizedBox(width: 3.w),
  //                     Expanded(
  //                       child: Text(
  //                         feature,
  //                         style: AppTheme.lightTheme.textTheme.bodyMedium
  //                             ?.copyWith(
  //                           color: Colors.white,
  //                           height: 1.4,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             )
  //             .toList(),
  //       ],
  //     ),
  //   );
  // }

  String _getSemanticLabel() {
    // Generate semantic labels based on slide content
    switch (currentPage) {
      case 1:
        return "NutriVita welcome screen with app introduction and tutorial text";
      case 2:
        return "NutriVita dashboard showing progress section highlighted with calories and weight display, plus complete quick actions section with 6 action buttons";
      case 3:
        return "NutriVita dashboard showing Aggiungi pasto button highlighted in red box within Azioni rapide section, with full dashboard view including Progresso di oggi section, all quick action buttons, and bottom navigation visible";
      case 4:
        return "Fresh vegetables and healthy meal preparation scene representing meal diary functionality";
      case 5:
        return "NutriVita dashboard showing Valutazione button highlighted in red box within Azioni rapide section, with full dashboard view including Progresso di oggi section showing calories (0 kcal) and weight (68.0 kg), all quick action buttons, and bottom navigation visible";
      case 6:
        return "NutriVita dashboard showing Approfondimenti button highlighted in red box within Azioni rapide section, with full dashboard view including Progresso di oggi section showing calories (0 kcal) and weight (68.0 kg), all quick action buttons, and bottom navigation visible";
      case 7:
        return "NutriVita dashboard showing Visualizza report button highlighted in red box within Azioni rapide section, with full dashboard view including Progresso di oggi section showing calories (0 kcal) and weight (68.0 kg), all quick action buttons, and bottom navigation visible";
      case 8:
        return "NutriVita dashboard showing Ricette button highlighted in red box within Azioni rapide section, with full dashboard view including Progresso di oggi section showing calories (0 kcal) and weight (68.0 kg), all quick action buttons, and bottom navigation visible";
      case 9:
        return "Diario pasti screen showing 29 Ottobre 2025 Martedì with empty state message Nessun pasto registrato oggi, search bar Tocca per cercare pasti, Aggiungi pasto button with plus icon, and Scatta foto button with camera icon, all contained within red border frame";
      case 10:
        return "Aggiungi pasto screen showing meal entry form with Data del pasto (today), Tipo di pasto selection with Colazione highlighted, Pranzo, Cena, Spuntino options, Orario set to 12:30, and Cerca cibo nel database search field with placeholder text, all contained within red border frame";
      case 11:
        return "Aggiungi pasto screen showing photo capture section with camera icon, Aggiungi una foto del pasto text, Apri fotocamera and Seleziona da galleria buttons, plus Note aggiuntive section with text field for treatment-related observations, all contained within red border frame";
      case 12:
        return "Diario pasti screen showing 24 Ottobre 2025 Venerdi with detailed meal entries: Pranzo (12:00) showing Involtini di pollo con prosciutto e formaggio with nutritional breakdown (60 kcal, 34.0g proteine, 1.0g carboidrati, 18.0g grassi), and Cena (18:30) showing Insalata di riso with complete nutritional values (102 kcal, 21.0g proteine, 71.0g carboidrati, 18.0g grassi), all contained within red border frame";
      case 13:
        return "Reports screen showing Genera PDF button, Settimanale dropdown selection, Riassunto nutrizionale Weekly with colored nutritional summary boxes (912 kcal in green, 85.9g in blue, 317.7g in orange, 182.6g in pink), 364 Ingredienti and 5 pasti totali statistics, Distribuzione macronutrienti chart section, and bottom action buttons Dashboard and Condividi report, all contained within red border frame";
      default:
        return "NutriVita app tutorial slide showing nutrition and health monitoring features";
    }
  }
}
