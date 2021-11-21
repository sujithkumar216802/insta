import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'extractor.dart';

class WebViewHelper {

  static bool completed = false;

  static HeadlessInAppWebView webView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: Uri.parse("https://instagram.com/")),
    onWebViewCreated: (_controller) {
      controller = _controller;
    },
    onLoadStop: (InAppWebViewController controller,Uri url) {
      completed = true;
    },
  );

  static InAppWebViewController controller;

  static dispose() {
    webView.dispose();
  }

  static isLoggedIn() async {
    //preparation to check if the user is logged in
    completed = false;
    await controller.loadUrl(urlRequest: URLRequest(url: Uri.parse("https://www.instagram.com/")),);
    if (!completed)
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100)).then((_) => !completed));

    return extract(await controller.getHtml(), checkLogin: true);
  }
}
