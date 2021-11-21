import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/ui/widget/pop_up_menu.dart';
import 'package:insta_downloader/ui/widget/video_player.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';

import '../../models/history_model.dart';
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
  _HistoryTemplateState(this.history, this.index, this.function) {
    init();
  }

  final History history;
  final int index;
  final function;
  PostAvailability postAvailability;
  List<int> indexes;
  List<Widget> showWidgets = [];
  List<String> cache = [];

  bool showFiles = false;
  bool filesLoaded = false;
  bool disposeBool = false;

  //for updating history by downloading missing files
  @override
  void didUpdateWidget(HistoryTemplate oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  void init() async {
    var value = await checkAllFiles(history);
    postAvailability = value['post_availability'];
    indexes = value['available_indexes'];
    filesLoaded = false;
    setState(() {});
    //show();
  }

  @override
  Widget build(BuildContext context) {
    if (showFiles && !filesLoaded) show();

    if (postAvailability != null)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                      callbackFunction: function,
                      index: index,
                      postAvailability: postAvailability,
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
              (showFiles && filesLoaded)
                  ? showWidgets.length > 0
                      ? AspectRatio(
                          aspectRatio: history.ratio,
                          child: PageView(
                            pageSnapping: true,
                            children: showWidgets,
                          ),
                        )
                      : Container(
                          child: Text(
                            "Nothing to show here",
                            style: TextStyle(fontSize: 20),
                          ),
                        )
                  : (!showFiles)
                      ? Container()
                      : Center(child: CircularProgressIndicator(),)
            ],
          ),
        ),
      );
    else
      return Container();
  }

  show() async {
    showWidgets = [];

    //checking before showing just to be safe (overkill)
    var value = await checkAllFiles(history);
    postAvailability = value['post_availability'];
    indexes = value['available_indexes'];

    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }
    for (int i in indexes) {
      Uint8List list = await getFile(history.files[i].uri);

      if (history.files[i].fileType == FileType.VIDEO) {
        //caching video file
        // TODO if none show up
        String path = await getPath();
        cache.add(path + history.files[i].name);
        File cacheFile = File(path + history.files[i].name);
        await cacheFile.writeAsBytes(list);
        showWidgets.add(VideoPlayerWidget(
            video: cacheFile, function: popUpMenuFunction, index: i));
      } else
        showWidgets.add(
            ImageWidget(list: list, function: popUpMenuFunction, index: i));
    }
    filesLoaded = true;
    if (!disposeBool) setState(() {});
  }

  void popUpMenuFunction(String value, int index) async {
    switch (value) {
      case 'share':
        shareFiles([history.files[index].uri]);
        break;
      case 'delete':
        if (await getSdk() < 29 && !(await getDownloadPermission())) {
          responseHelper(context, Status.PERMISSION_NOT_GRANTED);
          return;
        }
        await deleteFile(history.files[index].uri);
        init();
        break;
    }
  }

  @override
  void dispose() {
    disposeBool = true;
    for (String i in cache) {
      File cacheFile = File(i);
      if (cacheFile.existsSync()) {
        //just starts deleting no need to be sync
        cacheFile.delete();
      }
    }
    cache = [];
    super.dispose();
  }
}
