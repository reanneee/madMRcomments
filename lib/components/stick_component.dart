import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/components/progress_bar.dart';
import 'package:threecharacters/components/stick_display_component.dart';
import 'package:threecharacters/route/game_routes.dart';
import 'package:threecharacters/screens/game_screen.dart';

class StickComponent extends SpriteAnimationComponent
    with DragCallbacks, HasGameRef<GameRoutes> {
  //DragCallbacks mixin allows this component to respond to drag events.
  final MySpriteGame mygame;
  final StickDisplayComponent displayComponent;
  final ui.Image spriteSheet;
  final double frameWidth;
  final int stickType;
  ProgressBarComponent? progressBar;
  TextComponent? warningText;

  static const double cookTime = 8.0;
  static const double warningTime = 6.0;
  double cookTimer = 0.0;
  bool isCooking = false;
  bool isCooked = false;
  bool isBurnt = false;
  bool isDraggable = true;
  bool isWarningShown = false;

  StickComponent({
    //Constructor initializes the stick's type, position, and size.
    required this.stickType,
    required this.spriteSheet,
    required this.frameWidth,
    required Vector2 size,
    required Vector2 position,
    required this.displayComponent,
    required this.mygame,
  }) : super(size: size, position: position);

  late Vector2 originalPosition;

  @override
  Future<void> onLoad() async {
    originalPosition = position.clone();
    animation = SpriteAnimation.fromFrameData(
      spriteSheet,
      SpriteAnimationData.sequenced(
        amount: 9,
        textureSize: Vector2(frameWidth, 1144),
        stepTime: 1,
        loop: false,
      ),
    );
    playing = false;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (!isDraggable) return; //If the stick can't be dragged, exit early.
    if (isCooked || isBurnt) {
      //If it's cooked or burnt, remove it from the grill.
      displayComponent.removeStickFromRectangle(this);
    } else {
      originalPosition =
          position.clone(); // Store the position before dragging.
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (!isDraggable || !isMounted) return;
    //Ensures the component is still valid (isMounted).
    //Moves the stick based on the drag movement (localDelta).
    try {
      position += event.localDelta; // Update position based on drag movement.
    } catch (e) {
      debugPrint('Error updating position: $e');
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (!isDraggable) return;

    if (!isMounted) return;

    if (isBurnt && displayComponent.isOverTrash(position)) {
      removeWarningText();
      removeProgressBar();
      removeFromParent(); // Remove burnt sticks if dragged to trash.
      return;
    }

    if (!isCooked && !isBurnt) {
      mygame.playCookingSound(); // Play sound when placed back.
      displayComponent.placeStickOnRectangle(this);
      position = originalPosition; // Reset position.
    } else if (isCooked && !isBurnt) {
      bool served = false;
      if (isMounted) {
        served = mygame.serveFood(stickType, position);
      }

      if (served) {
        removeProgressBar();
        removeWarningText();
        removeFromParent(); // Remove stick after serving.

        mygame.incrementServedSticks(); // Update game state.
      } else {
        if (isMounted) {
          showFailedServeIndicator(); // Show error if served incorrectly.
          position = originalPosition;
        }
      }
    } else if (isBurnt) {
      if (isMounted) {
        showBurntIndicator(); // Indicate burnt stick status.
        position = originalPosition;
      }
    }
  }

  void showFailedServeIndicator() {
    if (!isMounted) return;

    final messageText = TextComponent(
      text: 'Wrong order!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.orange,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(position.x, position.y - 40),
    );
    displayComponent.add(messageText);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (messageText.isMounted) {
        messageText.removeFromParent();
      }
    });
  }

  void showBurntIndicator() {
    if (!isMounted) return;

    final messageText = TextComponent(
      text: 'Burnt! Trash it!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(position.x, position.y - 40),
    );
    displayComponent.add(messageText);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (messageText.isMounted) {
        messageText.removeFromParent();
      }
    });
  }

  void removeProgressBar() {
    progressBar?.removeFromParent();
    progressBar = null;
  }

  void showWarningText() {
    if (warningText == null && !isWarningShown) {
      isWarningShown = true;
      warningText = TextComponent(
        text: 'Almost burnt!',
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        position: Vector2(position.x, position.y - 20),
      );
      displayComponent.add(warningText!);
    }
  }

  void removeWarningText() {
    warningText?.removeFromParent();
    warningText = null;
    isWarningShown = false;
  }

  void startAnimation() {
    playing = true;
    startCooking();
    animation!.stepTime = cookTime / animation!.frames.length;
  }

  void startCooking() {
    isCooking = true;
    cookTimer = 0.0;
    progressBar = ProgressBarComponent(
      position: Vector2(position.x, position.y - 10),
      width: size.x,
      height: 5,
      totalTime: cookTime,
    );
    displayComponent.add(progressBar!);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isCooking) {
      cookTimer += dt;
      progressBar?.updateProgress(cookTimer / cookTime);

      double cookProgress = cookTimer / cookTime;

      if (cookProgress >= 0.5 && cookProgress < 0.9) {
        if (!isCooked) {
          isCooked = true;
          isBurnt = false;
          showReadyIndicator();
        }
      } else if (cookProgress >= 0.9) {
        isCooked = false;
        isBurnt = true;
      }

      if (cookProgress >= 0.8 && !isWarningShown && !isBurnt) {
        showWarningText();
        progressBar?.setDangerColor();
      }

      if (cookTimer >= cookTime) {
        isCooking = false;
        if (isBurnt) {
          loadBurntSprite();
          removeWarningText();
        }
        removeProgressBar();
      }
    }
  }

  void showReadyIndicator() {
    final readyText = TextComponent(
      text: 'Ready!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(position.x, position.y - 40),
    );
    displayComponent.add(readyText);

    Future.delayed(const Duration(seconds: 2), () {
      if (readyText.isMounted) {
        readyText.removeFromParent();
      }
    });
  }

  Future<void> loadBurntSprite() async {
    final path = 'burnt$stickType.png';
    debugPrint('Loading burnt sprite: $path');

    try {
      final burntSpriteSheet = gameRef.images.fromCache(path);
      debugPrint('Successfully loaded: $path');

      animation = SpriteAnimation.fromFrameData(
        burntSpriteSheet,
        SpriteAnimationData.sequenced(
          amount: 9,
          textureSize: Vector2(frameWidth, 1144),
          stepTime: 1,
          loop: true,
        ),
      );
      playing = true;
    } catch (e) {
      debugPrint('Error loading burnt sprite ($path): $e');
    }
  }
}
