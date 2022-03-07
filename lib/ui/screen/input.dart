import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/ui/widget/drawer.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/globals.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';

class Input extends StatelessWidget {
  static const String routeName = '/input';

  final _UrlController = TextEditingController();
  String _url;
  Uri _uri;
  BuildContext _context;

  Input() {
    if (isShare && share != "") {
      _UrlController.text = share;
      isShare = false;
      share = "";
    }
  }

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
          body: SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                      width: MediaQuery.of(context).size.width - 20,
                      child: TextField(
                        controller: _UrlController,
                        decoration: InputDecoration(
                          hintText: 'Paste URL here',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      height: 48,
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: paste, child: Text("Paste")),
                      width: MediaQuery.of(context).size.width / 2 - 20,
                    ),
                    Container(
                      height: 48,
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          onPressed: () {
                            download();
                          },
                          child: Text("Download")),
                      width: MediaQuery.of(context).size.width / 2 - 20,
                    )
                  ],
                )
              ],
            ),
            bottom: true,
            top: true,
            left: true,
            right: true,
          ),
          drawer: MyDrawer(),
        ),
        onWillPop: () async {
          //exiting app, not necessary but still
          if (screens.isNotEmpty) screens.pop();
          return true;
        });
  }

  Future<void> download() async {
    try {
      _uri = Uri.parse(_UrlController.text);
    } catch (e) {
      responseHelper(_context, Status.INVALID_URL);
      return;
    }

    initiateDownload(_context, _uri, _url);
  }

  void paste() {
    Clipboard.getData(Clipboard.kTextPlain)
        .then((value) => _UrlController.text = value.text);
  }

}
