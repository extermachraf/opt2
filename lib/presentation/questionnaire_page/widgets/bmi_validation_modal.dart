import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/body_metrics_service.dart';
import '../../../theme/app_theme.dart';

class BMIValidationModal extends StatelessWidget {
  final BMIValidationResult validationResult;
  final VoidCallback? onUpdatePressed;
  final VoidCallback? onCancelPressed;

  const BMIValidationModal({
    Key? key,
    required this.validationResult,
    this.onUpdatePressed,
    this.onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enhanced Warning Icon with Ocean Theme
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.seaTop.withAlpha(51),
                    AppTheme.seaMid.withAlpha(51),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.scale_outlined,
                size: 40,
                color: AppTheme.seaMid,
              ),
            ),

            SizedBox(height: 3.h),

            // Enhanced Title with Ocean Theme
            Text(
              'Aggiornamento BMI Richiesto',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Enhanced Message with better formatting
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                validationResult.message,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 2.h),

            // Enhanced Requirements Info with Ocean Theme
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.seaTop.withAlpha(26),
                    AppTheme.seaMid.withAlpha(26),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.seaTop.withAlpha(77), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.update,
                        size: 20,
                        color: AppTheme.seaDeep,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Dati da aggiornare oggi:',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.seaDeep,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  if (validationResult.requiresWeightUpdate) ...[
                    _buildRequirementItem(
                      icon: Icons.monitor_weight_outlined,
                      title: 'Peso corporeo',
                      subtitle: 'Inserisci il peso di oggi',
                    ),
                    if (validationResult.requiresHeightUpdate)
                      SizedBox(height: 1.h),
                  ],
                  if (validationResult.requiresHeightUpdate) ...[
                    _buildRequirementItem(
                      icon: Icons.height,
                      title: 'Altezza',
                      subtitle: 'Conferma o aggiorna l\'altezza',
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 1.5.h),

            // Enhanced Info Box
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Il BMI deve essere aggiornato quotidianamente per garantire valutazioni accurate.',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.amber.shade800,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            // Enhanced Action Buttons
            Row(
              children: [
                // Cancel Button with better styling
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      print('🚫 BMI validation modal cancelled');
                      if (onCancelPressed != null) {
                        onCancelPressed!();
                      }
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Annulla',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 4.w),

                // Update Button with Ocean Theme
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.seaTop, AppTheme.seaMid],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.seaMid.withAlpha(77),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        print(
                            '✅ BMI validation modal - redirecting to body metrics');
                        Navigator.of(context).pop();
                        if (onUpdatePressed != null) {
                          onUpdatePressed!();
                        } else {
                          // Default navigation to body metrics page
                          Navigator.pushNamed(
                            context,
                            AppRoutes.bodyMetrics,
                            arguments: {
                              'highlightBMI': true,
                              'requiredUpdate': {
                                'weight': validationResult.requiresWeightUpdate,
                                'height': validationResult.requiresHeightUpdate,
                              },
                            },
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.update, size: 18, color: Colors.white),
                          SizedBox(width: 2.w),
                          Text(
                            'Aggiorna Ora',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.seaTop.withAlpha(51), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.seaTop.withAlpha(51),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppTheme.seaMid,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.seaDeep,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: AppTheme.seaMid,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced static show method with additional options
  static Future<void> show({
    required BuildContext context,
    required BMIValidationResult validationResult,
    VoidCallback? onUpdatePressed,
    VoidCallback? onCancelPressed,
    bool barrierDismissible = false,
  }) {
    // Log modal display for debugging
    print('📱 Showing BMI validation modal: ${validationResult.message}');

    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => BMIValidationModal(
        validationResult: validationResult,
        onUpdatePressed: onUpdatePressed,
        onCancelPressed: onCancelPressed,
      ),
    );
  }
}
