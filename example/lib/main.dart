import 'package:flutter/material.dart';
import 'package:pp_image/pp_image.dart';

void main() => runApp(MyApp());

const mockUrl =
    "https://img.zcool.cn/community/01256a58b54ccea801219c77807a0c.jpg@1280w_1l_2o_100sh.jpg";

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          child: PPImage(
            image: PPNetworkImageItem(url: mockUrl),
            fit: BoxFit.cover,
            placeholder: Container(
              color: Colors.yellow,
            ),
            fadeIn: true,
          ),
        ),
      ),
    );
  }
}
