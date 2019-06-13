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
  List<String> mocks = [];
  @override
  void initState() {
    super.initState();

    PPImageDownloadManager.shared.configuration(5, logCallback: (log) {
      print(log);
    });

    for (int i = 0; i < 80; i++) {
      mocks.add(
          "https://img.zcool.cn/community/01256a58b54ccea801219c77807a0c.jpg@1280w_1l_2o_100sh.jpg?params=8-$i");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView.builder(
          itemCount: mocks.length,
          itemBuilder: (context, index) {
            final url = mocks[index];
            return Container(
              // width: 300,
              height: 300,
              child: PPImage(
                image: PPImageItem(url: url),
                fit: BoxFit.cover,
                placeholder: Container(
                  color: Colors.yellow,
                ),
                fadeIn: true,
              ),
            );
          },
        ));
  }
}
