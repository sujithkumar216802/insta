import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/page_routes.dart';
import 'package:insta_downloader/utils/globals.dart';
import 'package:insta_downloader/utils/web_view.dart';

import 'input.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/';

  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  _SplashScreenState() {
    WebViewHelper.webView.run();
    webViewStarted();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        "assets/images/icon.png",
        fit: BoxFit.cover,
      ),
    );
  }

  void webViewStarted() async {
    if (!WebViewHelper.webView.isRunning())
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
          .then((_) => !WebViewHelper.webView.isRunning()));
    screens.push(PageRoutes.input);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: PageRoutes.input),
          builder: (context) => Input(),
        ),
        (route) => false);
  }
}
