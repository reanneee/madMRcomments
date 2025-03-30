import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/components/progress_bar.dart';
import 'package:threecharacters/components/stick_component.dart';
import 'package:threecharacters/route/game_routes.dart';
import 'package:threecharacters/screens/game_screen.dart';

class StickDisplayComponent extends PositionComponent
    with HasGameRef<GameRoutes> {
  final MySpriteGame mygame;

  StickDisplayComponent({required this.mygame});
  final List<RectangleComponent> rectangles =
      []; // List of empty slots (rectangles) for sticks
  final Map<RectangleComponent, StickComponent?> placedSticks =
      {}; // Map to track which sticks are placed in each rectangle slot
  late RectangleComponent trashContainer;

  static const int numSticks = 5;
  static const double stickWidth = 80;
  static const double stickHeight = 50;
  static const double rectWidth = 80;
  static const double rectHeight = 40;
  static const double rectSpacing = 15;

  @override
  Future<void> onLoad() async {
    final double screenWidth = gameRef.size.x;
    final double screenHeight = gameRef.size.y;
    // Calculate starting X position for the rectangle slots
    final double totalRectWidth =
        (numSticks * rectWidth) + ((numSticks - 1) * rectSpacing);
    final double startX = (screenWidth - totalRectWidth) / 2;
    // Calculate spacing for sticks at the bottom of the screen
    final double stickSpacing =
        (screenWidth - (numSticks * stickWidth)) / (numSticks + 1);
    //Creating the Trash Bin
    trashContainer = RectangleComponent(
      size: Vector2(120, 120),
      position: Vector2(screenWidth - 100, screenHeight - 150),
      paint: Paint()..color = Colors.transparent,
    );
    add(trashContainer);

    final trashText = TextComponent(
      text: "🗑️",
      textRenderer: TextPaint(
        style: const TextStyle(color: Colors.white, fontSize: 60),
      ),
      position: Vector2(
        trashContainer.width / 2 - 40,
        trashContainer.height / 2 - 16,
      ),
    );
    trashContainer.add(trashText);
    // Create and display sticks at the bottom of the screen
    for (int i = 0; i < numSticks; i++) {
      final spriteSheet = gameRef.images.fromCache('stick${i + 1}.png');
      final stick = StickComponent(
        stickType: i + 1,
        spriteSheet: spriteSheet,
        frameWidth: 4860 / 9,
        size: Vector2(stickWidth, stickHeight),
        position: Vector2(
          stickSpacing + i * (stickWidth + stickSpacing),
          screenHeight - 50,
        ),
        displayComponent: this,
        mygame: mygame,
      );
      add(stick);
    }

    //Create empty slots (rectangles) for sticks to be placed on
    for (int i = 0; i < numSticks; i++) {
      final rect = RectangleComponent(
        size: Vector2(rectWidth, rectHeight),
        position: Vector2(
          startX + i * (rectWidth + rectSpacing),
          screenHeight - stickHeight - rectHeight - 10,
        ),
        paint: Paint()..color = const ui.Color.fromARGB(0, 0, 0, 0),
      );
      rectangles.add(rect);
      placedSticks[rect] = null;
      add(rect);
    }
  }

  //Player places a stick on a rectangle
  void placeStickOnRectangle(StickComponent stick) {
    for (final rect in rectangles) {
      // Check if the stick overlaps with an empty slot
      if (stick.toRect().overlaps(rect.toRect()) &&
          placedSticks[rect] == null) {
        final newStick = StickComponent(
          stickType: stick.stickType,
          spriteSheet: stick.spriteSheet,
          frameWidth: stick.frameWidth,
          size: stick.size,
          position: rect.position.clone(), // Move stick to slot
          displayComponent: this,
          mygame: mygame,
        );
        add(newStick);
        newStick.startAnimation(); // Start cooking animation
        placedSticks[rect] = newStick; // Mark the slot as occupied
        return;
      }
    }
  }

  //Remove a stick from a rectangle slot (for example, if thrown in trash)
  void removeStickFromRectangle(StickComponent stick) {
    for (final entry in placedSticks.entries) {
      if (entry.value == stick) {
        placedSticks[entry.key] = null;
        break;
      }
    }
  }

  //Checks if a stick is in the trash bin area
  bool isOverTrash(Vector2 position) {
    return trashContainer.toRect().contains(position.toOffset());
  }

  //Clear the grilling station (removes all cooked/burnt sticks)
  void clearGrillingStation() {
    // Remove all sticks that are currently cooking, cooked, or burnt
    children.whereType<StickComponent>().forEach((stick) {
      if (stick.isCooking || stick.isCooked || stick.isBurnt) {
        stick.removeProgressBar();
        stick.removeWarningText();
        stick.removeFromParent();
      }
    });
    // Remove all progress bars
    children.whereType<ProgressBarComponent>().forEach((progressBar) {
      progressBar.removeFromParent();
    });
    // Remove warning texts ("Almost burnt!" or "Burnt! Trash it!")
    children.whereType<TextComponent>().forEach((text) {
      if (text.text == 'Almost burnt!' || text.text == 'Burnt! Trash it!') {
        text.removeFromParent();
      }
    });
    // Reset all rectangle slots to be empty
    for (final rect in rectangles) {
      placedSticks[rect] = null;
    }
  }
}
