import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final String captureType;
  final Color borderColor;
  final Function(TapDownDetails) onTapToFocus;

  const CameraPreviewWidget({
    Key? key,
    required this.controller,
    required this.captureType,
    required this.borderColor,
    required this.onTapToFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onTapToFocus,
      child: Stack(
        children: [
          // ✅ Gerçek kamera preview
          Positioned.fill(child: CameraPreview(controller)),

          // 🟢 Overlay rehber
          Center(child: _buildOverlayGuide()),

          // 🔳 Izgara çizgileri
          CustomPaint(size: Size.infinite, painter: GridPainter()),
        ],
      ),
    );
  }

  Widget _buildOverlayGuide() {
    switch (captureType) {
      case 'skin':
        return buildDoubleBorderCircle(60.w, 50.w);
      case 'scalp':
        return buildDoubleBorderCircle(65.w, 55.w);
      case 'hair':
        return buildDoubleBorderRectangle(70.w, 50.w, 60.w, 40.w);
      default:
        return const SizedBox.shrink();
    }
  }

  /// 🔵 Daire şeklinde iç içe kenarlık çizen widget
  Widget buildDoubleBorderCircle(double outerSize, double innerSize) {
    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Center(
        child: Container(
          width: innerSize,
          height: innerSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }

  /// 🟦 Dikdörtgen şeklinde iç içe kenarlık çizen widget
  Widget buildDoubleBorderRectangle(
    double outerWidth,
    double outerHeight,
    double innerWidth,
    double innerHeight,
  ) {
    return Container(
      width: outerWidth,
      height: outerHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: Center(
        child: Container(
          width: innerWidth,
          height: innerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor.withOpacity(0.3), width: 1),
          ),
          child: Center(
            child: Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 0.5;

    // Dikey çizgiler
    canvas.drawLine(
      Offset(size.width / 3, 0),
      Offset(size.width / 3, size.height),
      paint,
    );
    canvas.drawLine(
      Offset(2 * size.width / 3, 0),
      Offset(2 * size.width / 3, size.height),
      paint,
    );

    // Yatay çizgiler
    canvas.drawLine(
      Offset(0, size.height / 3),
      Offset(size.width, size.height / 3),
      paint,
    );
    canvas.drawLine(
      Offset(0, 2 * size.height / 3),
      Offset(size.width, 2 * size.height / 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
