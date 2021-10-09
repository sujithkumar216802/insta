import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/screen/history_view.dart';
import 'package:insta_downloader/ui/screen/input.dart';

import 'widget/drawer.dart';

class CurrentPage extends StatefulWidget {
  const CurrentPage({Key key}) : super(key: key);

  @override
  _CurrentPageState createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  int state = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(140, 255, 255, 255),
        title: Text("InstaSave", style: TextStyle(color: Colors.black)),
        elevation: 10,
      ),
      body: SafeArea(
        child: page(state),
        bottom: true,
        top: true,
        left: true,
        right: true,
      ),
      drawer: MyDrawer(
        onChange: change,
      ),
    );
  }

  page(int x) {
    switch (x) {
      case 1:
        return Input();
        break;
      case 2:
        return HistoryView();
        break;
      // case 3:
      //   return Settings();
      //   break;
    }
  }

  change(int x) {
    setState(() {
      state = x;
    });
  }
}
