import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/widgets.dart';
import 'package:threecharacters/components/order_bubble_component.dart';
import 'package:threecharacters/route/game_routes.dart';
import 'package:threecharacters/screens/game_screen.dart';

class AnimatedCharacter extends PositionComponent with HasGameRef<GameRoutes> {
  final MySpriteGame mygame;
  final SpriteAnimation animation;
  final int positionIndex;
  final VoidCallback onTimerEnd;
  late SpriteAnimationComponent characterSprite;
  late OrderBubbleComponent orderBubble;
  late TimerComponent timerComponent;
  double cookingTime;
  Set<int> servedItems = {};

  final List<int> stickOrders = [
    Random().nextInt(5) + 1, // At least one order
    if (Random().nextBool()) Random().nextInt(5) + 1, // second order
  ];

  double get maxCookingTime => cookingTime;
  AnimatedCharacter(
    this.animation,
    Vector2 startPosition, //Sets initial position
    Vector2 targetPosition, //Moves character to targetPosition
    this.positionIndex,
    double initialCookingTime, //This parameter is now ignored and recalculated
    this.onTimerEnd,
    this.mygame,
  ) : cookingTime = 0.0,
      super(position: startPosition, size: Vector2(100, 200)) {
    cookingTime = stickOrders.length == 1 ? 15.0 : 25.0;
    characterSprite = SpriteAnimationComponent(
      animation: animation,
      size: Vector2(100, 150),
    ); // sprite animation component for the character

    orderBubble = OrderBubbleComponent(mygame, stickOrders, maxCookingTime);
    orderBubble.position = Vector2(110, 0);

    timerComponent = TimerComponent(
      // timer
      period: maxCookingTime,
      repeat: false,
      onTick: () {
        // this will execute when the timer completes its set duraton which is the maxCookingTime
        if (servedItems.isEmpty) {
          mygame.updateScore(
            -10,
          ); // if no items were served, the player loses 10 points
          mygame.resetConsecutiveCounter(); //resets
        } else if (servedItems.length < stickOrders.length) {
          
          mygame.updateScore(-10);  //incomplete order, loses 10 points 
          mygame.resetConsecutiveCounter(); //resets
        }
        add(
          MoveToEffect(
            Vector2(gameRef.size.x + 150, position.y), // defines the destination where the object will move(pa-right)
            EffectController(duration: 1.5, curve: Curves.easeIn),
            onComplete: () { // this will execute when the movement is finished
              removeFromParent(); //remove the character from the game after niyang mag exit 
              onTimerEnd(); // Calls a method (onTimerEnd()) to handle further logic.
            },
          ),
        );   // aalis na yung character
      },
    );

    add(
      MoveToEffect(
        targetPosition,
        EffectController(duration: 1.5, curve: Curves.easeOut),
      ),
    ); // Moves the character to its target position
  }

  @override
  Future<void> onLoad() async {
    add(characterSprite);
    add(orderBubble);
    add(timerComponent);
  }

  bool wantsStick(int stickType) {
    return stickOrders.contains(stickType) && !servedItems.contains(stickType);
  } //to check if the specific type of food na ba iyon is part ng customer's order
  // Checks if stickType is not in the servedItems collection to ensures that stickType has not already been served.


  void serveFoodItem(int stickType) { //  stickType is passed as an argument to specify which food item is being served.


    if (wantsStick(stickType)) { // ichecheck niya if part ba siya ng customer's order nd hindi pa naserved iyon
      servedItems.add(stickType); //  add that ordered food into the servedItems
      orderBubble.markOrderCompleted(stickType); // then, once it is successsfully served we will marked it as completed

      if (servedItems.length == stickOrders.length) {
        //if the vendor has served all foods
        mygame.updateScore(10 * stickOrders.length); // we will update the score
        mygame.characterFullyServed(); // it tracks how many cutomers has been fully served
        add(
          MoveToEffect(
            Vector2(gameRef.size.x + 150, position.y),
            EffectController(duration: 1.5, curve: Curves.easeIn),
            onComplete: () {
              removeFromParent();
              onTimerEnd();
            },
          ),
        ); // once it is served, aalis na
      }
    }
  }
}
