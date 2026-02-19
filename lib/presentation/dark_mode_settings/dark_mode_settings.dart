import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_settings_service.dart';
import './widgets/theme_preview_widget.dart';

class DarkModeSettings extends StatefulWidget {
  const DarkModeSettings({Key? key}) : super(key: key);

  @override
  State<DarkModeSettings> createState() => _DarkModeSettingsState();
}

class _DarkModeSettingsState extends State<DarkModeSettings> {
  final AuthService _authService = AuthService.instance;
  final UserSettingsService _userSettingsService = UserSettingsService.instance;
  final ThemeProvider _themeProvider = ThemeProvider.instance;

  bool _isLoading = true;
  String _currentThemeMode = 'light';
  String? _error;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _themeOptions = [
    {
      'value': 'light',
      'title': 'Modalità Chiara',
      'subtitle': 'Sfondo chiaro ottimizzato per uso medico',
      'icon': 'light_mode',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentThemeMode = _themeProvider.themeModeString;
    _loadThemeSettings();
  }

  Future<void> _loadThemeSettings() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get current theme from provider
      _currentThemeMode = _themeProvider.themeModeString;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateThemeMode(String themeMode) async {
    if (_isSaving || themeMode == _currentThemeMode) return;

    try {
      setState(() {
        _isSaving = true;
      });

      // Check if trying to set dark mode
      if (themeMode == 'dark' || themeMode == 'system') {
        _showComingSoonDialog();
        setState(() {
          _isSaving = false;
        });
        return;
      }

      // Update theme through provider
      await _themeProvider.updateThemeMode(themeMode);

      if (!mounted) return;

      setState(() {
        _currentThemeMode = themeMode;
        _isSaving = false;
      });

      final themeName = _themeOptions
          .firstWhere((option) => option['value'] == themeMode)['title'];

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tema cambiato a: $themeName'),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Errore nel cambiamento tema: ${error.toString().replaceFirst('Exception: ', '')}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _showComingSoonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).primaryColor,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            const Text('In arrivo presto!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'La modalità scura sarà disponibile presto!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Stiamo lavorando per offrirti la migliore esperienza possibile con:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 1.h),
            _buildFeatureItem('• Design ottimizzato per uso medico'),
            _buildFeatureItem('• Riduzione affaticamento degli occhi'),
            _buildFeatureItem('• Risparmio energetico per dispositivi OLED'),
            _buildFeatureItem('• Accessibilità migliorata'),
            SizedBox(height: 2.h),
            Text(
              'Nel frattempo, continua a utilizzare la modalità chiara progettata appositamente per l\'ambiente sanitario.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
            ),
            child: const Text('Ho capito'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h, left: 2.w),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);
    final isDark = _themeProvider.isDarkMode(context);

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Modalità Scura'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: currentTheme.primaryColor,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showPreviewToggle,
            icon: CustomIconWidget(
              iconName: 'preview',
              color: currentTheme.primaryColor,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorWidget(currentTheme)
              : _buildContent(currentTheme, isDark),
    );
  }

  Widget _buildErrorWidget(ThemeData currentTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: currentTheme.colorScheme.error,
          ),
          SizedBox(height: 2.h),
          Text(
            'Errore nel caricamento delle impostazioni del tema',
            style: currentTheme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              _error ?? 'Errore sconosciuto',
              style: currentTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: _loadThemeSettings,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData currentTheme, bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentThemeSection(currentTheme),
          SizedBox(height: 3.h),
          _buildComingSoonSection(currentTheme),
          SizedBox(height: 3.h),
          _buildAccessibilitySection(currentTheme),
          SizedBox(height: 3.h),
          _buildBatteryOptimizationInfo(currentTheme),
        ],
      ),
    );
  }

  Widget _buildCurrentThemeSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tema Attuale',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          margin: EdgeInsets.only(bottom: 2.h),
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentTheme.primaryColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor.withAlpha(13),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            leading: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: currentTheme.primaryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'light_mode',
                color: currentTheme.primaryColor,
                size: 5.w,
              ),
            ),
            title: Text(
              'Modalità Chiara',
              style: currentTheme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: currentTheme.primaryColor,
              ),
            ),
            subtitle: Text(
              'Tema chiaro ottimizzato per l\'uso medico professionale',
              style: currentTheme.textTheme.bodySmall?.copyWith(
                color: currentTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.check_circle,
              color: currentTheme.primaryColor,
              size: 6.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComingSoonSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Modalità Scura - In Arrivo',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: currentTheme.primaryColor.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentTheme.primaryColor.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: currentTheme.primaryColor,
                    size: 6.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Prossimamente disponibile',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'La modalità scura sarà presto disponibile con funzionalità avanzate progettate specificamente per l\'ambiente sanitario:',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  color: currentTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              _buildFeatureRow(
                'Design medicale ottimizzato',
                'Interface progettate per ridurre l\'affaticamento durante lunghe sessioni',
                'medical_services',
                currentTheme,
              ),
              _buildFeatureRow(
                'Risparmio batteria',
                'Estende la durata della batteria su dispositivi OLED',
                'battery_saver',
                currentTheme,
              ),
              _buildFeatureRow(
                'Accessibilità migliorata',
                'Contrasto ottimizzato per pazienti con problemi visivi',
                'accessibility',
                currentTheme,
              ),
              SizedBox(height: 2.h),
              ElevatedButton.icon(
                onPressed: _showComingSoonDialog,
                icon: Icon(Icons.info_outline, size: 5.w),
                label: const Text('Maggiori informazioni'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: currentTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(
      String title, String subtitle, String iconName, ThemeData currentTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: currentTheme.primaryColor,
            size: 4.w,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: currentTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: currentTheme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: currentTheme.textTheme.bodySmall?.copyWith(
                    color: currentTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilitySection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Accessibilità',
              style: currentTheme.textTheme.titleMedium?.copyWith(
                color: currentTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.accessibilitySettings),
              child: Text(
                'Gestisci',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  color: currentTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: currentTheme.primaryColor.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: currentTheme.primaryColor.withAlpha(51),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'accessibility',
                    color: currentTheme.primaryColor,
                    size: 6.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Impostazioni di Accessibilità',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      color: currentTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Personalizza l\'esperienza dell\'app per migliorare l\'accessibilità:',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  color: currentTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              _buildFeatureRow(
                'Alto contrasto',
                'Migliora la visibilità per pazienti con cambiamenti della vista',
                'contrast',
                currentTheme,
              ),
              _buildFeatureRow(
                'Testo ingrandito',
                'Aumenta la dimensione del testo per una lettura più facile',
                'text_fields',
                currentTheme,
              ),
              _buildFeatureRow(
                'Ridotta animazione',
                'Minimizza i movimenti per pazienti sensibili al movimento',
                'slow_motion_video',
                currentTheme,
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(
                      context, AppRoutes.accessibilitySettings),
                  icon: Icon(Icons.settings_accessibility, size: 5.w),
                  label: const Text('Configura Accessibilità'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryOptimizationInfo(ThemeData currentTheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: currentTheme.primaryColor.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'battery_saver',
                color: currentTheme.primaryColor,
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Ottimizzazione Futura',
                style: currentTheme.textTheme.titleMedium?.copyWith(
                  color: currentTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Quando la modalità scura sarà disponibile, potrà estendere la durata della batteria su dispositivi con schermo OLED, '
            'particolarmente utile durante lunghi periodi di trattamento quando l\'uso prolungato del dispositivo è necessario.',
            style: currentTheme.textTheme.bodyMedium?.copyWith(
              color: currentTheme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showPreviewToggle() {
    final currentTheme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anteprima Tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Anteprima del tema corrente:'),
            SizedBox(height: 2.h),
            ThemePreviewWidget(themeMode: _currentThemeMode),
            SizedBox(height: 2.h),
            Text(
              'La modalità scura sarà disponibile presto con design ottimizzato per l\'uso medico.',
              style: currentTheme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Chiudi'),
          ),
        ],
      ),
    );
  }
}
