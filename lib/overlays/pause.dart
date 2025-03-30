import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:threecharacters/screens/game_screen.dart';

class GamePause extends StatefulWidget {
  const GamePause({required this.mygame, super.key});

  final MySpriteGame mygame;

  @override
  State<GamePause> createState() => _GamePauseState();
}

class _GamePauseState extends State<GamePause> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 200,
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/banner.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Music",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          FlameAudio.play("click.mp3");
                          setState(() {
                            widget.mygame.musicOn = !widget.mygame.musicOn;
                          });
                        },
                        child: Image.asset(
                          widget.mygame.musicOn
                              ? 'assets/images/unmute.png'
                              : 'assets/images/mute.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Sound Effects",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          FlameAudio.play("click.mp3");
                          setState(() {
                            widget.mygame.soundFx = !widget.mygame.soundFx;
                          });
                        },
                        child: Image.asset(
                          widget.mygame.soundFx
                              ? 'assets/images/unmute.png'
                              : 'assets/images/mute.png',
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    InkWell(
                      onTap: () {
                        FlameAudio.play("click.mp3");
                        widget.mygame.resetGame();
                        widget.mygame.isGameOverlayed = false;
                        widget.mygame.game.resumeEngine();
                        widget.mygame.gameRef.overlays.remove('Pause');
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/restart.png'),
                          ),
                        ),
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        FlameAudio.play("click.mp3");
                        widget.mygame.game.resumeEngine();
                        widget.mygame.isGameOverlayed = false;
                        widget.mygame.returnHome();
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/home.png'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                backgroundColor: Colors.transparent,
                                contentPadding: EdgeInsets.zero,
                                content: Stack(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage(
                                              'assets/images/instruction.png',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        height: 300,
                                        width: 500,
                                      ),
                                    ),
                                    Positioned(
                                      top: -5,
                                      right: 15,
                                      child: InkWell(
                                        onTap: () {
                                          FlameAudio.play("click.mp3");
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          height: 50,
                                          width: 50,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(
                                                'assets/images/close.png',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        );
                      },
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/info.png'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            top: 10,
            child: InkWell(
              onTap: () {
                FlameAudio.play("click.mp3");
                widget.mygame.game.resumeEngine();
                widget.mygame.isGameOverlayed = false;
                widget.mygame.continueGame();
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/close.png'),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
