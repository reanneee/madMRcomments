import 'dart:async';
import 'package:flame_audio/flame_audio.dart';
import 'package:threecharacters/components/background_img_component.dart';
import 'package:threecharacters/route/game_routes.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';

class HomeScreen extends Component with HasGameRef<GameRoutes> {
  /*gives it access to the GameRoutes instance, 
  which means it can interact with the game (like switching screens).*/
  late ButtonComponent playButton;
  bool isBig = true;
  double scaleFactor = 1.0;

  @override
  Future<void> onLoad() async {
    //onLoad() is called when the component is added to the game.
    super.onLoad();

    game.overlays.add("Loading"); // loads the loading screen
    await loadAudio();
    await loadImages();
    game.overlays.remove(
      "Loading",
    ); //Removes the loading overlay once assets are ready.

    add(
      BackgroundComponent(name: "homescreen.png"),
    ); // name parameter passes the filename of the background image ("homescreen.png") to the BackgroundComponent, which then loads and displays the image.

    add(
      SpriteComponent(
        sprite: Sprite(game.images.fromCache("gamename.png")),
        size: Vector2(400, 200),
        position: Vector2((game.size.x - 408) / 2, game.size.y * .1),
        priority: 1,
      ),
    );

    playButton = ButtonComponent(
      button: SpriteComponent(
        sprite: Sprite(game.images.fromCache("play.png")),
        size: Vector2(200, 80),
      ),
      position: Vector2(game.size.x / 2, game.size.y * .8),
      anchor: Anchor.center,
      priority: 1,
      onPressed: () {
        FlameAudio.play("click.mp3");
        game.router.pushReplacementNamed("myGame");
      },
    );

    add(playButton);
  }

  //button animation
  @override
  void update(double dt) {
    super.update(dt);

    if (isBig) {
      scaleFactor += .5 * dt;
      if (scaleFactor >= 1.2) {
        isBig = false;
      }
    } else {
      scaleFactor -= .5 * dt;
      if (scaleFactor <= 1.0) {
        isBig = true;
      }
    }

    playButton.scale.setValues(scaleFactor, scaleFactor);
  }

  //preloads
  Future<void> loadAudio() async {
    await FlameAudio.audioCache.loadAll([
      'chismis_bg.mp3',
      'frying_sound.mp3',
      'click.mp3',
      'audio1.mp3',
      'audio2.mp3',
      'audio3.mp3',
    ]);
  }

  Future<void> loadImages() async {
    await game.images.loadAll([
      'homescreen.png',
      'gamename.png',
      'play.png',
      'game_background.png',
      'table.png',
      'score.png',
    ]);

    for (int i = 1; i <= 6; i++) {
      await game.images.load('character$i.png');
    }

    for (int i = 1; i <= 5; i++) {
      await game.images.load('stick$i.png');
      await game.images.load('burnt$i.png');
    }
  }
}
