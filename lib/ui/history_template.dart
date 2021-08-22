import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:insta_downloader/ui/pop_up_menu.dart';
import 'package:insta_downloader/ui/video_player.dart';
import 'package:insta_downloader/utils/file_checker.dart';

import '../models/history_model.dart';

class HistoryTemplate extends StatefulWidget {
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
  _HistoryTemplateState createState() =>
      _HistoryTemplateState(history, index, function);
}

class _HistoryTemplateState extends State<HistoryTemplate> {
  _HistoryTemplateState(this.history, this.index, this.function);

  final History history;
  final int index;
  final function;

  bool showFiles = false;

  @override
  Widget build(BuildContext context) {
    Map temp = FileChecker.checkAllFiles(history);
    int type = temp['type'];
    List<int> indexes = temp['available_indexes'];

    return ListTile(
      title: Container(
        margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.width / 25,
            0, MediaQuery.of(context).size.width / 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                    flex: 3,
                    fit: FlexFit.tight,
                    child: Image.memory(
                      history.thumbnail,
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 5,
                    )),
                Flexible(
                    flex: 11,
                    fit: FlexFit.tight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.memory(history.accountPhoto,
                                  height: 18, width: 18),
                              Text(' ' + history.tag,
                                  overflow: TextOverflow.ellipsis)
                            ],
                          ),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 50,
                              MediaQuery.of(context).size.width / 50,
                              0,
                              MediaQuery.of(context).size.width / 50),
                        ),
                        Container(
                          child: Text(history.description,
                              overflow: TextOverflow.ellipsis, softWrap: false),
                          padding: EdgeInsets.fromLTRB(
                              MediaQuery.of(context).size.width / 50,
                              MediaQuery.of(context).size.width / 50,
                              0,
                              MediaQuery.of(context).size.width / 50),
                        )
                      ],
                    )),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: TripleDot(
                    function: function,
                    index: index,
                    type: type,
                  ),
                )
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showFiles = !showFiles;
                    });
                  },
                  child: (showFiles)
                      ? Icon(Icons.arrow_drop_up_outlined)
                      : Icon(Icons.arrow_drop_down_outlined),
                ),
                Text("POSTS AHAHAHAHA")
              ],
            ),
            (showFiles)
                ? Container(
                    height: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: indexes.length,
                        itemBuilder: (BuildContext context, int index) {
                          return show(indexes[index]);
                        }),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  show(int index) {
    File file = new File(history.files[index].file);

    if (history.files[index].type == 2)
      return VideoPlayerWidget(video: file);
    else
      return Image.file(file);
  }
}
