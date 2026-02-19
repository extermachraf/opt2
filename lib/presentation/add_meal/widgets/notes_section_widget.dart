import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotesSectionWidget extends StatefulWidget {
  final String notes;
  final Function(String) onNotesChanged;
  final bool saveAsFavorite;
  final Function(bool) onSaveAsFavoriteChanged;
  final bool shareWithProvider;
  final Function(bool) onShareWithProviderChanged;

  const NotesSectionWidget({
    Key? key,
    required this.notes,
    required this.onNotesChanged,
    required this.saveAsFavorite,
    required this.onSaveAsFavoriteChanged,
    required this.shareWithProvider,
    required this.onShareWithProviderChanged,
  }) : super(key: key);

  @override
  State<NotesSectionWidget> createState() => _NotesSectionWidgetState();
}

class _NotesSectionWidgetState extends State<NotesSectionWidget> {
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  bool _isExpanded = false;
  static const int _maxCharacters = 500;

  // Ocean Blue colors
  static const Color _seaMid = Color(0xFF00ACC1);
  static const Color _seaDeep = Color(0xFF006064);
  static const Color _textMuted = Color(0xFF78909C);
  static const Color _textDark = Color(0xFF006064);
  static const Color _accentLight = Color(0xFFE0F7FA);
  static const Color _inputBg = Color(0xFFF0F8FF);
  static const Color _accentSand = Color(0xFFFFB74D);
  static const Color _accentWave = Color(0xFF4DD0E1);

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.notes;
    _notesController.addListener(() {
      widget.onNotesChanged(_notesController.text);
    });

    _notesFocusNode.addListener(() {
      setState(() {
        _isExpanded =
            _notesFocusNode.hasFocus || _notesController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _seaDeep.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('📝', style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 2.w),
              Text(
                'Note aggiuntive',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildNotesField(),
          SizedBox(height: 3.h),
          _buildOptionsSection(),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    final characterCount = _notesController.text.length;
    final isOverLimit = characterCount > _maxCharacters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _notesFocusNode.hasFocus ? _seaMid : Colors.transparent,
              width: _notesFocusNode.hasFocus ? 2 : 0,
            ),
          ),
          child: TextField(
            controller: _notesController,
            focusNode: _notesFocusNode,
            maxLines: _isExpanded ? 6 : 3,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Aggiungi osservazioni correlate al trattamento...',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: _textMuted,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(4.w),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: _textDark,
            ),
            textInputAction: TextInputAction.newline,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Note correlate al trattamento aiutano il team sanitario',
                style: TextStyle(
                  fontSize: 14.sp, // Increased from 11.sp for better readability
                  color: _textMuted,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              '$characterCount/$_maxCharacters',
              style: TextStyle(
                fontSize: 13.sp,
                color: isOverLimit ? Colors.red : _textMuted,
                fontWeight: isOverLimit ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ],
        ),
        if (isOverLimit) ...[
          SizedBox(height: 0.5.h),
          Row(
            children: [
              const CustomIconWidget(
                iconName: 'warning',
                color: Colors.red,
                size: 14,
              ),
              SizedBox(width: 1.w),
              Text(
                'Limite di caratteri superato',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        _buildOptionTile(
          emoji: '❤️',
          inactiveEmoji: '🤍',
          title: 'Salva come ricetta preferita',
          subtitle: 'Accesso rapido per futuri pasti registrati',
          value: widget.saveAsFavorite,
          onChanged: widget.onSaveAsFavoriteChanged,
          activeColor: _accentSand,
        ),
        SizedBox(height: 2.h),
        _buildOptionTile(
          emoji: '📤',
          inactiveEmoji: '📤',
          title: 'Condividi con operatore sanitario',
          subtitle: 'Includi nel prossimo report per revisione medica',
          value: widget.shareWithProvider,
          onChanged: widget.onShareWithProviderChanged,
          activeColor: _seaMid,
        ),
      ],
    );
  }

  Widget _buildOptionTile({
    required String emoji,
    required String inactiveEmoji,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required Color activeColor,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: value ? _accentLight : _inputBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: value ? activeColor : const Color(0xFFE0E0E0),
            width: value ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon container with emoji - always visible
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: value ? activeColor.withValues(alpha: 0.2) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? activeColor.withValues(alpha: 0.3) : const Color(0xFFE0E0E0),
                ),
              ),
              child: Center(
                child: Text(
                  value ? emoji : inactiveEmoji,
                  style: TextStyle(fontSize: 20.sp),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp, // Increased from 14.sp for better readability
                      fontWeight: FontWeight.w600,
                      color: value ? _textDark : _textMuted,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp, // Increased from 11.sp for better readability
                      color: _textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Custom toggle switch
            Container(
              width: 14.w,
              height: 7.w,
              decoration: BoxDecoration(
                color: value ? activeColor : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: value ? 7.w : 1.w,
                    top: 1.w,
                    child: Container(
                      width: 5.w,
                      height: 5.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
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
}
