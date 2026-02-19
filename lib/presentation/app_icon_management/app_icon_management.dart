import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/app_export.dart';
import './widgets/icon_preview_widget.dart';
import './widgets/preview_grid_widget.dart';
import './widgets/processing_options_widget.dart';
import './widgets/upload_section_widget.dart';

class AppIconManagement extends StatefulWidget {
  const AppIconManagement({super.key});

  @override
  State<AppIconManagement> createState() => _AppIconManagementState();
}

class _AppIconManagementState extends State<AppIconManagement>
    with TickerProviderStateMixin {
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  bool _isProcessing = false;
  bool _showPreviewToggle = false;

  late AnimationController _uploadAnimationController;
  late Animation<double> _uploadAnimation;

  // Icon sizes for Android
  final Map<String, int> _androidIconSizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };

  Map<String, Uint8List?> _generatedIcons = {};

  // Processing options
  bool _removeBackground = false;
  bool _applyRoundedCorners = true;
  bool _enhanceContrast = false;
  double _cornerRadius = 0.2;

  @override
  void initState() {
    super.initState();
    _uploadAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _uploadAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _uploadAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _uploadAnimationController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Camera error: ${e.toString()}');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        await _processSelectedImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Gallery error: ${e.toString()}');
    }
  }

  Future<void> _processSelectedImage(XFile image) async {
    setState(() => _isProcessing = true);

    try {
      final bytes = await image.readAsBytes();

      // Crop image to square format
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Icon Image',
            toolbarColor: AppTheme.primaryLight,
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: AppTheme.primaryLight,
            dimmedLayerColor: Colors.black.withValues(alpha: 0.8),
            cropFrameColor: AppTheme.primaryLight,
            cropGridColor: AppTheme.primaryLight.withValues(alpha: 0.5),
          ),
          IOSUiSettings(
            title: 'Crop Icon Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            rectHeight: 300,
            rectWidth: 300,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(width: 400, height: 400),
          ),
        ],
      );

      if (croppedFile != null) {
        final croppedBytes = await croppedFile.readAsBytes();

        setState(() {
          if (kIsWeb) {
            _selectedImageBytes = croppedBytes;
            _selectedImageFile = null;
          } else {
            _selectedImageFile = File(croppedFile.path);
            _selectedImageBytes = null;
          }
        });

        await _generateIconSizes();
        _uploadAnimationController.forward();
      }
    } catch (e) {
      _showErrorSnackBar('Image processing error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _generateIconSizes() async {
    if (_selectedImageFile == null && _selectedImageBytes == null) return;

    setState(() => _isProcessing = true);

    try {
      Uint8List imageData;
      if (kIsWeb && _selectedImageBytes != null) {
        imageData = _selectedImageBytes!;
      } else if (_selectedImageFile != null) {
        imageData = await _selectedImageFile!.readAsBytes();
      } else {
        return;
      }

      final img.Image? originalImage = img.decodeImage(imageData);
      if (originalImage == null) return;

      for (final entry in _androidIconSizes.entries) {
        final size = entry.value;
        img.Image resized = img.copyResize(
          originalImage,
          width: size,
          height: size,
          interpolation: img.Interpolation.cubic,
        );

        // Apply processing options
        if (_removeBackground) {
          // Simple background removal (white/transparent areas)
          resized = _removeWhiteBackground(resized);
        }

        if (_applyRoundedCorners) {
          resized = _applyRoundCorners(resized, _cornerRadius);
        }

        if (_enhanceContrast) {
          resized = img.adjustColor(resized, contrast: 1.2);
        }

        _generatedIcons[entry.key] = Uint8List.fromList(img.encodePng(resized));
      }

      setState(() {});
    } catch (e) {
      _showErrorSnackBar('Icon generation error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  img.Image _removeWhiteBackground(img.Image image) {
    final img.Image result =
        img.Image(width: image.width, height: image.height, numChannels: 4);

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();

        // If pixel is white or near-white, make it transparent
        if (r > 240 && g > 240 && b > 240) {
          result.setPixel(x, y, img.ColorRgba8(r, g, b, 0));
        } else {
          result.setPixel(x, y, pixel);
        }
      }
    }

    return result;
  }

  img.Image _applyRoundCorners(img.Image image, double radiusPercent) {
    final radius = (image.width * radiusPercent).round();
    final img.Image result =
        img.Image(width: image.width, height: image.height, numChannels: 4);

    final centerX = image.width / 2;
    final centerY = image.height / 2;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        // Check if pixel is within rounded rectangle bounds
        bool isInBounds = true;

        // Top-left corner
        if (x < radius && y < radius) {
          final dx = radius - x;
          final dy = radius - y;
          if (dx * dx + dy * dy > radius * radius) {
            isInBounds = false;
          }
        }
        // Top-right corner
        else if (x >= image.width - radius && y < radius) {
          final dx = x - (image.width - radius - 1);
          final dy = radius - y;
          if (dx * dx + dy * dy > radius * radius) {
            isInBounds = false;
          }
        }
        // Bottom-left corner
        else if (x < radius && y >= image.height - radius) {
          final dx = radius - x;
          final dy = y - (image.height - radius - 1);
          if (dx * dx + dy * dy > radius * radius) {
            isInBounds = false;
          }
        }
        // Bottom-right corner
        else if (x >= image.width - radius && y >= image.height - radius) {
          final dx = x - (image.width - radius - 1);
          final dy = y - (image.height - radius - 1);
          if (dx * dx + dy * dy > radius * radius) {
            isInBounds = false;
          }
        }

        if (isInBounds) {
          result.setPixel(x, y, pixel);
        } else {
          result.setPixel(x, y, img.ColorRgba8(0, 0, 0, 0));
        }
      }
    }

    return result;
  }

  Future<void> _applyGeneratedIcons() async {
    if (_generatedIcons.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      // Show success message with platform-specific instructions
      _showSuccessDialog();
    } catch (e) {
      _showErrorSnackBar('Apply icons error: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _resetToDefault() {
    setState(() {
      _selectedImageFile = null;
      _selectedImageBytes = null;
      _generatedIcons.clear();
      _uploadAnimationController.reset();
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorLight,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Icons Generated Successfully!',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.successLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your custom app icons have been generated for all Android densities.',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Next Steps:',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Replace icons in android/app/src/main/res/mipmap-*/ folders\n'
              '2. Rebuild your app\n'
              '3. Install the updated APK',
              style: GoogleFonts.inter(fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'App Icon Management',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
                _showPreviewToggle ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showPreviewToggle = !_showPreviewToggle;
              });
            },
            tooltip: 'Toggle Preview',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Icon Preview Card
            if (_showPreviewToggle ||
                _selectedImageFile != null ||
                _selectedImageBytes != null)
              IconPreviewWidget(
                selectedImageFile: _selectedImageFile,
                selectedImageBytes: _selectedImageBytes,
                animation: _uploadAnimation,
              ),

            const SizedBox(height: 24),

            // Upload Section
            UploadSectionWidget(
              onCameraPressed: _pickImageFromCamera,
              onGalleryPressed: _pickImageFromGallery,
              isProcessing: _isProcessing,
            ),

            const SizedBox(height: 24),

            // Processing Options
            if (_selectedImageFile != null || _selectedImageBytes != null)
              ProcessingOptionsWidget(
                removeBackground: _removeBackground,
                applyRoundedCorners: _applyRoundedCorners,
                enhanceContrast: _enhanceContrast,
                cornerRadius: _cornerRadius,
                onRemoveBackgroundChanged: (value) {
                  setState(() => _removeBackground = value);
                  if (_selectedImageFile != null ||
                      _selectedImageBytes != null) {
                    _generateIconSizes();
                  }
                },
                onRoundedCornersChanged: (value) {
                  setState(() => _applyRoundedCorners = value);
                  if (_selectedImageFile != null ||
                      _selectedImageBytes != null) {
                    _generateIconSizes();
                  }
                },
                onEnhanceContrastChanged: (value) {
                  setState(() => _enhanceContrast = value);
                  if (_selectedImageFile != null ||
                      _selectedImageBytes != null) {
                    _generateIconSizes();
                  }
                },
                onCornerRadiusChanged: (value) {
                  setState(() => _cornerRadius = value);
                  if (_selectedImageFile != null ||
                      _selectedImageBytes != null) {
                    _generateIconSizes();
                  }
                },
              ),

            // Preview Grid
            if (_generatedIcons.isNotEmpty)
              PreviewGridWidget(
                generatedIcons: _generatedIcons,
                androidIconSizes: _androidIconSizes,
              ),

            const SizedBox(height: 32),

            // Action Buttons
            if (_generatedIcons.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isProcessing ? null : _resetToDefault,
                      icon: Icon(Icons.refresh),
                      label: Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _applyGeneratedIcons,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(Icons.check),
                      label:
                          Text(_isProcessing ? 'Generating...' : 'Apply Icons'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}