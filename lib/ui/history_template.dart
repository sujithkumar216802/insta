import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:insta_downloader/ui/pop_up_menu.dart';
import 'package:insta_downloader/ui/video_player.dart';

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
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.fromLTRB(0, MediaQuery.of(context).size.width / 25,
            0, MediaQuery.of(context).size.width / 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(
                  0, 0, 0, MediaQuery.of(context).size.width / 50),
              child: Row(
                children: [
                  Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Container(
                          width: MediaQuery.of(context).size.width / 5,
                          height: MediaQuery.of(context).size.width / 5,
                          child: Image.memory(history.thumbnail))),
                  Flexible(
                      flex: 11,
                      fit: FlexFit.tight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(history.tag,
                                overflow: TextOverflow.ellipsis),
                            padding: EdgeInsets.fromLTRB(
                                MediaQuery.of(context).size.width / 50,
                                MediaQuery.of(context).size.width / 50,
                                0,
                                MediaQuery.of(context).size.width / 50),
                          ),
                          Container(
                            // height:
                            //     MediaQuery.of(context).size.width * 8 / 50 - 16,
                            child: Text(history.description,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false),
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
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: history.files.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      width: MediaQuery.of(context).size.width / 1.1,
                      child: show(index),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  show(int index) {
    if (history.files[index].type == 2) {
      return VideoP(video: history.files[index].file);
    } else {
      return Image.memory(history.files[index].file);
    }
  }
}
