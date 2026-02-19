import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<SettingsItemData> items;

  const SettingsSectionWidget({
    Key? key,
    required this.title,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20.sp, // Increased from 18.sp for better readability
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.seaMid.withAlpha(30)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadowSea.withAlpha(15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 0.8.h,
                    ),
                    leading: Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: AppTheme.seaMid.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: item.iconName,
                          color: AppTheme.seaMid,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp, // Increased from 14.sp for better readability
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textDark,
                      ),
                    ),
                    subtitle: item.subtitle != null
                        ? Text(
                            item.subtitle!,
                            style: GoogleFonts.inter(
                              fontSize: 13.sp, // Increased from 11.sp for better readability
                              color: AppTheme.textMuted,
                            ),
                          )
                        : null,
                    trailing: item.hasSwitch
                        ? Switch(
                            value: item.switchValue ?? false,
                            onChanged: item.onSwitchChanged,
                            activeColor: AppTheme.seaMid,
                          )
                        : item.trailingText != null
                            ? Text(
                                item.trailingText!,
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp, // Increased from 12.sp for better readability
                                  color: AppTheme.textMuted,
                                ),
                              )
                            : const CustomIconWidget(
                                iconName: 'chevron_right',
                                color: AppTheme.textMuted,
                                size: 20,
                              ),
                    onTap: item.onTap,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.seaMid.withAlpha(20),
                      indent: 18.w,
                      endIndent: 4.w,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class SettingsItemData {
  final String title;
  final String? subtitle;
  final String iconName;
  final Color iconColor;
  final VoidCallback? onTap;
  final bool hasSwitch;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final String? trailingText;

  SettingsItemData({
    required this.title,
    this.subtitle,
    required this.iconName,
    required this.iconColor,
    this.onTap,
    this.hasSwitch = false,
    this.switchValue,
    this.onSwitchChanged,
    this.trailingText,
  });
}
