import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:insta_downloader/ui/pop_up_menu.dart';
import 'package:insta_downloader/ui/video_player.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:share_plus/share_plus.dart';

import '../models/history_model.dart';
import 'imageWidget.dart';

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
    Map temp = checkAllFiles(history);
    int type = temp['type'];
    List<int> indexes = temp['available_indexes'];

    return ListTile(
      title: Container(
        margin: EdgeInsets.fromLTRB(
            0, 0, 0, MediaQuery.of(context).size.width / 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                    flex: 6,
                    fit: FlexFit.tight,
                    child: Image.memory(
                      history.thumbnail,
                      width: MediaQuery.of(context).size.width / 5,
                      height: MediaQuery.of(context).size.width / 5,
                    )),
                Flexible(
                    flex: 21,
                    fit: FlexFit.tight,
                    child: Container(
                      height: MediaQuery.of(context).size.width / 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                              flex: 2,
                              child: Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: MemoryImage(
                                                  history.accountPhoto))),
                                    ),
                                    Text(' ' + history.tag,
                                        overflow: TextOverflow.ellipsis)
                                  ],
                                ),
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width / 50,
                                    MediaQuery.of(context).size.width / 50,
                                    0,
                                    0),
                              )),
                          Flexible(
                              flex: 4,
                              child: Container(
                                child: Text(history.description,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false),
                                padding: EdgeInsets.fromLTRB(
                                    MediaQuery.of(context).size.width / 100,
                                    MediaQuery.of(context).size.width / 100,
                                    0,
                                    MediaQuery.of(context).size.width / 100),
                              ))
                        ],
                      ),
                    )),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: TripleDot(
                    function: function,
                    index: index,
                    type: type,
                  ),
                )
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showFiles = !showFiles;
                });
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (showFiles)
                      ? Icon(
                          Icons.arrow_drop_up_outlined,
                          size: 24,
                        )
                      : Icon(
                          Icons.arrow_drop_down_outlined,
                          size: 24,
                        ),
                  Text("Show Posts")
                ],
              ),
            ),
            (showFiles)
                ? AspectRatio(
                    aspectRatio: history.ratio,
                    child: PageView(
                      pageSnapping: true,
                      children: indexes.map((e) => show(e)).toList(),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget show(int index) {
    File file = new File(history.files[index].file);

    if (history.files[index].type == 2)
      return VideoPlayerWidget(
          video: file, function: popUpMenuFunction, index: index);
    else
      return ImageWidget(file: file, function: popUpMenuFunction, index: index);
  }

  void popUpMenuFunction(String value, int index) async {
    switch (value) {
      case 'share':
        await Share.shareFiles([history.files[index].file]);
        break;
    }
  }
}
