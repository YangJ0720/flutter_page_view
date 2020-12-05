import 'package:flutter/material.dart';

import 'guide_view.dart';

class Home extends StatelessWidget {
  final List<String> _list = [
    'images/page_one.jpg',
    'images/page_two.jpeg',
    'images/page_three.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IconButton(
          icon: Icon(Icons.photo),
          onPressed: () {
            var view = GuideView(_list, 450);
            showDialog(context: context, builder: (_) => view);
          },
        ),
      ),
    );
  }
}
