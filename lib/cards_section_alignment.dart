import 'dart:math';

import 'package:flutter/material.dart';
import 'package:tinder_card/profile_card_consumer.dart';

import 'profile_card.dart';

enum CardAlignment { left, right }

class CardsSectionAlignment extends StatefulWidget {
  final ValueChanged<double> onCardDrag;
  final ValueChanged<CardAlignment> onDragEnd;
  final ProfileCardConsumer consumer;

  CardsSectionAlignment(Size size, {List<ProfileCard> cards, this.onCardDrag, this.onDragEnd})
      : this.consumer = ProfileCardConsumer(size, cards: cards);

  @override
  _CardsSectionState createState() => _CardsSectionState();
}

class _CardsSectionState extends State<CardsSectionAlignment> with SingleTickerProviderStateMixin {
  AnimationController _controller;

  Alignment get defaultFrontCardAlign => this.consumer.cardsAlign[2];
  Alignment frontCardAlign;
  double frontCardRot = 0.0;
  ProfileCardConsumer consumer;

  @override
  void initState() {
    super.initState();
    this.consumer = widget.consumer;
    frontCardAlign = this.consumer.cardsAlign[2];
    // Init the animation controller
    _controller = AnimationController(duration: Duration(milliseconds: 700), vsync: this);
    _controller.addListener(() => setState(() {}));
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) changeCardsOrder();
    });
  }

  Widget _buildPanMask(BuildContext context) {
    return _controller.status != AnimationStatus.forward
        ? SizedBox.expand(
            child: GestureDetector(
              // While dragging the first card
              onPanUpdate: (DragUpdateDetails details) {
                // Add what the user swiped in the last frame to the alignment of the card
                if (this.widget.onCardDrag != null) {
                  this.widget.onCardDrag(frontCardAlign.x);
                }
                setState(() {
                  // 20 is the "speed" at which moves the card
                  // 改變 frontCardAlign 的 x y 決定第一張卡片的位置
                  frontCardAlign = Alignment(
                    frontCardAlign.x + 20 * details.delta.dx / MediaQuery.of(context).size.width,
                    frontCardAlign.y + 40 * details.delta.dy / MediaQuery.of(context).size.height,
                  );
                  frontCardRot = frontCardAlign.x; // * rotation speed;
                });
              },
              // When releasing the first card
              onPanEnd: (_) {
                // If the front card was swiped far enough to count as swiped
                if (frontCardAlign.x > 3.0 || frontCardAlign.x < -3.0) {
                  if (this.widget.onDragEnd != null) {
                    if (frontCardAlign.x > 3.0) this.widget.onDragEnd(CardAlignment.right);
                    if (frontCardAlign.x < -3.0) this.widget.onDragEnd(CardAlignment.left);
                  }
                  animateCards();
                } else {
                  // Return to the initial rotation and alignment
                  setState(
                    () {
                      // 移動結束後 frontCardAlign 回到預設位置
                      frontCardAlign = defaultFrontCardAlign;
                      frontCardRot = 0.0;
                    },
                  );
                }
              },
            ),
          )
        : Container();
  }

  List<Widget> _buildCardStack(BuildContext context) {
    final back = backCard();
    final middle = middleCard();
    final front = frontCard();
    List<Widget> stack = <Widget>[];
    if (back != null) stack.add(back);
    if (middle != null) stack.add(middle);
    if (front != null) stack.add(front);
    stack.add(this._buildPanMask(context));
    return stack;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(children: this._buildCardStack(context)),
    );
  }

  Widget backCard() {
    return this.consumer.presentingCards.length > 2
        ? Align(
            alignment: _controller.status == AnimationStatus.forward
                ? CardsAnimation.backCardAlignmentAnim(
                    _controller,
                    begin: this.consumer.cardsAlign[0],
                    end: this.consumer.cardsAlign[1],
                  ).value
                : this.consumer.cardsAlign[0],
            child: SizedBox.fromSize(
              size: _controller.status == AnimationStatus.forward
                  ? CardsAnimation.backCardSizeAnim(
                      _controller,
                      begin: this.consumer.cardsSize[2],
                      end: this.consumer.cardsSize[1],
                    ).value
                  : this.consumer.cardsSize[2],
              child: this.consumer.presentingCards[2],
            ),
          )
        : null;
  }

  Widget middleCard() {
    return this.consumer.presentingCards.length > 1
        ? Align(
            alignment: _controller.status == AnimationStatus.forward
                ? CardsAnimation.middleCardAlignmentAnim(
                    _controller,
                    begin: this.consumer.cardsAlign[1],
                    end: this.consumer.cardsAlign[2],
                  ).value
                : this.consumer.cardsAlign[1],
            child: SizedBox.fromSize(
              size: _controller.status == AnimationStatus.forward
                  ? CardsAnimation.middleCardSizeAnim(
                      _controller,
                      begin: this.consumer.cardsSize[1],
                      end: this.consumer.cardsSize[0],
                    ).value
                  : this.consumer.cardsSize[1],
              child: this.consumer.presentingCards[1],
            ),
          )
        : null;
  }

  Widget frontCard() {
    return this.consumer.presentingCards.isNotEmpty
        ? Align(
            alignment: _controller.status == AnimationStatus.forward
                ? CardsAnimation.frontCardDisappearAlignmentAnim(_controller, frontCardAlign).value
                : frontCardAlign,
            child: Transform.rotate(
              angle: (pi / 180.0) * frontCardRot,
              child: SizedBox.fromSize(size: this.consumer.cardsSize[0], child: this.consumer.presentingCards[0]),
            ),
          )
        : null;
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)
      this.consumer.swapCards();
      frontCardAlign = defaultFrontCardAlign;
      frontCardRot = 0.0;
    });
  }

  void animateCards() {
    _controller.stop();
    _controller.value = 0.0;
    _controller.forward();
  }
}

class CardsAnimation {
  static Animation<Alignment> backCardAlignmentAnim(
    AnimationController parent, {
    @required Alignment begin,
    @required Alignment end,
  }) {
    return AlignmentTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> backCardSizeAnim(
    AnimationController parent, {
    @required Size begin,
    @required Size end,
  }) {
    return SizeTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.4, 0.7, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> middleCardAlignmentAnim(
    AnimationController parent, {
    @required Alignment begin,
    @required Alignment end,
  }) {
    return AlignmentTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Size> middleCardSizeAnim(
    AnimationController parent, {
    @required Size begin,
    @required Size end,
  }) {
    return SizeTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.2, 0.5, curve: Curves.easeIn),
      ),
    );
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
      begin: beginAlign,
      end: Alignment(
          beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0, 0.0), // Has swiped to the left or right?
    ).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
  }
}
