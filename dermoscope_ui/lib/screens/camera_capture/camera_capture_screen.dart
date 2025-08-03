import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_routes.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/capture_controls_widget.dart';
import './widgets/capture_type_selector_widget.dart';
import './widgets/quality_indicator_widget.dart';

class CameraCapture extends StatefulWidget {
  const CameraCapture({Key? key}) : super(key: key);

  @override
  State<CameraCapture> createState() => _CameraCaptureState();
}

class _CameraCaptureState extends State<CameraCapture> {
  String selectedCaptureType = 'skin';
  bool isFlashOn = false;
  bool isCameraReady = false;
  String qualityStatus = 'checking';
  String guidanceMessage = 'Position your skin in the circle';
  Color borderColor = Colors.yellow;
  bool isCapturing = false;
  int selectedCameraIndex = 0;

  late CameraController _cameraController;
  late List<CameraDescription> _cameras;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeCamera();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _disposeCamera() async {
    if (_isCameraInitialized) {
      try {
        await _cameraController.dispose();
      } catch (e) {
        debugPrint('Error disposing camera: $e');
      }
      _isCameraInitialized = false;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras found');
      }

      _cameraController = CameraController(
        _cameras[selectedCameraIndex],
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      // Initialize the controller
      await _cameraController.initialize();
      
      if (_isDisposed) {
        await _disposeCamera();
        return;
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          isCameraReady = true;
          qualityStatus = 'good';
          guidanceMessage = 'Perfect! Ready to capture';
          borderColor = Colors.green;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          isCameraReady = false;
          qualityStatus = 'error';
          guidanceMessage = 'Camera error: ${e.toString()}';
          borderColor = Colors.red;
        });
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      isCameraReady = false;
      _isCameraInitialized = false;
    });

    try {
      await _disposeCamera();
      
      selectedCameraIndex = (selectedCameraIndex + 1) % _cameras.length;
      
      _cameraController = CameraController(
        _cameras[selectedCameraIndex],
        ResolutionPreset.veryHigh,
        enableAudio: false,
      );

      await _cameraController.initialize();

      if (_isDisposed) {
        await _disposeCamera();
        return;
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          isCameraReady = true;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
      if (mounted) {
        setState(() {
          isCameraReady = false;
          qualityStatus = 'error';
          guidanceMessage = 'Error switching camera';
          borderColor = Colors.red;
        });
      }
    }
  }

  void _toggleFlash() async {
    setState(() => isFlashOn = !isFlashOn);
    await _cameraController.setFlashMode(
      isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    HapticFeedback.lightImpact();
  }

  void _onCaptureTypeChanged(String type) {
    setState(() {
      selectedCaptureType = type;
      switch (type) {
        case 'skin':
          guidanceMessage = 'Position your skin in the circle';
          break;
        case 'hair':
          guidanceMessage = 'Frame your hair in the rectangle';
          break;
        case 'scalp':
          guidanceMessage = 'Focus on your scalp area';
          break;
      }
    });
  }

  Future<void> _captureImage() async {
    if (!isCameraReady || isCapturing || !_isCameraInitialized) return;

    setState(() => isCapturing = true);
    HapticFeedback.mediumImpact();

    try {
      final XFile image = await _cameraController.takePicture();
      
      if (_isDisposed) return;

      if (mounted) {
        print("Captured image path: ${image.path}");
        Navigator.pushNamed(
          context,
          AppRoutes.analysisResults,
          arguments: {
            'imagePath': image.path,
            'captureType': selectedCaptureType,
          },
        );
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to capture image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isCapturing = false);
      }
    }
  }

  Future<void> _openGallery() async {
    HapticFeedback.lightImpact();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print("Gallery image path: ${image.path}");
      Navigator.pushNamed(
        context,
        AppRoutes.analysisResults,
        arguments: {
          'imagePath': image.path,
          'captureType': selectedCaptureType,
        },
      );
    }
  }

  void _closeCamera() => Navigator.pop(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: isCameraReady
                  ? CameraPreviewWidget(
                      controller: _cameraController,
                      captureType: selectedCaptureType,
                      borderColor: borderColor,
                      onTapToFocus: (_) => HapticFeedback.lightImpact(),
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Positioned(
              top: 2.h,
              left: 4.w,
              right: 4.w,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _iconButton('close', _closeCamera),
                  Row(
                    children: [
                      _iconButton(
                        isFlashOn ? 'flash_on' : 'flash_off',
                        _toggleFlash,
                        isFlashOn,
                      ),
                      SizedBox(width: 2.w),
                      _iconButton('flip_camera', _switchCamera),
                    ],
                  ),
                ],
              ),
            ),

            Positioned(
              top: 18.h,
              left: 4.w,
              right: 4.w,
              child: QualityIndicatorWidget(
                status: qualityStatus,
                message: guidanceMessage,
              ),
            ),
            Positioned(
              bottom: 4.h,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CaptureTypeSelectorWidget(
                    selectedType: selectedCaptureType,
                    onTypeChanged: _onCaptureTypeChanged,
                  ),
                  SizedBox(height: 3.h),
                  CaptureControlsWidget(
                    isReady: isCameraReady && qualityStatus == 'good',
                    isCapturing: isCapturing,
                    onCapture: _captureImage,
                    onGalleryTap: _openGallery,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconButton(String icon, VoidCallback onTap, [bool active = false]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.lightTheme.colorScheme.primary.withAlpha(200)
              : Colors.black.withAlpha(100),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(iconName: icon, color: Colors.white, size: 6.w),
      ),
    );
  }
}
