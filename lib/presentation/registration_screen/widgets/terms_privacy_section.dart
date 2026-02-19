import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import './legal_consent_modal.dart';
import './privacy_policy_modal.dart';

class TermsPrivacySection extends StatelessWidget {
  final bool termsAccepted;
  final bool privacyAccepted;
  final bool dataProcessingAccepted;
  final Function(bool?) onTermsChanged;
  final Function(bool?) onPrivacyChanged;
  final Function(bool?) onDataProcessingChanged;
  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  const TermsPrivacySection({
    Key? key,
    required this.termsAccepted,
    required this.privacyAccepted,
    required this.dataProcessingAccepted,
    required this.onTermsChanged,
    required this.onPrivacyChanged,
    required this.onDataProcessingChanged,
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  }) : super(key: key);

  Future<void> _showLegalConsentModal(BuildContext context) async {
    final result = await showDialog<Map<String, bool>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const LegalConsentModal();
      },
    );

    if (result != null) {
      // Update the consent states based on modal result
      if (result['consentProcessing'] == true) {
        onDataProcessingChanged(true);
      }
      if (result['acceptTerms'] == true) {
        onTermsChanged(true);
        onPrivacyChanged(true);
      }
    }
  }

  Future<void> _showPrivacyPolicyModal(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PrivacyPolicyModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Updated detailed consent information text
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(3.w),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            'I dati gestiti attraverso Nutrivita possono rivelare le tue condizioni di salute. Per poter accedere ai servizi di Nutrivita è necessario esprimere il tuo consenso al trattamento. Leggi con attenzione la Privacy Policy e ricorda che il tuo consenso potrà essere sempre revocato; in caso di revoca del consenso, il tuo profilo sarà rimosso e i tuoi dati cancellati. Ti chiediamo inoltre di rispettare i Termini e le condizioni di utilizzo.',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimaryLight,
              height: 1.5,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // "Con la presente:" text
        Text(
          'Con la presente:',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 3.h),

        // Data Processing Consent Checkbox - Updated with clickable link
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: dataProcessingAccepted,
              onChanged: onDataProcessingChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppTheme.lightTheme.colorScheme.primary,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.w),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryLight,
                    ),
                    children: [
                      TextSpan(
                        text: 'acconsento al trattamento di dati personali',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPrivacyPolicyModal(context),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Terms of Service Checkbox - Updated text
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: termsAccepted,
              onChanged: onTermsChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppTheme.lightTheme.colorScheme.primary,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.w),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryLight,
                    ),
                    children: [
                      const TextSpan(
                        text: 'dichiaro di conoscere e accettare i ',
                      ),
                      TextSpan(
                        text: 'termini e le condizioni di utilizzo',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = onTermsPressed,
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 2.h),

        // Privacy Policy Checkbox - Updated text
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: privacyAccepted,
              onChanged: onPrivacyChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AppTheme.lightTheme.colorScheme.primary,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 2.w),
                child: RichText(
                  text: TextSpan(
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryLight,
                    ),
                    children: [
                      const TextSpan(
                        text: 'dichiaro di aver letto e accettato l\'',
                      ),
                      TextSpan(
                        text: 'informativa sulla privacy',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPrivacyPolicyModal(context),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 3.h),

        // Info text - Updated
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(2.w),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange.shade700,
                size: 4.w,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Tutti i consensi sopra elencati devono essere selezionati per poter procedere con la registrazione.',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
