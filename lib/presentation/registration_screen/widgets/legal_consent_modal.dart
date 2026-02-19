import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class LegalConsentModal extends StatefulWidget {
  const LegalConsentModal({Key? key}) : super(key: key);

  @override
  State<LegalConsentModal> createState() => _LegalConsentModalState();
}

class _LegalConsentModalState extends State<LegalConsentModal> {
  bool _consentProcessing = false;
  bool _acknowledgeDpia = false;
  bool _acceptTerms = false;

  bool get _allBoxesChecked =>
      _consentProcessing && _acknowledgeDpia && _acceptTerms;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.w)),
      insetPadding: EdgeInsets.all(4.w),
      child: Container(
        constraints: BoxConstraints(maxHeight: 85.h, maxWidth: 95.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.w),
                  topRight: Radius.circular(4.w),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Data Protection and Privacy Agreement',
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Introduction
                    Text(
                      'Before creating your account, please read and accept the following important information about how we handle your data.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimaryLight,
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Consent Section
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(3.w),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // First Checkbox - Consent to processing
                          _buildCheckboxItem(
                            value: _consentProcessing,
                            onChanged: (value) {
                              setState(() {
                                _consentProcessing = value ?? false;
                              });
                            },
                            title:
                                'I consent to the processing of my personal and health data.',
                            content:
                                'I understand that Nutrivita, provided by AIOM, will process my data, including special categories (health data), as described in the Privacy Policy, for the purpose of nutritional management and support.',
                          ),

                          SizedBox(height: 3.h),

                          // Second Checkbox - DPIA acknowledgment
                          _buildCheckboxItem(
                            value: _acknowledgeDpia,
                            onChanged: (value) {
                              setState(() {
                                _acknowledgeDpia = value ?? false;
                              });
                            },
                            title:
                                'I acknowledge that I have been informed about the Data Protection Impact Assessment (DPIA).',
                            content:
                                'A DPIA has been conducted for this app. Key findings include:',
                            bulletPoints: [
                              'The app is designed for vulnerable data subjects (oncology patients).',
                              'It processes highly sensitive health data.',
                              'All identified risks (e.g., unauthorized access, data breaches) have been assessed and mitigated, resulting in a low residual risk level.',
                              'Data is stored securely on Google Firebase platforms within the European Economic Area (EEA).',
                            ],
                          ),

                          SizedBox(height: 3.h),

                          // Third Checkbox - Terms and Privacy
                          _buildCheckboxItem(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                            title:
                                'I accept the Terms of Service and Privacy Policy.',
                            content:
                                'I agree to the general terms governing the use of the Nutrivita application.',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Withdrawal Information
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(2.w),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You may withdraw your consent at any time by deleting your account via the app settings. Withdrawal of consent does not affect the lawfulness of processing based on consent before its withdrawal.',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue.shade800,
                              fontStyle: FontStyle.italic,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          RichText(
                            text: TextSpan(
                              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                                color: Colors.blue.shade800,
                                fontStyle: FontStyle.italic,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                      'For more details, please refer to the full ',
                                ),
                                TextSpan(
                                  text: 'DPIA Summary',
                                  style: TextStyle(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: Navigate to DPIA Summary
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'DPIA Summary - Link to be implemented',
                                              ),
                                            ),
                                          );
                                        },
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer:
                                      TapGestureRecognizer()
                                        ..onTap = () {
                                          // TODO: Navigate to Privacy Policy
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Privacy Policy - Link to be implemented',
                                              ),
                                            ),
                                          );
                                        },
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.w),
                  bottomRight: Radius.circular(4.w),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          _allBoxesChecked
                              ? () {
                                Navigator.of(context).pop({
                                  'consentProcessing': _consentProcessing,
                                  'acknowledgeDpia': _acknowledgeDpia,
                                  'acceptTerms': _acceptTerms,
                                });
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _allBoxesChecked
                                ? AppTheme.lightTheme.colorScheme.primary
                                : Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 3.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                      ),
                      child: Text(
                        'Accept All',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool value,
    required Function(bool?) onChanged,
    required String title,
    required String content,
    List<String>? bulletPoints,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          activeColor: AppTheme.lightTheme.colorScheme.primary,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                content,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textPrimaryLight,
                  height: 1.4,
                ),
              ),
              if (bulletPoints != null) ...[
                SizedBox(height: 1.h),
                ...bulletPoints.map(
                  (point) => Padding(
                    padding: EdgeInsets.only(left: 4.w, bottom: 0.5.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppTheme.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color: AppTheme.textPrimaryLight,
                                  height: 1.3,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
