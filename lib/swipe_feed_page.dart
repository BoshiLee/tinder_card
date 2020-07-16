import 'package:flutter/material.dart';

import 'cards_section_alignment.dart';
import 'profile_card_alignment.dart';

class SwipeFeedPage extends StatefulWidget {
  @override
  _SwipeFeedPageState createState() => _SwipeFeedPageState();
}

class _SwipeFeedPageState extends State<SwipeFeedPage> {
  bool showAlignmentCards = false;

  Size get size => MediaQuery.of(context).size;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            children: <Widget>[
              CardsSectionAlignment(
                Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                ),
                cards: [ProfileCardAlignment(1), ProfileCardAlignment(2), ProfileCardAlignment(3)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
