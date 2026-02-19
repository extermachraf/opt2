import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Custom input field for screening pages with suffix support (cm, Kg, Kcal)
class ScreeningInputField extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const ScreeningInputField({
    Key? key,
    required this.controller,
    required this.suffix,
    required this.hint,
    this.keyboardType = TextInputType.number,
    this.inputFormatters,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1A5F6F).withOpacity(0.4), // Darker teal background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4DD0E1).withOpacity(0.5),
          width: 1.5,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              validator: validator,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF004D40), // Dark teal for better visibility
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF004D40).withOpacity(0.4),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            suffix,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF004D40).withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
