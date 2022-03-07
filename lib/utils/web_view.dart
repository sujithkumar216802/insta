import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:insta_downloader/enums/status_enum.dart';

import 'extractor.dart';

class WebViewHelper {
  static bool completed = false;
  static InAppWebViewController controller;

  static HeadlessInAppWebView webView = HeadlessInAppWebView(
    initialUrlRequest: URLRequest(url: Uri.parse("https://instagram.com/")),
    onWebViewCreated: (_controller) {
      controller = _controller;
    },
    onLoadStop: (InAppWebViewController controller, Uri url) {
      completed = true;
    },
  );

  // page doesn't load fully before inbuilt loadUrl returns
  static loadUrl(String url) async {
    completed = false;
    await controller.loadUrl(
      urlRequest: URLRequest(url: Uri.parse(url)),
    );
    if (!completed)
      await Future.doWhile(() =>
          Future.delayed(Duration(milliseconds: 100)).then((_) => !completed));
    return;
  }

  static isLoggedIn() async {
    await loadUrl("https://www.instagram.com/");
    return extract(await controller.getHtml(), checkLogin: true);
  }

  static userLogin(context, callback,
      {String val, int index, String URL}) async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
              content: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://www.instagram.com/")),
                onLoadStop: (controller, url) async {
                  var value =
                      extract(await controller.getHtml(), checkLogin: true);
                  if (value is! Status && value) {
                    if (val != null)
                      callback(val, index);
                    else
                      callback(context, URL);
                  }
                },
              ),
            ));
  }

  static dispose() {
    webView.dispose();
  }
}
