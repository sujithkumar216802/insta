import 'package:flutter/material.dart';
import 'package:insta_downloader/utils/page_routes.dart';
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
    if (!WebViewHelper.completed)
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100))
          .then((_) => !WebViewHelper.completed));
    Navigator.pushReplacementNamed(context, PageRoutes.input);
  }
}
