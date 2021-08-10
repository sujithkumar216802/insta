import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/ui/history_template.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:share_plus/share_plus.dart';
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
  //TODO
  FileChecker fileChecker = new FileChecker();

  _HistoryViewState() {
    DatabaseHelper.instance.getAllHistory().then((value) {
      for (History x in value) {
        FileChecker.checkAllFiles(x);
      }
      setState(() {
        list = value;
      });
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
                history: list[index],
                index: index,
                function: popUpMenuFunction);
          }),
    );
  }

  void popUpMenuFunction(String value, int index) async {
    switch (value) {
      case 'url':
        await canLaunch(list[index].url)
            ? await launch(list[index].url)
            : throw 'Could not launch ${list[index].url}';
        break;
      case 'share':
        if (FileChecker.checkAllFiles(list[index]) != 2) {
          List<String> listFiles = [];
          for (FileInfo x in list[index].files)
            if (x.isAvailable) listFiles.add(x.file);
          await Share.shareFiles(listFiles);
        } else {
          setState(() {});
        }
        break;
      case 'caption':
        Clipboard.setData(ClipboardData(text: list[index].description));
        break;
      case 'delete':
        FileChecker.checkAllFiles(list[index]);
        for (FileInfo l in list[index].files) {
          if (l.isAvailable) {
            File f = File(l.file);
            f.delete();
            //l.isAvailable = false;
          }
        }
        await DatabaseHelper.instance.delete(list[index]);
        list.removeAt(index);
        setState(() {});
        break;
      case 'download':
        showDialog(
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
        await Downloader.updateHistory(list[index]);
        Navigator.pop(context);
        setState(() {});
        break;
    }
  }
}
