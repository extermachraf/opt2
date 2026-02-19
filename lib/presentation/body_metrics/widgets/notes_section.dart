import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotesSection extends StatefulWidget {
  final String notes;
  final Function(String) onNotesChanged;

  const NotesSection({
    Key? key,
    required this.notes,
    required this.onNotesChanged,
  }) : super(key: key);

  @override
  State<NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<NotesSection> {
  late TextEditingController _notesController;
  bool _isExpanded = false;
  final int _maxCharacters = 500;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF26C6DA), Color(0xFF00ACC1)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const CustomIconWidget(
                        iconName: 'note_add',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sintomi e Note',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppTheme.seaDeep,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!_isExpanded && _notesController.text.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(top: 0.5.h),
                              child: Text(
                                _notesController.text.length > 50
                                    ? '${_notesController.text.substring(0, 50)}...'
                                    : _notesController.text,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: CustomIconWidget(
                        iconName: 'expand_more',
                        color: AppTheme.textMuted,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isExpanded ? null : 0,
            child:
                _isExpanded
                    ? Padding(
                      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.seaMid.withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 5,
                              maxLength: _maxCharacters,
                              onChanged: widget.onNotesChanged,
                              decoration: InputDecoration(
                                hintText:
                                    'Registra sintomi, effetti collaterali o osservazioni...',
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppTheme.textMuted.withValues(alpha: 0.7),
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(3.w),
                                counterStyle: TextStyle(
                                  fontSize: 10.sp,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppTheme.seaDeep,
                              ),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          _buildSuggestionChips(),
                        ],
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'Affaticamento',
      'Nausea',
      'Perdita di appetito',
      'Aumento di peso',
      'Perdita di peso',
      'Gonfiore',
      'Dolore',
      'Buona energia',
      'Appetito normale',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Suggerimenti rapidi:',
          style: TextStyle(
            fontSize: 11.sp,
            color: AppTheme.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children:
              suggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () {
                    final currentText = _notesController.text;
                    final newText =
                        currentText.isEmpty
                            ? suggestion
                            : '$currentText, $suggestion';

                    if (newText.length <= _maxCharacters) {
                      _notesController.text = newText;
                      widget.onNotesChanged(newText);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.seaMid.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.seaMid.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      suggestion,
                      style: TextStyle(
                        fontSize: 13.sp, // Increased from 11.sp for better readability
                        color: AppTheme.seaMid,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
