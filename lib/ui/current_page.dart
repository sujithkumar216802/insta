import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/ui/screen/history_view.dart';
import 'package:insta_downloader/ui/screen/input.dart';
import 'package:insta_downloader/ui/screen/splash_screen.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';
import 'package:insta_downloader/utils/web_view.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import 'widget/drawer.dart';

class CurrentPage extends StatefulWidget {
  const CurrentPage({Key key}) : super(key: key);

  @override
  _CurrentPageState createState() => _CurrentPageState();
}

class _CurrentPageState extends State<CurrentPage> {
  int state = 0;
  String _sharedText = "";
  StreamSubscription _intentDataStreamSubscription;
  bool share = false;

  @override
  void initState() {
    super.initState();
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription =
        ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        share = true;
        _sharedText = value;
        change(0);
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        share = true;
        _sharedText = value;
        change(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(140, 255, 255, 255),
        title: Text("InstaSave", style: TextStyle(color: Colors.black)),
        elevation: 10,
      ),
      body: SafeArea(
        child: page(),
        bottom: true,
        top: true,
        left: true,
        right: true,
      ),
      drawer: MyDrawer(
        onChange: change,
      ),
    );
  }

  page() {
    if (state == 0 && WebViewHelper.webView.isRunning()) {
      state = 1;
    }
    switch (state) {
      case 0:
        return SplashScreen(onChange: change);
      case 1:
        if (share) {
          share = false;
          return Input(share: _sharedText);
        }
        return Input();
      case 2:
        return HistoryView();
      // case 3:
      //   return Settings();
      //   break;
    }
  }

  change(int x) async {
    if (x == 2 && await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }
    setState(() {
      state = x;
    });
  }

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }
}
