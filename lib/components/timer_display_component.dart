import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/route/game_routes.dart';

class TimerDisplayComponent extends PositionComponent
    with HasGameRef<GameRoutes> {
  double _remainingTime;
  late double totalTime;
  late TextComponent timerText;

  double get remainingTime => _remainingTime;

  TimerDisplayComponent(double totalTime)
    : _remainingTime = totalTime,
      totalTime = totalTime,
      super(size: Vector2(70, 70));

  @override
  Future<void> onLoad() async {
    position = Vector2(gameRef.size.x / 2, 20);

    timerText = TextComponent(
      text: _remainingTime.toInt().toString(),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.brown,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(size.x / 2, size.y / 2),
    );

    add(timerText);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final double progress = math.min(_remainingTime / totalTime, 1.0);
    final Paint backgroundPaint = Paint()..color = const Color(0xFFFDEAC7);

    final Paint progressPaint =
        Paint()
          ..color = Color.lerp(Colors.green, Colors.red, 1 - progress)!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final Offset center = Offset(size.x / 2, size.y / 2);
    final double radius = size.x / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_remainingTime > 0) {
      _remainingTime -= dt;
      timerText.text = _remainingTime.toInt().toString();
    }

    if (_remainingTime < 0) {
      _remainingTime = 0;
    }
  }

  set remainingTime(double value) {
    if (value >= 0) {
      _remainingTime = value;
      timerText.text = _remainingTime.toInt().toString();
    } else {
      print('Remaining time cannot be negative.');
    }
  }

  void addTime(double extraTime) {
    _remainingTime += extraTime;

    totalTime = _remainingTime;
    timerText.text = _remainingTime.toInt().toString();
  }

  void resetTimer() {
    _remainingTime = totalTime;
  }
}
