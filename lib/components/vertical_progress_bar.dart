import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/route/game_routes.dart';

class VerticalProgressBarComponent extends PositionComponent
    with HasGameRef<GameRoutes> {
  final double duration;
  late TimerComponent timerComponent;
  late RectangleComponent bar;
  late RectangleComponent background;
  late RectangleComponent border;

  VerticalProgressBarComponent({
    required Vector2 position,
    required Vector2 size,
    required this.duration,
  }) : super(position: position, size: size) {
    background = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.grey[300]!,
    );

    bar = RectangleComponent(
      size: Vector2(size.x, size.y),
      paint: Paint()..color = Colors.green,
      position: Vector2.zero(),
    );

    border = RectangleComponent(
      size: size,
      paint:
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
    );

    timerComponent = TimerComponent(
      period: duration,
      repeat: false,
      onTick: () => removeFromParent(),
    );
  }

  @override
  Future<void> onLoad() async {
    add(background);
    add(bar);
    add(border);
    add(timerComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    double progress = timerComponent.timer.progress;
    bar.size.y = size.y * (1 - progress);
    bar.position.y = size.y * progress;
    bar.paint.color = Color.lerp(Colors.green, Colors.red, progress)!;
  }
}
