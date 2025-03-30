import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threecharacters/screens/game_screen.dart';

class GameOverOverlay extends StatefulWidget {
  final MySpriteGame mygame;

  const GameOverOverlay({required this.mygame, super.key});

  @override
  State<GameOverOverlay> createState() => _GameOverOverlayState();
}

class _GameOverOverlayState extends State<GameOverOverlay> {
  int highestScore = 0;

  @override
  void initState() {
    super.initState();

    getHighScore();
  }

  Future<void> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highestScore = prefs.getInt('high_score') ?? 0;
    });
  }

  Future<void> saveNewHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    int newScore = widget.mygame.score;

    await prefs.setInt('high_score', newScore);
  }

  String highScore() {
    if (widget.mygame.score > highestScore) {
      saveNewHighScore();
      return 'New Highest Score: ${widget.mygame.score}';
    } else {
      return 'Highest Score: $highestScore';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 300,
            height: 225,
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
                Text(
                  'Game Over!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Score: ${widget.mygame.score}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Sticks Served: ${widget.mygame.servedSticks}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  highScore(),
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        widget.mygame.isGameOverlayed = false;
                        widget.mygame.resetGame();
                        widget.mygame.game.resumeEngine();
                        widget.mygame.gameRef.overlays.remove('GameOver');
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
                    SizedBox(width: 12),
                    InkWell(
                      onTap: () {
                        widget.mygame.isGameOverlayed = false;
                        widget.mygame.gameRef.overlays.remove('GameOver');
                        widget.mygame.gameRef.overlays.remove('Pause');

                        Future.delayed(Duration(milliseconds: 100), () {
                          widget.mygame.returnHome();
                        });
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

                    SizedBox(width: 12),
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
                                        onTap: () => Navigator.pop(context),
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
        ],
      ),
    );
  }
}
