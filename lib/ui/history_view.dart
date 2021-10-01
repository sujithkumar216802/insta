import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/ui/history_template.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/history_model.dart';
import '../utils/database_helper.dart';
import '../utils/file_checker.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key key}) : super(key: key);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<History> list = [];

  _HistoryViewState() {
    DatabaseHelper.instance.getAllHistory().then((value) {
      setState(() => list = value);
    });
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return HistoryTemplate(
                key: ValueKey(list[index].url),
                history: list[index],
                index: index,
                function: popUpMenuFunction);
          }),
    );
  }

  //TODO CHANGE EVERYTHING TO FIT THE PREVIEW
  void popUpMenuFunction(String value, int index) async {
    Map temp = await checkAllFiles(list[index]);
    int type = temp['type'];
    List<String> files = temp['files'];
    List<FileInfo> notAvailable = temp['not_available'];

    switch (value) {
      case 'url':
        await canLaunch(list[index].url)
            ? await launch(list[index].url)
            : throw 'Could not launch ${list[index].url}';
        break;
      case 'share':
        //TODO just download the files that are not available ig
        if (type != 2) shareFiles(files);
        setState(() {});
        break;
      case 'caption':
        Clipboard.setData(ClipboardData(text: list[index].description));
        break;
      case 'delete':
        for (String file in files) {
          File f = File(file);
          f.delete();
        }
        await DatabaseHelper.instance.delete(list[index]);
        list.removeAt(index);
        setState(() {});
        break;
      case 'download':
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (_) => AlertDialog(
                title: Text('Downloading'),
                content: Align(
                  child: Container(
                      child: CircularProgressIndicator(),
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 5),
                  alignment: Alignment.center,
                  heightFactor: 1,
                )));
        await updateHistory(notAvailable);
        Navigator.pop(context);
        setState(() {});
        break;
    }
  }
}
