import 'package:flutter/material.dart';
import 'package:insta_downloader/utils/web_view.dart';

class SplashScreen extends StatefulWidget {
  final onChange;

  const SplashScreen({Key key, @required this.onChange}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState(onChange);
}

class _SplashScreenState extends State<SplashScreen> {
  _SplashScreenState(this.onChange) {
    WebViewHelper.webView.run();
    webViewStarted();
  }

  final onChange;

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
    onChange(1);
  }
}
