import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressPainter extends CustomPainter {
  double progress;

  ProgressPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(-2, -3.75, size.width+2, size.height+3.75);
    const startAngle = -math.pi / 2;
    final sweepAngle = (2*math.pi)*progress;
    const useCenter = false;
    final paint = Paint()
      ..color = Color(0xFF75C344)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
