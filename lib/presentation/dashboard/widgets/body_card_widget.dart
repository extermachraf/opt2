import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../../core/app_export.dart';
import '../../../services/body_metrics_service.dart';

class BodyCardWidget extends StatefulWidget {
  const BodyCardWidget({Key? key}) : super(key: key);

  @override
  State<BodyCardWidget> createState() => _BodyCardWidgetState();
}

class _BodyCardWidgetState extends State<BodyCardWidget> {
  final BodyMetricsService _bodyMetricsService = BodyMetricsService.instance;

  // Data state
  Map<String, dynamic>? _bodyMetrics;
  bool _isLoading = true;
  String? _error;

  // Real-time subscription
  late RealtimeChannel? _weightEntriesChannel;
  late RealtimeChannel? _medicalProfilesChannel;

  @override
  void initState() {
    super.initState();
    _loadBodyMetrics();
    _setupRealtimeSubscription();
  }

  @override
  void dispose() {
    _weightEntriesChannel?.unsubscribe();
    _medicalProfilesChannel?.unsubscribe();
    super.dispose();
  }

  // Setup proper real-time subscriptions for weight entries
  void _setupRealtimeSubscription() {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      // Subscribe to weight_entries changes for current user
      _weightEntriesChannel = Supabase.instance.client
          .channel('body_card_weight_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'weight_entries',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              if (mounted) {
                print(
                    'Weight entries changed in body card, refreshing data...');
                _loadBodyMetrics();
              }
            },
          )
          .subscribe();

      // Subscribe to medical_profiles changes for current user
      _medicalProfilesChannel = Supabase.instance.client
          .channel('body_card_medical_changes')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'medical_profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              if (mounted) {
                print(
                    'Medical profile changed in body card, refreshing data...');
                _loadBodyMetrics();
              }
            },
          )
          .subscribe();
    } catch (e) {
      print('Failed to setup real-time subscription in body card: $e');
    }
  }

  Future<void> _loadBodyMetrics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _bodyMetricsService.getBodyMetricsSummary();

      if (mounted) {
        setState(() {
          _bodyMetrics = summary;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.bodyMetrics);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        margin: EdgeInsets.only(bottom: 2.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF006064).withValues(alpha: 0.12),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null || _bodyMetrics == null) {
      return _buildErrorState();
    }

    return _buildDataState();
  }

  Widget _buildLoadingState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF00ACC1), // seaMid
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          'Caricamento...',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF78909C), // textMuted
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CustomIconWidget(
          iconName: 'error_outline',
          size: 24,
          color: Color(0xFFE74C3C), // errorLight
        ),
        SizedBox(width: 2.w),
        Text(
          'Tocca per riprovare',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xFF78909C), // textMuted
          ),
        ),
      ],
    );
  }

  Widget _buildDataState() {
    final medicalProfile =
        _bodyMetrics?['medical_profile'] as Map<String, dynamic>?;
    // FIXED: Use today's weight instead of latest weight
    final todayWeight =
        _bodyMetrics?['today_weight'] as Map<String, dynamic>?;
    final latestWeight =
        _bodyMetrics?['latest_weight'] as Map<String, dynamic>?;

    // Extract values - prioritize today's weight
    final weight = todayWeight?['weight_kg']?.toDouble() ??
        medicalProfile?['current_weight_kg']?.toDouble();
    final height = medicalProfile?['height_cm']?.toDouble();
    final lastUpdated =
        todayWeight?['recorded_at'] ?? todayWeight?['created_at'];

    // Calculate BMI if we have both weight and height
    double? bmi;
    if (weight != null && height != null && height > 0) {
      bmi =
          _bodyMetricsService.calculateBMI(weightKg: weight, heightCm: height);
    }

    // Format last updated date
    String lastUpdateText = 'Ultimo aggiornamento: ';
    if (lastUpdated != null) {
      try {
        final DateTime updateDate = DateTime.parse(lastUpdated.toString());
        final DateTime now = DateTime.now();
        final difference = now.difference(updateDate);

        if (difference.inDays == 0) {
          lastUpdateText += 'Oggi';
        } else if (difference.inDays == 1) {
          lastUpdateText += 'Ieri';
        } else if (difference.inDays < 7) {
          lastUpdateText += '${difference.inDays} giorni fa';
        } else {
          lastUpdateText +=
              '${updateDate.day}/${updateDate.month}/${updateDate.year}';
        }
      } catch (e) {
        lastUpdateText += 'Data non disponibile';
      }
    } else {
      lastUpdateText += 'Non disponibile';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with title and menu icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Metriche corporee',
                style: TextStyle(
                  fontSize: 20.sp, // Increased from 18.sp for better readability
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF004D40), // textDark
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFE0F7FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CustomIconWidget(
                  iconName: 'more_horiz',
                  color: Color(0xFF00838F),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.5.h),
        // Metrics row with icons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Weight stat
            Expanded(
              child: _buildBodyStat(
                weight != null ? weight.toStringAsFixed(1) : 'N/A',
                'kg',
                'Peso',
                'restaurant', // fork/knife icon for weight
                false,
              ),
            ),
            // Height stat
            Expanded(
              child: _buildBodyStat(
                height != null ? '${height.toInt()}' : 'N/A',
                'cm',
                'Altezza',
                'straighten', // ruler icon for height
                false,
              ),
            ),
            // BMI stat (with emoji like screenshot)
            Expanded(
              child: _buildBodyStat(
                bmi != null ? bmi.toStringAsFixed(1) : 'N/A',
                '',
                'BMI',
                'emoji_emotions', // emoji icon for BMI
                true, // isHighlighted for green/orange color
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        // Divider
        Container(
          height: 1,
          color: const Color(0xFFECEFF1),
        ),
        SizedBox(height: 1.5.h),
        // Footer row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                lastUpdateText,
                style: TextStyle(
                  fontSize: 13.sp, // Increased from 11.sp for better readability
                  color: const Color(0xFF78909C), // textMuted
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 2.w),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tocca per gestire',
                  style: TextStyle(
                    fontSize: 14.sp, // Increased from 12.sp for better readability
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00ACC1), // seaMid
                  ),
                ),
                SizedBox(width: 1.w),
                const CustomIconWidget(
                  iconName: 'arrow_forward',
                  size: 16,
                  color: Color(0xFF00ACC1), // seaMid
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBodyStat(String value, String unit, String label, String iconName, bool isHighlighted) {
    return Column(
      children: [
        // Icon in light cyan bubble
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F7FA), // Light cyan
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: const Color(0xFF00838F), // Teal
              size: 22,
            ),
          ),
        ),
        SizedBox(height: 1.h),
        // Value with unit
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  fontSize: 20.sp, // Increased from 18.sp for better readability
                  fontWeight: FontWeight.bold,
                  color: isHighlighted
                      ? const Color(0xFFFFB74D) // Orange for BMI like screenshot
                      : const Color(0xFF004D40), // textDark
                ),
              ),
              if (unit.isNotEmpty)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.normal,
                    color: const Color(0xFF78909C), // textMuted
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 0.3.h),
        // Label
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp, // Increased from 11.sp for better readability
            fontWeight: FontWeight.w500,
            color: const Color(0xFF78909C), // textMuted
          ),
        ),
      ],
    );
  }
}