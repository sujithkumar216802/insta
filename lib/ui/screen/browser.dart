import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../utils/globals.dart';
import '../widget/drawer.dart';

class Browser extends StatelessWidget {
  const Browser({Key key}) : super(key: key);

  static const String routeName = '/browser';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("InstaSave"),
            elevation: 10,
          ),
          body: InAppWebView(
            initialUrlRequest:
                URLRequest(url: Uri.parse("https://www.instagram.com/")),
          ),
          drawer: MyDrawer(),
        ),
        onWillPop: () async {
          if (screens.isNotEmpty) screens.pop();
          return true;
        });
  }
}
