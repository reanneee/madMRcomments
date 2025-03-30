import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class ScoreComponent extends PositionComponent with HasGameRef {
  late SpriteComponent background;
  late TextComponent scoreText;

  ScoreComponent();

  @override
  Future<void> onLoad() async {
    final scoreSprite = await gameRef.loadSprite('score.png');

    background = SpriteComponent(sprite: scoreSprite, size: Vector2(150, 50));

    scoreText = TextComponent(
      text: "Score: 0",
      textRenderer: TextPaint(
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      position: Vector2(20, 12),
    );

    add(background);
    add(scoreText);

    position = Vector2(20, 20);
  }

  void updateScore(int newScore) {
    scoreText.text = "Score: $newScore";
  }
}
