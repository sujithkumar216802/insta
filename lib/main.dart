import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:insta_downloader/enums/page_routes.dart';
import 'package:insta_downloader/ui/screen/input.dart';
import 'package:insta_downloader/ui/screen/splash_screen.dart';
import 'package:insta_downloader/utils/globals.dart';
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
  StreamSubscription _intentDataStreamSubscription;
  bool _init = false;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      share = value ?? "";
      isShare = true;
      Navigator.popUntil(
          _navigatorKey.currentContext, ModalRoute.withName(PageRoutes.input));
      Navigator.pushReplacement(
        _navigatorKey.currentContext,
        MaterialPageRoute(
          settings: RouteSettings(name: PageRoutes.input),
          builder: (context) => Input(),
        ),
      );
      while (screens.isNotEmpty && screens.top() != PageRoutes.input)
        screens.pop();
    }, onError: (err) => print("getLinkStream error: $err"));

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      share = value ?? "";
      isShare = true;
    });
    _init = true;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      home: SplashScreen(),
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
