import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../theme/app_theme.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSearchChanged;
  final String hintText;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.onSearchChanged,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.seaMid.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.seaMid.withAlpha(40)),
      ),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          color: AppTheme.textDark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            color: AppTheme.textMuted,
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(3.w),
            child: const CustomIconWidget(
              iconName: 'search',
              color: AppTheme.seaMid,
              size: 22,
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                  icon: const CustomIconWidget(
                    iconName: 'clear',
                    color: AppTheme.textMuted,
                    size: 18,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        ),
      ),
    );
  }
}
