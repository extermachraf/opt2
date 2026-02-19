import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CameraPreviewWidget extends StatefulWidget {
  final XFile? capturedImage;
  final Function(XFile?) onImageCaptured;

  const CameraPreviewWidget({
    Key? key,
    this.capturedImage,
    required this.onImageCaptured,
  }) : super(key: key);

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isInitializing = false;
  bool _showCamera = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Don't initialize camera automatically
    // User must press button to open camera
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;
    return (await Permission.camera.request()).isGranted;
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;

    setState(() {
      _isInitializing = true;
    });

    try {
      if (!await _requestCameraPermission()) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _isInitializing = false;
        });
        return;
      }

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
          camera, kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high);

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isInitializing = false;
          _showCamera = true;
        });
      }
    } catch (e) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
    } catch (e) {}

    if (!kIsWeb) {
      try {
        await _cameraController!.setFlashMode(FlashMode.auto);
      } catch (e) {}
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      widget.onImageCaptured(photo);

      // Hide camera after capture
      setState(() {
        _showCamera = false;
        _isCameraInitialized = false;
      });

      // Dispose camera to free resources
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null) {
        widget.onImageCaptured(image);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _openCamera() async {
    await _initializeCamera();
  }

  // CRITICAL FIX: Public method to allow external triggering of camera opening
  void openCameraExternally() {
    _openCamera();
  }

  void _retakePhoto() {
    widget.onImageCaptured(null);
    setState(() {
      _showCamera = false;
      _isCameraInitialized = false;
    });
    // Dispose camera controller
    _cameraController?.dispose();
    _cameraController = null;
  }

  void _closeCamera() {
    setState(() {
      _showCamera = false;
      _isCameraInitialized = false;
    });
    // Dispose camera controller
    _cameraController?.dispose();
    _cameraController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.capturedImage != null
            ? _buildCapturedImageView()
            : _showCamera
                ? _buildCameraView()
                : _buildCameraButtonView(),
      ),
    );
  }

  Widget _buildCapturedImageView() {
    return Stack(
      fit: StackFit.expand,
      children: [
        kIsWeb
            ? CustomImageWidget(
                imageUrl: widget.capturedImage!.path,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(widget.capturedImage!.path),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
        Positioned(
          top: 2.h,
          right: 2.w,
          child: Row(
            children: [
              _buildActionButton(
                icon: 'refresh',
                onTap: _retakePhoto,
                backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              ),
              SizedBox(width: 2.w),
              _buildActionButton(
                icon: 'photo_library',
                onTap: _selectFromGallery,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 2.h,
          left: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.green,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Foto catturata! Verrà salvata con il pasto.',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraButtonView() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
              ),
              child: CustomIconWidget(
                iconName: 'camera_alt',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 48,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Aggiungi una foto del pasto',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Cattura o seleziona un\'immagine per il tuo pasto',
              textAlign: TextAlign.center,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPrimaryActionButton(
                  icon: 'camera_alt',
                  label: 'Apri fotocamera',
                  onTap: _openCamera,
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                ),
                _buildPrimaryActionButton(
                  icon: 'photo_library',
                  label: 'Seleziona da galleria',
                  onTap: _selectFromGallery,
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    if (_isInitializing) {
      return _buildLoadingView();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return _buildNoCameraView();
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview fills entire space
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize!.height,
              height: _cameraController!.value.previewSize!.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),
        // Close camera button
        Positioned(
          top: 2.h,
          left: 2.w,
          child: _buildActionButton(
            icon: 'close',
            onTap: _closeCamera,
            backgroundColor: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        Positioned(
          bottom: 2.h,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: 'photo_library',
                onTap: _selectFromGallery,
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              ),
              _buildCaptureButton(),
              if (!kIsWeb)
                _buildActionButton(
                  icon: 'flip_camera_ios',
                  onTap: _switchCamera,
                  backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(height: 2.h),
            Text(
              'Inizializzazione fotocamera...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCameraView() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'camera_alt',
              color: AppTheme.lightTheme.colorScheme.outline,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Fotocamera non disponibile',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 1.h),
            ElevatedButton.icon(
              onPressed: _selectFromGallery,
              icon: CustomIconWidget(
                iconName: 'photo_library',
                color: Colors.white,
                size: 18,
              ),
              label: Text('Seleziona da galleria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _capturePhoto,
      child: Container(
        width: 18.w,
        height: 18.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 3,
          ),
        ),
        child: Center(
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String icon,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor.withValues(alpha: 0.9),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryActionButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required Color backgroundColor,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: CustomIconWidget(
        iconName: icon,
        color: Colors.white,
        size: 20,
      ),
      label: Text(
        label,
        style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    try {
      final currentLensDirection = _cameraController!.description.lensDirection;
      final newCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection != currentLensDirection,
        orElse: () => _cameras.first,
      );

      await _cameraController!.dispose();
      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
