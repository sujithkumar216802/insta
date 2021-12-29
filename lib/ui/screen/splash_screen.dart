import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/page_routes.dart';
import 'package:insta_downloader/utils/web_view.dart';

class SplashScreen extends StatefulWidget {
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
    Navigator.pushReplacementNamed(context, PageRoutes.input);
  }
}
