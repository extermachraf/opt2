import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({
    Key? key,
    required this.password,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strength = _calculatePasswordStrength(password);
    final strengthText = _getStrengthText(strength);
    final strengthColor = _getStrengthColor(strength);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 0.5.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: strength / 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: strengthColor,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              strengthText,
              style: TextStyle(
                fontSize: 12.sp,
                color: strengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (password.isNotEmpty) ...[
          SizedBox(height: 1.h),
          _buildRequirementsList(),
        ],
      ],
    );
  }

  Widget _buildRequirementsList() {
    final requirements = [
      {'text': 'Almeno 8 caratteri', 'met': password.length >= 8},
      {
        'text': 'Una lettera maiuscola',
        'met': password.contains(RegExp(r'[A-Z]'))
      },
      {
        'text': 'Una lettera minuscola',
        'met': password.contains(RegExp(r'[a-z]'))
      },
      {'text': 'Un numero', 'met': password.contains(RegExp(r'[0-9]'))},
      {
        'text': 'Un carattere speciale',
        'met': password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))
      },
    ];

    return Column(
      children: requirements.map((req) {
        final isMet = req['met'] as bool;
        return Padding(
          padding: EdgeInsets.only(bottom: 0.5.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: isMet ? 'check_circle' : 'radio_button_unchecked',
                color: isMet
                    ? AppTheme.loginCredsAccent
                    : AppTheme.loginTextMuted,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                req['text'] as String,
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: isMet
                      ? AppTheme.loginCredsAccent
                      : AppTheme.loginTextMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  int _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    return strength;
  }

  String _getStrengthText(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return 'Debole';
      case 2:
      case 3:
        return 'Media';
      case 4:
      case 5:
        return 'Forte';
      default:
        return 'Debole';
    }
  }

  Color _getStrengthColor(int strength) {
    switch (strength) {
      case 0:
      case 1:
        return AppTheme.lightTheme.colorScheme.error;
      case 2:
      case 3:
        return AppTheme.warningLight;
      case 4:
      case 5:
        return AppTheme.lightTheme.colorScheme.tertiary;
      default:
        return AppTheme.lightTheme.colorScheme.error;
    }
  }
}
