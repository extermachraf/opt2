import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onFilterTap;
  final VoidCallback? onVoiceSearch;
  final VoidCallback? onBarcodeSearch;
  final Function(String)? onChanged;

  const SearchBarWidget({
    Key? key,
    required this.controller,
    this.onFilterTap,
    this.onVoiceSearch,
    this.onBarcodeSearch,
    this.onChanged,
  }) : super(key: key);

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  bool _isVoiceActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                decoration: InputDecoration(
                  hintText: 'Cerca ricette, ingredienti...',
                  hintStyle: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 16.sp, // Increased from 15.sp for better readability
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.seaMid,
                      size: 5.w,
                    ),
                  ),
                  // suffixIcon removed - voice search and barcode scanner disabled
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 3.w,
                  ),
                ),
                style: TextStyle(
                  color: AppTheme.seaDeep,
                  fontSize: 15.sp, // Increased from 12.sp for better readability
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          // Filter Button
          GestureDetector(
            onTap: widget.onFilterTap,
            child: Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.seaTop, AppTheme.seaMid],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.seaMid.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CustomIconWidget(
                iconName: 'tune',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
