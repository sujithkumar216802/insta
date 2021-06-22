import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/input.dart';

class CurrentPage extends StatelessWidget {
  const CurrentPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(140, 255, 255, 255),
        title: Text("InstaSave", style: TextStyle(color: Colors.black)),
        elevation: 10,
      ),
      body: SafeArea(
        child: Input(),
        bottom: true,
        top: true,
        left: true,
        right: true,
      ),
    );
  }
}
