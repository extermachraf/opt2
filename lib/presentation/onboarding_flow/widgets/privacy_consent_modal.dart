import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../registration_screen/widgets/pdf_viewer_modal.dart';

class PrivacyConsentModal extends StatefulWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const PrivacyConsentModal({
    Key? key,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  @override
  State<PrivacyConsentModal> createState() => _PrivacyConsentModalState();
}

class _PrivacyConsentModalState extends State<PrivacyConsentModal> {
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _acceptHealthData = false;

  bool get _allAccepted => _acceptTerms && _acceptPrivacy && _acceptHealthData;

  // Ocean Blue Dark Theme Colors for Modal
  static const Color _modalBg = Color(0xFF165B6E); // Slightly lighter petrolio for popup
  static const Color _modalHeaderBg = Color(0xFF0F4C5C); // Darker header
  static const Color _tealAccent = Color(0xFF80CBC4); // Teal accent
  static const Color _textLight = Color(0xFFFFFFFF);
  static const Color _textMuted = Color(0xFFCFD8DC);
  static const Color _checkItemBg = Color(0x33000000); // 20% black
  static const Color _buttonAccept = Color(0xFFE0E0E0);
  static const Color _buttonAcceptText = Color(0xFF37474F);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 90.w,
        constraints: BoxConstraints(maxHeight: 80.h),
        decoration: BoxDecoration(
          color: _modalBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(128),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header - Dark Ocean Blue styled
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: _modalHeaderBg.withAlpha(128),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Shield icon with background
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(26),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '🛡️',
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Privacy e Consenso',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: _tealAccent,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    'Dati Sanitari',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _textLight,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'La privacy dei tuoi dati sanitari è la nostra priorità',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Content - Dark themed
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Per fornirti un monitoraggio nutrizionale personalizzato e l\'integrazione con i fornitori sanitari, abbiamo bisogno del tuo consenso per:',
                      style: TextStyle(
                        fontSize: 14,
                        color: _textMuted,
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Terms of Service
                    _buildConsentItem(
                      icon: 'description',
                      title: 'Termini di Servizio',
                      description:
                          'Accordo per utilizzare NutriVita secondo i nostri termini e condizioni',
                      value: _acceptTerms,
                      onChanged: (value) =>
                          setState(() => _acceptTerms = value ?? false),
                    ),

                    SizedBox(height: 2.h),

                    // Privacy Policy
                    _buildConsentItem(
                      icon: 'privacy_tip',
                      title: 'Informativa sulla Privacy',
                      description:
                          'Come raccogliamo, utilizziamo e proteggiamo le tue informazioni personali',
                      value: _acceptPrivacy,
                      onChanged: (value) =>
                          setState(() => _acceptPrivacy = value ?? false),
                      onTap: () async {
                        await showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (BuildContext context) {
                            return const PdfViewerModal();
                          },
                        );
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Health Data Processing
                    _buildConsentItem(
                      icon: 'medical_information',
                      title: 'Elaborazione',
                      description:
                          'Elaborazione di dati nutrizionali e sanitari per supporto terapeutico e supervisione dei fornitori sanitari',
                      value: _acceptHealthData,
                      onChanged: (value) =>
                          setState(() => _acceptHealthData = value ?? false),
                      isRequired: true,
                    ),

                    SizedBox(height: 3.h),

                    // HIPAA Compliance Notice - Dark themed
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: _tealAccent.withAlpha(26),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _tealAccent.withAlpha(77),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _tealAccent.withAlpha(51),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text('✓', style: TextStyle(color: _tealAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              'NutriVita è conforme HIPAA e segue standard di sicurezza medici per la protezione dei tuoi dati sanitari.',
                              style: TextStyle(
                                fontSize: 12,
                                color: _tealAccent,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons - Dark themed
            Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  // Accept button - Light button on dark background
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _allAccepted ? widget.onAccept : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _allAccepted
                            ? _buttonAccept
                            : Colors.white.withAlpha(51),
                        foregroundColor: _buttonAcceptText,
                        disabledBackgroundColor: Colors.white.withAlpha(26),
                        disabledForegroundColor: Colors.white.withAlpha(77),
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Accetta e Continua',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // Decline button - Transparent with border
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: widget.onDecline,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Colors.white.withAlpha(51)),
                        ),
                      ),
                      child: Text(
                        'Rifiuta',
                        style: TextStyle(
                          fontSize: 14,
                          color: _textMuted,
                        ),
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

  Widget _buildConsentItem({
    required String icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool?> onChanged,
    bool isRequired = false,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: _checkItemBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: _tealAccent,
            checkColor: _modalBg,
            side: BorderSide(color: Colors.white.withAlpha(77)),
          ),
          SizedBox(width: 2.w),
          CustomIconWidget(
            iconName: icon,
            color: _tealAccent,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: onTap != null
                          ? GestureDetector(
                              onTap: onTap,
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textLight,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            )
                          : Text(
                              title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textLight,
                              ),
                            ),
                    ),
                    isRequired
                        ? Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF5252).withAlpha(51),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Obbligatorio',
                              style: TextStyle(
                                fontSize: 10,
                                color: const Color(0xFFFF8A80),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: _textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
