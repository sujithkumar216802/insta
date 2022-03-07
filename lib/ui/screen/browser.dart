import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../enums/status_enum.dart';
import '../../utils/downloader.dart';
import '../../utils/globals.dart';
import '../../utils/url_checker.dart';
import '../widget/drawer.dart';

class Browser extends StatefulWidget {
  const Browser({Key key}) : super(key: key);

  static const String routeName = '/browser';

  @override
  State<Browser> createState() => _BrowserState();
}

class _BrowserState extends State<Browser> {
  bool _showFab = false;
  String _url;
  Uri _uri;
  BuildContext _context;
  InAppWebViewController controller;

  @override
  Widget build(BuildContext context) {
    _context = context;
    return WillPopScope(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            title: Text("InstaSave"),
            elevation: 10,
          ),
          body: InAppWebView(
            onWebViewCreated: (_controller) {
              controller = _controller;
            },
            initialUrlRequest:
                URLRequest(url: Uri.parse("https://www.instagram.com/")),
            onLoadStop: (InAppWebViewController controller, Uri url) async {
              //url is wrong, have to fetch the url again
              //TODO _url seems to pickup the correct url from the second post....
              _uri = await controller.getUrl();
              var urlCheck = urlChecker(_uri);
              if (urlCheck is Status) {
                _showFab = false;
              } else {
                _showFab = true;
                _url = urlCheck;
              }
              setState(() {});
            },
          ),
          drawer: MyDrawer(),
          floatingActionButton: _showFab
              ? FloatingActionButton(
                  onPressed: () async {
                    initiateDownload(_context, _uri, _url);
                  },
                  child: const Icon(Icons.download),
                )
              : null,
        ),
        onWillPop: () async {
          if (await controller.canGoBack()) {
            controller.goBack();
            return false;
          } else {
            if (screens.isNotEmpty) screens.pop();
            return true;
          }
        });
  }
}
