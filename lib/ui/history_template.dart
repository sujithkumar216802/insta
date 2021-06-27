import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/pop_up_menu.dart';
import 'package:insta_downloader/utils/file_checker.dart';

import '../models/history_model.dart';

class HistoryTemplate extends StatelessWidget {
  const HistoryTemplate(
      {Key key,
      @required this.history,
      @required this.index,
      @required this.function})
      : super(key: key);
  final History history;
  final int index;
  final function;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Container(
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width / 5,
        child: Row(
          children: [
            Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                    width: MediaQuery.of(context).size.width / 5,
                    height: MediaQuery.of(context).size.width / 5,
                    child: Image.memory(history.thumbnail))),
            Flexible(
                flex: 4,
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(history.tag, overflow: TextOverflow.ellipsis),
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 50,
                          MediaQuery.of(context).size.width / 50,
                          0,
                          5),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.width * 8 / 50 - 16,
                      child: Text(history.description,
                          overflow: TextOverflow.ellipsis, softWrap: false),
                      padding: EdgeInsets.fromLTRB(
                          MediaQuery.of(context).size.width / 50,
                          MediaQuery.of(context).size.width / 50,
                          0,
                          5),
                    )
                  ],
                )),
          ],
        ),
      ),
      trailing: TripleDot(
        function: function,
        index: index,
        type: FileChecker.checkAllFiles(history),
      ),
    );
  }
}
