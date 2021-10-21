import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
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

  //TODO Optimise
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

  void popUpMenuFunction(String value, int index) async {
    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }
    Map check = await checkAllFiles(list[index]);
    PostAvailability postAvailability = check['post_availability'];
    List<String> availableFiles = check['available_files_uri'];
    List<FileInfo> notAvailableFilesInfo = check['not_available_files_info'];

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
        showDialogueWithLoadingBar(context, 'Downloading');
        var status = await updateHistory(notAvailableFilesInfo);
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
