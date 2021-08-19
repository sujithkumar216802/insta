import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/ui/history_template.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/history_model.dart';
import '../utils/database_helper.dart';

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
                history: list[index],
                index: index,
                function: popUpMenuFunction);
          }),
    );
  }

  //TODO CHANGE EVERYTHING TO FIT THE PREVIEW
  void popUpMenuFunction(String value, int index) async {

    switch (value) {
      case 'url':
        await canLaunch(list[index].url)
            ? await launch(list[index].url)
            : throw 'Could not launch ${list[index].url}';
        break;
      case 'share':
        List<String> files = list[index].files.map((e) => e.file).toList();
        await Share.shareFiles(files);
        break;
      case 'caption':
        Clipboard.setData(ClipboardData(text: list[index].description));
        break;
      case 'delete':
        for (FileInfo file in list[index].files) {
          File f = File(file.file);
          f.delete();
        }
        await DatabaseHelper.instance.delete(list[index]);
        list.removeAt(index);
        setState(() {});
        break;
    }
  }
}
