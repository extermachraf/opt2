import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/user_settings_service.dart';

class DataSyncFrequencySettings extends StatefulWidget {
  const DataSyncFrequencySettings({Key? key}) : super(key: key);

  @override
  State<DataSyncFrequencySettings> createState() => _DataSyncFrequencySettingsState();
}

class _DataSyncFrequencySettingsState extends State<DataSyncFrequencySettings> {
  final UserSettingsService _userSettingsService = UserSettingsService.instance;

  String _selectedFrequency = 'realtime';
  bool _backgroundSyncEnabled = true;
  bool _wifiOnlyEnabled = false;
  bool _cellularBackupEnabled = true;
  bool _isLoading = true;
  String? _error;
  DateTime? _lastSyncTime;

  final List<Map<String, dynamic>> _syncOptions = [
{ 'value': 'realtime',
'title': 'Tempo reale',
'subtitle': 'Sincronizzazione istantanea per dati critici',
'description': 'I dati vengono sincronizzati immediatamente. Raccomandato per monitoraggio medico.',
'dataUsage': 'Alto',
'batteryImpact': 'Medio',
'icon': 'flash_on',
},
{ 'value': 'every_15_minutes',
'title': 'Ogni 15 minuti',
'subtitle': 'Approccio bilanciato tra velocità e risparmio',
'description': 'Sincronizzazione frequente con buon equilibrio tra prestazioni e batteria.',
'dataUsage': 'Medio',
'batteryImpact': 'Basso',
'icon': 'schedule',
},
{ 'value': 'hourly',
'title': 'Ogni ora',
'subtitle': 'Conservazione della batteria',
'description': 'Sincronizzazione oraria per massimizzare la durata della batteria.',
'dataUsage': 'Basso',
'batteryImpact': 'Molto basso',
'icon': 'battery_saver',
},
{ 'value': 'manual_only',
'title': 'Solo manuale',
'subtitle': 'Controllo completo del paziente',
'description': 'La sincronizzazione avviene solo quando richiesta manualmente.',
'dataUsage': 'Minimo',
'batteryImpact': 'Nessuno',
'icon': 'touch_app',
},
];

  final List<String> _criticalDataTypes = [
    'Avvisi farmaci urgenti',
    'Contatti di emergenza',
    'Segnalazioni sintomi gravi',
    'Alert medici critici',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _updateLastSyncTime();
  }

  Future<void> _loadSettings() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final settings = await _userSettingsService.getUserSettings();
      
      if (mounted && settings != null) {
        setState(() {
          _selectedFrequency = settings['sync_frequency'] ?? 'realtime';
          _backgroundSyncEnabled = settings['background_sync_enabled'] ?? true;
          _wifiOnlyEnabled = settings['wifi_only_sync'] ?? false;
          _cellularBackupEnabled = settings['cellular_backup_enabled'] ?? true;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  void _updateLastSyncTime() {
    setState(() {
      _lastSyncTime = DateTime.now();
    });
  }

  Future<void> _saveSettings() async {
    try {
      await _userSettingsService.updateUserSettings({
        'sync_frequency': _selectedFrequency,
        'background_sync_enabled': _backgroundSyncEnabled,
        'wifi_only_sync': _wifiOnlyEnabled,
        'cellular_backup_enabled': _cellularBackupEnabled,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impostazioni sincronizzazione aggiornate'),
            backgroundColor: AppTheme.lightTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nel salvataggio: ${error.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _performManualSync() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate sync process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _updateLastSyncTime();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sincronizzazione completata con successo'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget()
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildSyncStatusCard(),
                      SizedBox(height: 2.h),
                      _buildFrequencyOptions(),
                      SizedBox(height: 2.h),
                      _buildCriticalDataSection(),
                      SizedBox(height: 2.h),
                      _buildAdvancedSettings(),
                      SizedBox(height: 2.h),
                      _buildSyncHistory(),
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Frequenza Sincronizzazione Dati'),
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.lightTheme.primaryColor,
          size: 6.w,
        ),
      ),
      actions: [
        if (_lastSyncTime != null)
          Container(
            margin: EdgeInsets.only(right: 4.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'sync',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 4.w,
                ),
                Text(
                  'Aggiornato',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.lightTheme.colorScheme.error,
          ),
          SizedBox(height: 2.h),
          Text(
            'Errore nel caricamento delle impostazioni',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              _error ?? 'Errore sconosciuto',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _loadSettings,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatusCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'cloud_done',
              color: Colors.white,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stato Sincronizzazione',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _lastSyncTime != null
                      ? 'Ultimo aggiornamento: ${_formatSyncTime(_lastSyncTime!)}'
                      : 'Mai sincronizzato',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor.withAlpha(179),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _performManualSync,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 4.w,
            ),
            label: const Text('Sincronizza'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyOptions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              'Frequenza di sincronizzazione',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ..._syncOptions.map((option) => _buildSyncOptionTile(option)).toList(),
        ],
      ),
    );
  }

  Widget _buildSyncOptionTile(Map<String, dynamic> option) {
    final isSelected = _selectedFrequency == option['value'];
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedFrequency = option['value'];
        });
        _saveSettings();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.lightTheme.primaryColor.withAlpha(26)
              : Colors.transparent,
          border: isSelected 
              ? Border.all(color: AppTheme.lightTheme.primaryColor, width: 2)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppTheme.lightTheme.primaryColor
                    : AppTheme.lightTheme.primaryColor.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: option['icon'],
                color: isSelected 
                    ? Colors.white
                    : AppTheme.lightTheme.primaryColor,
                size: 5.w,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option['title'],
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.lightTheme.primaryColor : null,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    option['subtitle'],
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    option['description'],
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant.withAlpha(179),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildInfoChip('Dati: ${option['dataUsage']}', Icons.data_usage),
                      SizedBox(width: 2.w),
                      _buildInfoChip('Batteria: ${option['batteryImpact']}', Icons.battery_alert),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.primaryColor,
                size: 6.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withAlpha(51),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 3.w, color: AppTheme.lightTheme.primaryColor),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppTheme.lightTheme.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriticalDataSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'priority_high',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Dati critici',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'I seguenti dati vengono sempre sincronizzati immediatamente, indipendentemente dalle impostazioni:',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          ..._criticalDataTypes.map((dataType) => Padding(
            padding: EdgeInsets.symmetric(vertical: 0.5.h),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'fiber_manual_record',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 2.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  dataType,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildAdvancedSettings() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Impostazioni avanzate',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          SwitchListTile(
            title: const Text('Sincronizzazione in background'),
            subtitle: const Text('Mantieni i dati aggiornati anche quando l\'app è chiusa'),
            value: _backgroundSyncEnabled,
            onChanged: (value) {
              setState(() {
                _backgroundSyncEnabled = value;
              });
              _saveSettings();
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('Solo Wi-Fi'),
            subtitle: const Text('Sincronizza solo quando connesso al Wi-Fi'),
            value: _wifiOnlyEnabled,
            onChanged: (value) {
              setState(() {
                _wifiOnlyEnabled = value;
              });
              _saveSettings();
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
          SwitchListTile(
            title: const Text('Backup cellulare per emergenze'),
            subtitle: const Text('Usa la connessione mobile per dati critici'),
            value: _cellularBackupEnabled,
            onChanged: (value) {
              setState(() {
                _cellularBackupEnabled = value;
              });
              _saveSettings();
            },
            activeColor: AppTheme.lightTheme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHistory() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cronologia sincronizzazione',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSyncHistoryItem(
            'Sincronizzazione completata',
            DateTime.now().subtract(const Duration(minutes: 5)),
            true,
          ),
          _buildSyncHistoryItem(
            'Sincronizzazione completata',
            DateTime.now().subtract(const Duration(hours: 1)),
            true,
          ),
          _buildSyncHistoryItem(
            'Sincronizzazione fallita - Riprovare',
            DateTime.now().subtract(const Duration(hours: 2)),
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildSyncHistoryItem(String title, DateTime time, bool success) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: success 
                  ? AppTheme.lightTheme.primaryColor.withAlpha(26)
                  : AppTheme.lightTheme.colorScheme.error.withAlpha(26),
              borderRadius: BorderRadius.circular(6),
            ),
            child: CustomIconWidget(
              iconName: success ? 'check' : 'error',
              color: success 
                  ? AppTheme.lightTheme.primaryColor
                  : AppTheme.lightTheme.colorScheme.error,
              size: 4.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatSyncTime(time),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!success)
            TextButton(
              onPressed: _performManualSync,
              child: Text(
                'Riprova',
                style: TextStyle(
                  color: AppTheme.lightTheme.primaryColor,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Ora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minuti fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ore fa';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}