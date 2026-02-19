import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/accessibility_provider.dart';
import '../../widgets/custom_icon_widget.dart';

class AccessibilitySettings extends StatefulWidget {
  const AccessibilitySettings({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettings> createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings>
    with TickerProviderStateMixin {
  final AccessibilityProvider _accessibilityProvider =
      AccessibilityProvider.instance;

  bool _isLoading = false;
  String? _error;
  late AnimationController _resetAnimationController;
  late Animation<double> _resetScaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadAccessibilitySettings();
  }

  @override
  void dispose() {
    _resetAnimationController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _resetAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _resetScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _resetAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadAccessibilitySettings() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _accessibilityProvider.initialize();

      if (!mounted) return;
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

  Future<void> _updateHighContrast(bool value) async {
    try {
      await _accessibilityProvider.updateHighContrast(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Alto contrasto attivato'
                : 'Alto contrasto disattivato'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Errore: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateLargeText(bool value) async {
    try {
      await _accessibilityProvider.updateLargeText(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Testo ingrandito attivato'
                : 'Testo ingrandito disattivato'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Errore: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateReducedAnimation(bool value) async {
    try {
      await _accessibilityProvider.updateReducedAnimation(value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(value
                ? 'Animazioni ridotte attivate'
                : 'Animazioni normali ripristinate'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Errore: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _updateTextScale(double value) async {
    try {
      await _accessibilityProvider.updateTextScaleFactor(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Errore: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _resetAllSettings() async {
    try {
      await _resetAnimationController.forward();
      await _accessibilityProvider.resetAccessibilitySettings();
      await _resetAnimationController.reverse();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Impostazioni di accessibilità ripristinate'),
            backgroundColor: Theme.of(context).primaryColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      await _resetAnimationController.reverse();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Errore nel ripristino: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Theme.of(context);

    return Scaffold(
      backgroundColor: currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Accessibilità'),
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
            onPressed: _showAccessibilityInfo,
            icon: CustomIconWidget(
              iconName: 'info',
              color: currentTheme.primaryColor,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _accessibilityProvider,
        builder: (context, child) {
          return _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorWidget(currentTheme)
                  : _buildContent(currentTheme);
        },
      ),
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
            'Errore nel caricamento delle impostazioni di accessibilità',
            style: currentTheme.textTheme.titleLarge,
            textAlign: TextAlign.center,
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
            onPressed: _loadAccessibilitySettings,
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData currentTheme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(currentTheme),
          SizedBox(height: 3.h),
          _buildAccessibilityOptionsSection(currentTheme),
          SizedBox(height: 3.h),
          _buildTextScaleSection(currentTheme),
          SizedBox(height: 3.h),
          _buildPreviewSection(currentTheme),
          SizedBox(height: 3.h),
          _buildResetSection(currentTheme),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData currentTheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            currentTheme.primaryColor.withAlpha(26),
            currentTheme.primaryColor.withAlpha(13),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                size: 7.w,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Impostazioni di Accessibilità',
                  style: currentTheme.textTheme.titleLarge?.copyWith(
                    color: currentTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Personalizza l\'esperienza dell\'app per migliorare l\'accessibilità e l\'usabilità in base alle tue esigenze specifiche.',
            style: currentTheme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityOptionsSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Opzioni di Accessibilità',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildAccessibilityToggle(
                'Alto contrasto',
                'Migliora la visibilità per pazienti con cambiamenti della vista',
                'contrast',
                _accessibilityProvider.highContrastEnabled,
                _updateHighContrast,
                currentTheme,
              ),
              _buildDivider(currentTheme),
              _buildAccessibilityToggle(
                'Testo ingrandito',
                'Aumenta la dimensione del testo per una lettura più facile',
                'text_fields',
                _accessibilityProvider.largeTextEnabled,
                _updateLargeText,
                currentTheme,
              ),
              _buildDivider(currentTheme),
              _buildAccessibilityToggle(
                'Ridotta animazione',
                'Minimizza i movimenti per pazienti sensibili al movimento',
                'slow_motion_video',
                _accessibilityProvider.reducedAnimationEnabled,
                _updateReducedAnimation,
                currentTheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccessibilityToggle(
    String title,
    String subtitle,
    String iconName,
    bool value,
    Future<void> Function(bool) onChanged,
    ThemeData currentTheme,
  ) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: value
                  ? currentTheme.primaryColor.withAlpha(26)
                  : currentTheme.colorScheme.surfaceContainerHighest.withAlpha(128),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value
                    ? currentTheme.primaryColor
                    : currentTheme.colorScheme.outline,
                width: value ? 2 : 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: value
                  ? currentTheme.primaryColor
                  : currentTheme.colorScheme.onSurfaceVariant,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: currentTheme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: value ? currentTheme.primaryColor : null,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  subtitle,
                  style: currentTheme.textTheme.bodySmall?.copyWith(
                    color: currentTheme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: currentTheme.primaryColor,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _buildTextScaleSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dimensione del Testo',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor.withAlpha(26),
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
                    iconName: 'format_size',
                    color: currentTheme.primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Fattore di Scala: ${(_accessibilityProvider.textScaleFactor * 100).round()}%',
                    style: currentTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Text(
                    'Aa',
                    style: currentTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _accessibilityProvider.textScaleFactor,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      activeColor: currentTheme.primaryColor,
                      onChanged: _updateTextScale,
                      label:
                          '${(_accessibilityProvider.textScaleFactor * 100).round()}%',
                    ),
                  ),
                  Text(
                    'Aa',
                    style: currentTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Regola la dimensione del testo per migliorare la leggibilità. Il valore ottimale dipende dalle tue esigenze visive.',
                style: currentTheme.textTheme.bodySmall?.copyWith(
                  color: currentTheme.colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Anteprima',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _accessibilityProvider.highContrastEnabled
                  ? currentTheme.primaryColor
                  : currentTheme.colorScheme.outline.withAlpha(51),
              width: _accessibilityProvider.highContrastEnabled ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor.withAlpha(26),
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
                    iconName: 'preview',
                    color: currentTheme.primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Esempio di Testo',
                    style: currentTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                'Questo è un esempio di come apparirà il testo con le impostazioni di accessibilità attuali. '
                'Puoi vedere come cambiano le dimensioni e il contrasto.',
                style: currentTheme.textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: currentTheme.primaryColor,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Impostazioni applicate correttamente',
                      style: currentTheme.textTheme.bodySmall?.copyWith(
                        color: currentTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResetSection(ThemeData currentTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ripristino Impostazioni',
          style: currentTheme.textTheme.titleMedium?.copyWith(
            color: currentTheme.primaryColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: currentTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: currentTheme.shadowColor.withAlpha(26),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'restore',
                    color: currentTheme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ripristina Impostazioni Predefinite',
                          style: currentTheme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Ripristina tutte le impostazioni di accessibilità ai valori predefiniti',
                          style: currentTheme.textTheme.bodySmall?.copyWith(
                            color: currentTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              AnimatedBuilder(
                animation: _resetScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _resetScaleAnimation.value,
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            _accessibilityProvider.hasAccessibilityEnabled
                                ? _resetAllSettings
                                : null,
                        icon: Icon(
                          Icons.restore,
                          size: 5.w,
                        ),
                        label: const Text('Ripristina Tutto'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          side: BorderSide(
                            color:
                                _accessibilityProvider.hasAccessibilityEnabled
                                    ? currentTheme.colorScheme.outline
                                    : currentTheme.colorScheme.outline
                                        .withAlpha(77),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (!_accessibilityProvider.hasAccessibilityEnabled) ...[
                SizedBox(height: 1.h),
                Text(
                  'Nessuna modifica da ripristinare',
                  style: currentTheme.textTheme.bodySmall?.copyWith(
                    color: currentTheme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData currentTheme) {
    return Divider(
      height: 0,
      thickness: 1,
      color: currentTheme.colorScheme.outline.withAlpha(51),
    );
  }

  void _showAccessibilityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.accessibility_new,
              color: Theme.of(context).primaryColor,
              size: 6.w,
            ),
            SizedBox(width: 2.w),
            const Text('Informazioni Accessibilità'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoItem(
              'Alto Contrasto',
              'Aumenta il contrasto tra il testo e lo sfondo per migliorare la leggibilità per persone con difficoltà visive.',
            ),
            SizedBox(height: 2.h),
            _buildInfoItem(
              'Testo Ingrandito',
              'Aumenta automaticamente la dimensione di tutto il testo nell\'app per facilitarne la lettura.',
            ),
            SizedBox(height: 2.h),
            _buildInfoItem(
              'Animazioni Ridotte',
              'Riduce o elimina le animazioni nell\'interfaccia per persone sensibili ai movimenti.',
            ),
            SizedBox(height: 2.h),
            _buildInfoItem(
              'Scala Testo',
              'Permette di regolare con precisione la dimensione del testo secondo le proprie necessità.',
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

  Widget _buildInfoItem(String title, String description) {
    final currentTheme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: currentTheme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: currentTheme.primaryColor,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          description,
          style: currentTheme.textTheme.bodySmall?.copyWith(
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
