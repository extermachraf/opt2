import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../theme/app_theme.dart';

class EducationalSectionWidget extends StatefulWidget {
  final Map<String, dynamic> section;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;

  const EducationalSectionWidget({
    super.key,
    required this.section,
    required this.isBookmarked,
    required this.onBookmarkToggle,
  });

  @override
  State<EducationalSectionWidget> createState() =>
      _EducationalSectionWidgetState();
}

class _EducationalSectionWidgetState extends State<EducationalSectionWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            onTap: _toggleExpansion,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(_isExpanded ? 0 : 16),
              bottomRight: Radius.circular(_isExpanded ? 0 : 16),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.seaMid.withAlpha(15),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(_isExpanded ? 0 : 16),
                  bottomRight: Radius.circular(_isExpanded ? 0 : 16),
                ),
              ),
              child: Row(
                children: [
                  // Icon
                  Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.seaTop, AppTheme.seaMid],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CustomIconWidget(
                      iconName: widget.section['icon'],
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Title
                  Expanded(
                    child: Text(
                      widget.section['title'],
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),

                  // Bookmark button
                  IconButton(
                    onPressed: widget.onBookmarkToggle,
                    icon: CustomIconWidget(
                      iconName:
                          widget.isBookmarked ? 'bookmark' : 'bookmark_border',
                      color: widget.isBookmarked
                          ? AppTheme.seaMid
                          : AppTheme.textMuted,
                      size: 22,
                    ),
                  ),

                  // Expand/Collapse icon
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: const CustomIconWidget(
                      iconName: 'keyboard_arrow_down',
                      color: AppTheme.seaMid,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildContent(widget.section['content']),
                  SizedBox(height: 2.h),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.seaTop, AppTheme.seaMid],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showFullContentModal(context),
                            borderRadius: BorderRadius.circular(20),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CustomIconWidget(
                                    iconName: 'fullscreen',
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Leggi tutto',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(String content) {
    // Parse content for better formatting
    final lines = content.split('\n');
    List<Widget> contentWidgets = [];

    for (String line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        contentWidgets.add(SizedBox(height: 1.h));
        continue;
      }

      // Bold text (between **)
      if (line.startsWith('**') && line.endsWith('**')) {
        contentWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 1.h, top: 0.5.h),
            child: Text(
              line.replaceAll('**', ''),
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
          ),
        );
      }
      // Bullet points
      else if (line.startsWith('•')) {
        contentWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 0.5.h, left: 2.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 1.h, right: 2.w),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.seaMid,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    line.substring(1).trim(),
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      // Regular text
      else {
        contentWidgets.add(
          Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: Text(
              line,
              style: GoogleFonts.inter(
                fontSize: 15.sp, // Increased from 13.sp for better readability
                color: AppTheme.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  void _showFullContentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.seaMid.withAlpha(50),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.seaTop.withAlpha(30),
                      AppTheme.seaMid.withAlpha(20),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.seaTop, AppTheme.seaMid],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomIconWidget(
                        iconName: widget.section['icon'],
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        widget.section['title'],
                        style: GoogleFonts.inter(
                          fontSize: 20.sp, // Increased from 18.sp for better readability
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.seaMid.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const CustomIconWidget(
                          iconName: 'close',
                          color: AppTheme.seaMid,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Full content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  child: _buildContent(widget.section['content']),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
