import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/overlays/gameover.dart';
import 'package:threecharacters/overlays/loading.dart';
import 'package:threecharacters/overlays/pause.dart';
import 'package:threecharacters/route/game_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ininitialize muna bago mag async, WidgetsFlutterBinding.ensureInitialized(); is needed kasi may mga async functions sa main()
  await Flame.device.fullScreen();
  await Flame.device
      .setLandscape(); // once you run the game, ise-set niya into fullscreen and the landscape mode
  await FlameAudio.bgm.initialize(); //initialize the bg music

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget(
          // widget siya from the flame engine para sa game rendering(it renders the game graphics,logic, etc).
          game: GameRoutes(),
          /* main game instance that contains the game logic.
          GameRoutes() is created and passed to GameWidget.
                              This means GameRoutes becomes the game manager*/
          overlayBuilderMap: {
            // to define the various ui overlay, these are screens na magpa-pop up on top of the game
            'GameOver': //
                (context, GameRoutes game) =>
                    GameOverOverlay(mygame: game.activeGame!),
            'Pause':
                (context, GameRoutes game) =>
                    GamePause(mygame: game.activeGame!),
            'Loading': (context, GameRoutes game) => LoadingScreen(),
          },
        ),
      ),
    ),
  );
}
