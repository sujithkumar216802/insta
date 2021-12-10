import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'extractor.dart';

class WebViewHelper {

  static bool completed = false;
  static InAppWebViewController controller;

  static HeadlessInAppWebView webView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: Uri.parse("https://instagram.com/")),
    onWebViewCreated: (_controller) {
      controller = _controller;
    },
    onLoadStop: (InAppWebViewController controller,Uri url) {
      completed = true;
    },
  );

  // page doesn't load fully before loadUrl nds
  static loadUrl(String url) async {
    completed = false;
    await controller.loadUrl(urlRequest: URLRequest(url: Uri.parse(url)),);
    if (!completed)
      await Future.doWhile(() => Future.delayed(Duration(milliseconds: 100)).then((_) => !completed));
    return;
  }


  static isLoggedIn() async {
    loadUrl("https://www.instagram.com/");
    return extract(await controller.getHtml(), checkLogin: true);
  }

  static dispose() {
    webView.dispose();
  }

}
