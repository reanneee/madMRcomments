import 'dart:ui';

import 'package:flame/components.dart';

class ProgressBarComponent extends PositionComponent {
  final double width;
  final double height;
  final double totalTime;
  double progress = 0.0;
  Color progressColor = const Color(0xFF00FF00);

  ProgressBarComponent({
    required Vector2 position,
    required this.width,
    required this.height,
    required this.totalTime,
  }) : super(position: position, size: Vector2(width, height));

  void setDangerColor() {
    progressColor = const Color(0xFFFF0000);
  }

  @override
  void render(Canvas canvas) {
    final Paint backgroundPaint = Paint()..color = const Color(0xFFCCCCCC);
    final Paint progressPaint = Paint()..color = progressColor;

    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), backgroundPaint);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, width * progress, height),
      progressPaint,
    );
  }

  void updateProgress(double newProgress) {
    progress = newProgress.clamp(0.0, 1.0);
  }
}
