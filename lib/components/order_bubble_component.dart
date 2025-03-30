import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/Route/game_routes.dart';
import 'package:threecharacters/components/vertical_progress_bar.dart';
import 'package:threecharacters/screens/game_screen.dart';

class OrderBubbleComponent extends PositionComponent
    with HasGameRef<GameRoutes> {
  final MySpriteGame mygame;
  final List<int> stickOrders;
  final double cookingTime;
  late VerticalProgressBarComponent progressBar;
  Map<int, SpriteComponent> orderSprites = {};
  Map<int, bool> completedOrders = {};

  OrderBubbleComponent(this.mygame, this.stickOrders, this.cookingTime)
    : super(size: Vector2(80, 90)) {
    for (int order in stickOrders) {
      completedOrders[order] = false; //each order is incomplete
    }
  }

  @override
  Future<void> onLoad() async {
    progressBar = VerticalProgressBarComponent(
      position: Vector2(5, 15),
      size: Vector2(8, 80),
      duration: cookingTime,
    );

    add(progressBar);

    for (int i = 0; i < stickOrders.length; i++) {
      final stickType = stickOrders[i];
      final spriteSheet = await mygame.gameRef.images.load(
        'stick${stickType}.png',
      );

      final firstFrame = Sprite(
        spriteSheet,
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(4860 / 9, 1144), //9 frames[9 columns, 1 row]
      );

      final stick = SpriteComponent(
        sprite: firstFrame,
        size: Vector2(50, 40),
        position: Vector2(20, 15 + (i * 40)),
      );

      orderSprites[stickType] = stick;
      add(stick);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final Paint bubblePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final RRect bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 10, size.x, size.y),
      const Radius.circular(10),
    );

    canvas.drawRRect(bubble, bubblePaint);
  }

  void markOrderCompleted(int stickType) {
    if (orderSprites.containsKey(stickType) && !completedOrders[stickType]!) {
      final checkmark = TextComponent(
        text: "✓",
        textRenderer: TextPaint(
          style: TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      final orderSprite = orderSprites[stickType]!;
      checkmark.position = Vector2(
        orderSprite.position.x + 40,
        orderSprite.position.y,
      );

      add(checkmark);
      completedOrders[stickType] = true;

      orderSprite.paint = Paint()..color = const Color(0x809E9E9E);
    }
  }
}
