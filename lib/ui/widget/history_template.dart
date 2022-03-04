import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
  _HistoryTemplateState createState() => _HistoryTemplateState();
}

class _HistoryTemplateState extends State<HistoryTemplate> {
  @override
  void initState() {
    super.initState();
    init();
  }

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
    var value = await checkAllFiles(widget.history);
    postAvailability = value['post_availability'];
    indexes = value['available_indexes'];
    filesLoaded = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (showFiles && !filesLoaded) show();

    if (postAvailability != null)
      return Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
            borderRadius: BorderRadius.all(
                Radius.circular(MediaQuery.of(context).size.width / 25))),
        child: Column(
          children: [
            ListTile(
              leading: Image.memory(widget.history.thumbnail),
              trailing: TripleDot(
                callbackFunction: widget.function,
                index: widget.index,
                postAvailability: postAvailability,
              ),
              subtitle: Text(
                widget.history.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              isThreeLine: true,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: MemoryImage(widget.history.accountPhoto))),
                  ),
                  Text('  ' + widget.history.tag,
                      overflow: TextOverflow.ellipsis)
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showFiles = !showFiles;
                });
              },
              child: Container(
                color: Theme.of(context).colorScheme.secondary,
                padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Row(
                  children: [
                    (showFiles)
                        ? Icon(
                            Icons.arrow_drop_up_outlined,
                            size: 30,
                            color: Theme.of(context).primaryIconTheme.color,
                          )
                        : Icon(
                            Icons.arrow_drop_down_outlined,
                            size: 30,
                            color: Theme.of(context).primaryIconTheme.color,
                          ),
                    Text(
                      "Show Posts",
                      style: Theme.of(context).primaryTextTheme.bodyText1,
                    )
                  ],
                ),
              ),
            ),
            (showFiles && filesLoaded)
                ? showWidgets.length > 0
                    ? AspectRatio(
                        aspectRatio: widget.history.ratio,
                        child: PageView.builder(
                          pageSnapping: true,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                showWidgets[index],
                                Container(
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  padding: EdgeInsets.all(5),
                                  margin: EdgeInsets.all(5),
                                  child: Text(
                                    '${index + 1}/${showWidgets.length}',
                                  ),
                                )
                              ],
                            );
                          },
                          itemCount: showWidgets.length,
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
                    : Center(
                        child: CircularProgressIndicator(),
                      )
          ],
        ),
        margin: EdgeInsets.fromLTRB(
            0, 0, 0, MediaQuery.of(context).size.width / 25),
      );
    else
      return Container(
        child: CircularProgressIndicator(),
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width / 5,
        height: MediaQuery.of(context).size.width / 5,
      );
  }

  show() async {
    showWidgets = [];

    //checking before showing just to be safe (overkill)
    var value = await checkAllFiles(widget.history);
    postAvailability = value['post_availability'];
    indexes = value['available_indexes'];

    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      // responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }

    for (int i in indexes) {
      Uint8List list = await getFile(widget.history.files[i].uri);

      if (widget.history.files[i].fileType == FileType.VIDEO) {
        //caching video file
        String path = await getPath();
        cache.add(path + widget.history.files[i].name);
        File cacheFile = File(path + widget.history.files[i].name);
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
        shareFiles([widget.history.files[index].uri]);
        break;
      case 'delete':
        if (await getSdk() < 29 && !(await getDownloadPermission())) {
          responseHelper(context, Status.PERMISSION_NOT_GRANTED);
          return;
        }
        await deleteFile(widget.history.files[index].uri);
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
