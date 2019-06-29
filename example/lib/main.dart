import 'package:example/hero_test.dart';
import 'package:flutter/material.dart';
import 'package:pp_image/pp_image.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PPImage Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'PPImage Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) {
                  return HeroTest();
                },
              ),
            );
          },
          child: Container(
            width: 300,
            height: 300,
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
