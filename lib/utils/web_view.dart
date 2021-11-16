import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'extractor.dart';

//static to singleton maybe
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
    return extract(await controller.getHtml(), checkLogin: true);
  }
}
