import 'package:flame/components.dart';
import 'package:threecharacters/route/game_routes.dart';

class TableComponent extends SpriteComponent with HasGameRef<GameRoutes> {
  @override
  Future<void> onLoad() async {
    sprite = await gameRef.loadSprite('table.png');
    size = Vector2(gameRef.size.x, gameRef.size.y * 0.6);
    position = Vector2(0, gameRef.size.y - size.y);
    priority = 2;
  }
}
