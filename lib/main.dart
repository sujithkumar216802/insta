import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:insta_downloader/enums/page_routes.dart';
import 'package:insta_downloader/ui/screen/browser.dart';
import 'package:insta_downloader/ui/screen/history_view.dart';
import 'package:insta_downloader/ui/screen/input.dart';
import 'package:insta_downloader/ui/screen/splash_screen.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid)
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sharedText = "";
  StreamSubscription _intentDataStreamSubscription;
  bool _share = false;
  bool _init = false;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      _sharedText = value ?? "";
      if (value != null) {
        _share = true;
        if (_init)
          Navigator.pushReplacementNamed(
              _navigatorKey.currentContext, PageRoutes.input);
      }
    }, onError: (err) => print("getLinkStream error: $err"));

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      _sharedText = value ?? "";
      if (value != null) {
        _share = true;
        if (_init)
          Navigator.pushReplacementNamed(
              _navigatorKey.currentContext, PageRoutes.input);
      }
    });
    _init = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: SplashScreen(),
      onGenerateRoute: (settings) {
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) {
            Widget ret;
            switch (settings.name) {
              case PageRoutes.input:
                if (_share) {
                  _share = false;
                  ret = Input(share: _sharedText);
                }
                ret = Input();
                break;
              case PageRoutes.history:
                ret = const HistoryView();
                break;
              case PageRoutes.browser:
                ret = const Browser();
                break;
            }
            return ret;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
