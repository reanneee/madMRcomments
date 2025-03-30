import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/components/character_component.dart';
import 'package:threecharacters/components/background_img_component.dart';
import 'package:threecharacters/components/score_component.dart';
import 'package:threecharacters/components/stick_display_component.dart';
import 'package:threecharacters/components/table_component.dart';
import 'package:threecharacters/components/timer_display_component.dart';
import 'package:threecharacters/route/game_routes.dart';
import 'package:flame/sprite.dart';

class MySpriteGame extends Component with HasGameRef<GameRoutes> {
  final math.Random random = math.Random();
  List<SpriteAnimation> spriteAnimations = [];
  List<bool> occupiedPositions = [false, false, false];
  bool assetsLoaded = false;
  int score = 0;
  late TimerComponent gameTimer;
  int servedSticks = 0;
  late TimerComponent characterSpawnTimer;

  late TimerDisplayComponent timerDisplay;
  bool bgMusicStarted = false;
  late ButtonComponent button;

  bool musicOn = true;
  bool soundFx = true;
  bool isGameOverlayed = false;

  int consecutiveCharactersServed = 0;
  static const int requiredConsecutiveServes = 2;
  static const double timeBonus = 20.0;

  @override
  Future<void> onLoad() async {
    for (int i = 1; i <= 6; i++) {
      final spriteSheet = gameRef.images.fromCache(
        'character$i.png',
      ); // retrieve an already preloaded image from the cache instead of loading it again.
      final frameSize = Vector2(
        1056,
        1248,
      ); //per frame, height 1056,width 1248. [actual image 4 col, 3 row =details 4224x3744]

      final spriteSheetData = SpriteSheet(
        image: spriteSheet,
        srcSize: frameSize,
      );
      spriteAnimations.add(
        spriteSheetData.createAnimation(row: i % 3, stepTime: 0.1, loop: true),
      );
    }

    assetsLoaded = true;

    add(BackgroundComponent(name: 'game_background.png'));
    add(TableComponent());
    add(StickDisplayComponent(mygame: this)..priority = 3);
    add(ScoreComponent());

    final menuSprite = await gameRef.loadSprite('menu.png');
    /* This loads an image file named menu.png 
    from the game's assets folder, converting it into a Sprite */

    final menuButtonSprite = SpriteComponent(
      sprite: menuSprite,
      size: Vector2(50, 50),
    );

    button = ButtonComponent(
      position: Vector2(gameRef.size.x - 60, 10),
      size: Vector2(50, 50),
      button: menuButtonSprite,
      onPressed: () {
        FlameAudio.play("click.mp3");
        isGameOverlayed = true;
        FlameAudio.bgm.pause();
        game.pauseEngine();
        game.overlays.add('Pause');
      },
    );

    add(button);

    playBackgroundMusic();

    timerDisplay = TimerDisplayComponent(60.0);
    add(timerDisplay);

    gameTimer = TimerComponent(period: 60.0, repeat: false, onTick: endGame);
    gameTimer.timer.start();
    add(gameTimer);

    characterSpawnTimer = TimerComponent(
      period: 1.0,
      repeat: true,
      onTick: () {
        for (int i = 0; i < 3; i++) {
          if (getNextAvailablePosition() != null) {
            addCharacter();
          }
        }
      },
    );
    add(characterSpawnTimer);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameTimer.timer.isRunning() && !isGameOverlayed) {
      timerDisplay.remainingTime =
          gameTimer.timer.limit - gameTimer.timer.current;
    }

    if (isGameOverlayed && button.parent != null) {
      remove(button);
    } else if (!isGameOverlayed && button.parent == null) {
      add(button);
    }
  }

  void playBackgroundMusic() {
    if (!bgMusicStarted) {
      FlameAudio.bgm.play('chismis_bg.mp3', volume: 0.5);
      bgMusicStarted = true;
    }
  }

  void stopBackgroundMusic() {
    FlameAudio.bgm.stop();
    bgMusicStarted = false;
  }

  void playOrderSound(int orderSoundIndex) {
    // final int orderSoundIndex = random.nextInt(3) + 1;
    if (soundFx) FlameAudio.play('audio$orderSoundIndex.mp3');
  }

  void playCookingSound() {
    if (soundFx) FlameAudio.play('frying_sound.mp3');
  }

  int? getNextAvailablePosition() {
    for (int i = 0; i < occupiedPositions.length; i++) {
      if (!occupiedPositions[i]) {
        return i;
      }
    }
    return null;
  }

  void addCharacter() {
    if (!assetsLoaded || spriteAnimations.isEmpty) {
      return;
    }

    int? positionIndex = getNextAvailablePosition();
    if (positionIndex != null) {
      occupiedPositions[positionIndex] = true;

      final Vector2 startPosition = Vector2(-150, gameRef.size.y / 2 - 75);
      final Vector2 targetPosition = getTargetPosition(positionIndex);

      final int randInt = random.nextInt(spriteAnimations.length);
      final SpriteAnimation randomAnimation = spriteAnimations[randInt];
      double cookingTime = 25;
      final AnimatedCharacter character = AnimatedCharacter(
        randomAnimation,
        startPosition,
        targetPosition,
        positionIndex,
        cookingTime,
        () => occupiedPositions[positionIndex] = false,
        this,
      );

      add(character);
      playOrderSound(randInt >= 1 && randInt <= 3 ? random.nextInt(2) + 1 : 3);
    }
  }

  Vector2 getTargetPosition(int index) {
    final screenWidth = gameRef.size.x;
    final screenHeight = gameRef.size.y;
    final double characterWidth = 120;
    final double spacing = (screenWidth - (characterWidth * 3)) / 4;

    switch (index) {
      case 0:
        return Vector2(
          screenWidth / 2 - characterWidth / 2,
          screenHeight / 2 - 90,
        );
      case 1:
        return Vector2(spacing + 40, screenHeight / 2 - 90);
      case 2:
        return Vector2(
          spacing * 3 - 20 + characterWidth * 2,
          screenHeight / 2 - 90,
        );
      default:
        return Vector2.zero();
    }
  }

  void incrementServedSticks() {
    servedSticks++;
  }

  bool serveFood(int stickType, Vector2 position) {
    Iterable<Component> components = children.whereType<AnimatedCharacter>();
    for (final component in components) {
      final character = component as AnimatedCharacter;
      if (character.toRect().contains(position.toOffset())) {
        if (character.wantsStick(stickType)) {
          character.serveFoodItem(stickType);
          return true;
        }
      }
    }
    return false;
  }

  void characterFullyServed() {
    consecutiveCharactersServed++; // Increases the consecutiveCharactersServed count by 1 each time a customer is fully served.

    if (consecutiveCharactersServed == requiredConsecutiveServes) { // dito ichecheck lang natin if the vendor has served a required number of consecutive characters
      addTimeBonus(); //call addTimeBonus method 
      showTimeBonusMessage(); // call showTimeBonusTimeMessage, where a message is shown to indcate the bonus time
      consecutiveCharactersServed = 0; // after the bonus is applied, we will reset the consecutiveCharctersServed  counter to 0,
    }
  }

  void addTimeBonus() {
    double elapsedTime = gameTimer.timer.current;
    double remainingTime = gameTimer.timer.limit - elapsedTime;
    double newRemainingTime = remainingTime + timeBonus;

    remove(gameTimer);

    gameTimer = TimerComponent(
      period: newRemainingTime,
      repeat: false,
      onTick: endGame,
    );

    add(gameTimer);
    gameTimer.timer.start();

    timerDisplay.totalTime = gameTimer.timer.limit;
    timerDisplay.remainingTime = newRemainingTime;

    print(
      'Added bonus time: +$timeBonus seconds. New remaining time: $newRemainingTime',
    );
  }

  void resetConsecutiveCounter() {
    consecutiveCharactersServed = 0;
  }

  void showTimeBonusMessage() {
    final TextComponent bonusText = TextComponent(
      text: '+${timeBonus.toInt()} SECONDS BONUS!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    bonusText.position = Vector2(
      (game.size.x - bonusText.width) / 2,
      game.size.y / 4,
    );

    add(bonusText);

    Future.delayed(const Duration(seconds: 2), () {
      if (bonusText.isMounted) {
        bonusText.removeFromParent();
      }
    });
  }

  void updateScore(int points) {
    int newScore = score + points;
    if (newScore < 0) {
      newScore = 0;
    }

    score = newScore;
    final scoreComponent = children.whereType<ScoreComponent>().firstOrNull;
    if (scoreComponent != null) {
      scoreComponent.updateScore(score);
    }
  }

  void resetGame() {
    children.whereType<AnimatedCharacter>().forEach((character) {
      character.removeFromParent();
    });

    occupiedPositions = [false, false, false];

    servedSticks = 0;
    score = 0;
    consecutiveCharactersServed = 0;
    final scoreComponent = children.whereType<ScoreComponent>().firstOrNull;
    scoreComponent?.updateScore(score);

    timerDisplay.remainingTime = 60;

    remove(gameTimer);
    remove(characterSpawnTimer);

    playBackgroundMusic();
    gameTimer = TimerComponent(period: 60.0, repeat: false, onTick: endGame);

    characterSpawnTimer = TimerComponent(
      period: 1.0,
      repeat: true,
      onTick: () {
        for (int i = 0; i < 3; i++) {
          if (getNextAvailablePosition() != null) {
            addCharacter();
          }
        }
      },
    );

    add(gameTimer);
    add(characterSpawnTimer);

    gameTimer.timer.start();
    characterSpawnTimer.timer.start();

    final stickDisplay =
        children.whereType<StickDisplayComponent>().firstOrNull;
    if (stickDisplay != null) {
      stickDisplay.clearGrillingStation();
    }

    gameRef.overlays.remove('GameOver');
  }

  void endGame() {
    gameTimer.timer.stop();
    characterSpawnTimer.timer.stop();

    children.whereType<AnimatedCharacter>().forEach((character) {
      character.removeFromParent();
    });

    final stickDisplay =
        children.whereType<StickDisplayComponent>().firstOrNull;
    if (stickDisplay != null) {
      stickDisplay.clearGrillingStation();
    }

    gameOverPopup();
  }

  void gameOverPopup() {
    stopBackgroundMusic();
    isGameOverlayed = true;
    gameRef.overlays.add('GameOver');
  }

  void continueGame() {
    game.overlays.remove("Pause");

    if (!musicOn) {
      FlameAudio.bgm.pause();
    } else {
      FlameAudio.bgm.resume();
    }
  }

  void returnHome() {
    game.overlays.remove("Pause");

    game.router.pushReplacementNamed("home");
  }
}
