import 'package:flutter/material.dart';
import 'package:tinder_card/profile_card.dart';

class ProfileCardConsumer {
  List<ProfileCard> presentingCards = [];
  List<ProfileCard> backCards = [];
  int get remindCards => this.backCards.length;
  List<Alignment> cardsAlign = [Alignment(0.0, 0.75), Alignment(0.0, 0.5), Alignment(0, 0)];
  List<Size> cardsSize = List(3);

  ProfileCardConsumer(Size size, {List<ProfileCard> cards = const []}) {
    cardsSize[0] = Size(size.width * 0.9, size.height * 0.9);
    cardsSize[1] = Size(size.width * 0.85, size.height * 0.85);
    cardsSize[2] = Size(size.width * 0.8, size.height * 0.8);
    this.backCards = cards;
    this.initCards();
  }

  void initCards() {
    if (backCards.isNotEmpty) {
      if (backCards.length > 3) {
        this.presentingCards = this.backCards.sublist(0, 3);
        this.backCards.removeRange(0, 3);
      } else {
        this.presentingCards = this.backCards;
        this.backCards.clear();
      }
    }
  }

  void swapCards() {
    if (presentingCards.isNotEmpty) {
      this.presentingCards.removeAt(0);
    }
    if (this.backCards.isNotEmpty) {
      this.presentingCards.add(this.backCards.first);
      this.backCards.removeAt(0);
    }
  }
}
