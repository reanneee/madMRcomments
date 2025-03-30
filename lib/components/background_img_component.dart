import 'package:flame/components.dart';
import 'package:threecharacters/route/game_routes.dart';

class BackgroundComponent extends SpriteComponent with HasGameRef<GameRoutes> {
  //
  String name;

  BackgroundComponent({
    required this.name,
  }); // The constructor takes name as a required parameter, which represents the filename of the background image.

  @override
  Future<void> onLoad() async {
    //loads the bg image when the component is added to the game
    sprite = Sprite(game.images.fromCache(name)); //fetch the image
    size = gameRef.size; //bg fills the entire game screen
    priority =
        0; // determines the rendering order. A lower priority means it will be drawn behind other components (like characters or UI elements).
  }
}
