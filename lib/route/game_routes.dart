import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart' hide Route, OverlayRoute;
import 'package:threecharacters/screens/game_screen.dart';
import 'package:threecharacters/screens/home_screen.dart';

class GameRoutes extends FlameGame with WidgetsBindingObserver {
  // to detect minimized, paused, or resumed.
  GameRoutes() {
    // constructor
    WidgetsBinding.instance.addObserver(
      this,
    ); // to observe the flutter app lifecyle para mamonitor ung state ng app if kailan siya naka-pause, resume or inactive yung app.
  }
  late final RouterComponent router; //
  MySpriteGame? activeGame; // store the current game intance(MySpriteGame)

  @override
  Future<void> onLoad() async {
    // TODO: implement onLoad

    activeGame = MySpriteGame();

    add(
      router = RouterComponent(
        initialRoute: 'home', // default screen

        routes: {
          'home': Route(HomeScreen.new), //home screen
          'myGame': Route(
            () {
              activeGame = MySpriteGame();
              return activeGame!;
            },
            maintainState: false,
          ) /* The game instance is discarded when the user leaves the route. 
          If they return to 'myGame', a new instance of MySpriteGame is created. 
          This ensures a fresh game restart each time the user navigates back. */,
        },
      ),
    );
  }

  @override
  void onRemove() {
    // TODO: implement onRemove
    WidgetsBinding.instance.removeObserver(
      this,
    ); // Removes this object from listening to app lifecycle events
    FlameAudio.bgm.stop(); // Stops background music when the game is removed
    super.onRemove();
  }

  //Called when the game instance is removed (e.g., navigating away or closing the app).
  //Stops observing the app lifecycle to prevent memory leaks.
  //Stops background music to avoid audio playing after the game exits.

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pauseEngine();
      FlameAudio.bgm.pause();
    } else if (state == AppLifecycleState.resumed) {
      resumeEngine();
      FlameAudio.bgm.resume();
    }
  }

  void home() {
    router.pop();
    router.pushReplacementNamed('home');
  }

  void restart() {
    router.pushReplacementNamed('myGame');
  }
}
