import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class PageIndicatorWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;

  const PageIndicatorWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          totalPages,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(horizontal: 1.w),
            width: index == currentPage ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color:
                  index == currentPage
                      ? const Color(0xFFFF9800) // Orange for active dot (matching HTML)
                      : Colors.white.withAlpha(77), // 30% white for inactive dots on dark bg
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}
