import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class CirclesPainter extends CustomPainter {
  final ui.Image image;
  final List<Face> faces;
  final bool showEyes;
  final bool showMouth;

  CirclesPainter(this.image, this.faces, this.showEyes, this.showMouth);

  void drawContainerIfTrue(
    Canvas canvas,
    Offset position,
    bool condition,
    bool isMouthRegion,
  ) {
    if (condition) {
      drawGreenContainer(canvas, position, isMouthRegion);
    }
  }

  void drawGreenContainer(Canvas canvas, Offset position, bool isMouthRegion) {
    final paint = Paint()..color = Colors.green.withOpacity(0.5);
    final size =
        isMouthRegion ? const Size(50.0, 20.0) : const Size(20.0, 20.0);
    final borderRadius = BorderRadius.circular(30.0);

    final rect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: position, width: size.width, height: size.height),
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    canvas.drawRRect(rect, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green;

    // Calculate scaling factors for the image
    double scaleX = size.width / image.width;
    double scaleY = size.height / image.height;

    // Calculate the destination rectangle for the image
    Rect destRect =
        Rect.fromPoints(const Offset(0, 0), Offset(size.width, size.height));

    // Draw the scaled image
    canvas.drawImageRect(
      image,
      Rect.fromPoints(
        const Offset(0, 0),
        Offset(image.width.toDouble(), image.height.toDouble()),
      ),
      destRect,
      paint,
    );

    for (Face face in faces) {
      final FaceLandmark? leftEye = face.landmarks[FaceLandmarkType.leftEye];
      final FaceLandmark? rightEye = face.landmarks[FaceLandmarkType.rightEye];
      final FaceLandmark? mouth = face.landmarks[FaceLandmarkType.bottomMouth];

      if (leftEye != null) {
        drawContainerIfTrue(
            canvas,
            Offset(leftEye.position.x.toDouble() * scaleX,
                leftEye.position.y.toDouble() * scaleY),
            showEyes,
            false);
      }
      if (rightEye != null) {
        drawContainerIfTrue(
            canvas,
            Offset(rightEye.position.x.toDouble() * scaleX,
                rightEye.position.y.toDouble() * scaleY),
            showEyes,
            false);
      }

      if (mouth != null) {
        drawContainerIfTrue(
            canvas,
            Offset(mouth.position.x.toDouble() * scaleX,
                mouth.position.y.toDouble() * scaleY - 10),
            showMouth,
            true);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
