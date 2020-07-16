import 'dart:math';

import 'package:flutter/material.dart';

import 'profile_card.dart';

List<Alignment> cardsAlign = [Alignment(0.0, 1.0), Alignment(0.0, 0.8), Alignment(0.0, 0.0)];
List<Size> cardsSize = List(3);

enum CardAlignment { left, right }

class CardsSectionAlignment extends StatefulWidget {
  final ValueChanged<double> onCardDrag;
  final ValueChanged<CardAlignment> onDragEnd;
  final List<ProfileCard> cards;

  CardsSectionAlignment(Size size, {this.cards = const [], this.onCardDrag, this.onDragEnd}) {
    cardsSize[0] = Size(size.width * 0.9, size.height * 0.9);
    cardsSize[1] = Size(size.width * 0.85, size.height * 0.85);
    cardsSize[2] = Size(size.width * 0.8, size.height * 0.8);
  }

  @override
  _CardsSectionState createState() => _CardsSectionState();
}

class _CardsSectionState extends State<CardsSectionAlignment> with SingleTickerProviderStateMixin {
  int cardsCounter = 0;

  AnimationController _controller;

  final Alignment defaultFrontCardAlign = Alignment(0.0, 0.0);
  Alignment frontCardAlign;
  double frontCardRot = 0.0;
  List<ProfileCard> cards = [];

  @override
  void initState() {
    super.initState();

    // Init cards
    this.cards = widget.cards;
    cardsCounter = widget.cards.length;

    frontCardAlign = cardsAlign[2];

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
                  frontCardAlign = Alignment(
                      frontCardAlign.x + 20 * details.delta.dx / MediaQuery.of(context).size.width,
                      frontCardAlign.y + 40 * details.delta.dy / MediaQuery.of(context).size.height);

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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: <Widget>[
          backCard(),
          middleCard(),
          frontCard(),
          this._buildPanMask(context),
        ],
      ),
    );
  }

  Widget backCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.backCardAlignmentAnim(_controller).value
          : cardsAlign[0],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.backCardSizeAnim(_controller).value
              : cardsSize[2],
          child: cards[2]),
    );
  }

  Widget middleCard() {
    return Align(
      alignment: _controller.status == AnimationStatus.forward
          ? CardsAnimation.middleCardAlignmentAnim(_controller).value
          : cardsAlign[1],
      child: SizedBox.fromSize(
          size: _controller.status == AnimationStatus.forward
              ? CardsAnimation.middleCardSizeAnim(_controller).value
              : cardsSize[1],
          child: cards[1]),
    );
  }

  Widget frontCard() {
    return Align(
        alignment: _controller.status == AnimationStatus.forward
            ? CardsAnimation.frontCardDisappearAlignmentAnim(_controller, frontCardAlign).value
            : frontCardAlign,
        child: Transform.rotate(
          angle: (pi / 180.0) * frontCardRot,
          child: SizedBox.fromSize(size: cardsSize[0], child: cards[0]),
        ));
  }

  void changeCardsOrder() {
    setState(() {
      // Swap cards (back card becomes the middle card; middle card becomes the front card, front card becomes a  bottom card)

      cards[2] = ProfileCard(cardsCounter);
      cardsCounter++;

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
  static Animation<Alignment> backCardAlignmentAnim(AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[0], end: cardsAlign[1])
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Size> backCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[2], end: cardsSize[1])
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.4, 0.7, curve: Curves.easeIn)));
  }

  static Animation<Alignment> middleCardAlignmentAnim(AnimationController parent) {
    return AlignmentTween(begin: cardsAlign[1], end: cardsAlign[2])
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Size> middleCardSizeAnim(AnimationController parent) {
    return SizeTween(begin: cardsSize[1], end: cardsSize[0])
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.2, 0.5, curve: Curves.easeIn)));
  }

  static Animation<Alignment> frontCardDisappearAlignmentAnim(AnimationController parent, Alignment beginAlign) {
    return AlignmentTween(
            begin: beginAlign,
            end: Alignment(
                beginAlign.x > 0 ? beginAlign.x + 30.0 : beginAlign.x - 30.0, 0.0) // Has swiped to the left or right?
            )
        .animate(CurvedAnimation(parent: parent, curve: Interval(0.0, 0.5, curve: Curves.easeIn)));
  }
}
