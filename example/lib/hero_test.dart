import 'package:flutter/material.dart';
import 'package:pp_image/pp_image.dart';

class HeroTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: 500,
            child: PPImage(
              image: PPImageItem(
                url:
                    "http://pic121.huitu.com/res/20190523/1663235_20190523114920376020_1.jpg",
              ),
              fit: BoxFit.cover,
              placeholder: Container(
                color: Colors.black,
              ),
              fadeIn: true,
              heroTag: "xxx",
            ),
          ),
        ),
      ),
    );
  }
}
