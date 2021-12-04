import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/ui/widget/drawer.dart';
import 'package:insta_downloader/ui/widget/history_template.dart';
import 'package:insta_downloader/utils/dialogue_helper.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/history_model.dart';
import '../../utils/database_helper.dart';
import '../../utils/file_checker.dart';

class HistoryView extends StatefulWidget {
  static const String routeName = '/history';

  const HistoryView({Key key}) : super(key: key);

  @override
  _HistoryViewState createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  List<History> list = [];
  bool initialLoading = true;

  // int length = 0;
  // int pageSize;

  _HistoryViewState() {
    DatabaseHelper.instance.getAllHistory().then((value) {
      list = value.reversed.toList();
      // pageSize = (MediaQuery.of(context).size.height ~/
      //         MediaQuery.of(context).size.width) *
      //     5 + 3;
      // length = list.length > pageSize ? pageSize : list.length;
      initialLoading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(140, 255, 255, 255),
        title: Text("InstaSave", style: TextStyle(color: Colors.black)),
        elevation: 10,
      ),
      body: list.length == 0
          ? Container(
              child: Center(
                child: (initialLoading)
                    ? CircularProgressIndicator()
                    : Text(
                        "Nothing to show here",
                        style: TextStyle(fontSize: 32),
                      ),
              ),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                  cacheExtent: (MediaQuery.of(context).size.width * 6 / 5) *
                      (list.length + 5),
                  itemCount: list.length,
                  itemBuilder: (BuildContext context, int index) {
                    return HistoryTemplate(
                        key: ValueKey(list[index].url),
                        history: list[index],
                        index: index,
                        function: popUpMenuFunction);
                  }),
            ),
      drawer: MyDrawer(),
    );
    // return length == 0
    //     ? Container(
    //         child: Center(
    //           child: (initialLoading)
    //               ? CircularProgressIndicator()
    //               : Text(
    //                   "Nothing to show here",
    //                   style: TextStyle(fontSize: 32),
    //                 ),
    //         ),
    //       )
    //     : Container(
    //         width: MediaQuery.of(context).size.width,
    //         child: NotificationListener<ScrollNotification>(
    //           onNotification: (ScrollNotification info) {
    //             if (info.metrics.pixels + MediaQuery.of(context).size.height >= info.metrics.maxScrollExtent &&
    //                 list.length != length) {
    //               length = length + pageSize > list.length
    //                   ? list.length
    //                   : length + pageSize;
    //               setState(() {});
    //             }
    //             return true;
    //           },
    //           child: ListView.builder(
    //               cacheExtent: (MediaQuery.of(context).size.width * 6 / 5) *
    //                   (length + 5),
    //               itemCount: length,
    //               itemBuilder: (BuildContext context, int index) {
    //                 return HistoryTemplate(
    //                     key: ValueKey(list[index].url),
    //                     history: list[index],
    //                     index: index,
    //                     function: popUpMenuFunction);
    //               }),
    //         ),
    //       );
  }

  void popUpMenuFunction(String value, int index) async {
    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }
    Map check = await checkAllFiles(list[index]);
    PostAvailability postAvailability = check['post_availability'];
    List<String> availableFiles = check['available_files_uri'];
    List<FileInfo> notAvailableFilesInfo = check['not_available_files_info'];
    List<int> notAvailableIndexes = check['not_available_indexes'];

    switch (value) {
      case 'url':
        await canLaunch(list[index].url)
            ? launch(list[index].url)
            : throw 'Could not launch ${list[index].url}';
        break;
      case 'share':
        if (postAvailability != PostAvailability.NONE)
          shareFiles(availableFiles);
        break;
      case 'caption':
        Clipboard.setData(ClipboardData(text: list[index].description));
        break;
      case 'delete':
        if (await getSdk() < 29 && !(await getDownloadPermission())) {
          responseHelper(context, Status.PERMISSION_NOT_GRANTED);
          return;
        }
        deleteFiles(availableFiles);
        //fire and forget
        DatabaseHelper.instance.delete(list[index]);
        list.removeAt(index);
        // update history
        setState(() {});
        break;
      case 'download':
        showDownloadingDialogue(context);
        var status = await updateHistory(
            notAvailableFilesInfo, list[index].url, notAvailableIndexes);
        Navigator.pop(context);
        responseHelper(context, status);

        //update history in db
        //fire and forget
        DatabaseHelper.instance.update(list[index]);
        // update history
        setState(() {});
        break;
    }
  }
}
