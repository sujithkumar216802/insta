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
  List<History> _list = [];
  bool _initialLoading = true;
  bool _permissionGiven = false;

  int _length = 0;
  int _pageSize;
  double _maxScrollExtent = 0;

  _HistoryViewState() {
    DatabaseHelper.instance.getAllHistory().then((value) {
      _list = value.reversed.toList();
      _pageSize = (MediaQuery.of(context).size.height ~/
                  MediaQuery.of(context).size.width) *
              5 +
          3;
      _length = _list.length > _pageSize ? _pageSize : _list.length;
      checkPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("InstaSave"),
        elevation: 10,
      ),
      body: SafeArea(
        child: _initialLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _list.length == 0
                ? Center(
                    child: Text(
                      "Nothing to show here",
                      style: Theme.of(context).textTheme.headline3,
                    ),
                  )
                : _permissionGiven
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        child: NotificationListener<ScrollNotification>(
                          onNotification: (ScrollNotification info) {
                            if ((_maxScrollExtent !=
                                    info.metrics.maxScrollExtent) &&
                                ((info.metrics.pixels +
                                        MediaQuery.of(context).size.height) >=
                                    info.metrics.maxScrollExtent) &&
                                (_list.length != _length)) {
                              _maxScrollExtent = info.metrics.maxScrollExtent;
                              _length = _length + _pageSize > _list.length
                                  ? _list.length
                                  : _length + _pageSize;
                              setState(() {});
                            }
                            return true;
                          },
                          child: ListView.builder(
                              cacheExtent:
                                  (MediaQuery.of(context).size.width * 6 / 5) *
                                      (_length + 5),
                              itemCount: _length,
                              itemBuilder: (BuildContext context, int index) {
                                return HistoryTemplate(
                                    key: ValueKey(_list[index].url),
                                    history: _list[index],
                                    index: index,
                                    function: popUpMenuFunction);
                              }),
                        ),
                      )
                    : Center(
                        child: Text(
                          "Permission Not given",
                          style: Theme.of(context).textTheme.headline3,
                        ),
                      ),
        bottom: true,
        top: true,
        left: true,
        right: true,
      ),
      drawer: MyDrawer(),
    );
  }

  void popUpMenuFunction(String value, int index) async {
    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }

    Map check = await checkAllFiles(_list[index]);
    PostAvailability postAvailability = check['post_availability'];
    List<String> availableFiles = check['available_files_uri'];
    List<FileInfo> notAvailableFilesInfo = check['not_available_files_info'];
    List<int> notAvailableIndexes = check['not_available_indexes'];

    switch (value) {
      case 'url':
        await canLaunch(_list[index].url)
            ? launch(_list[index].url)
            : throw 'Could not launch ${_list[index].url}';
        break;
      case 'share':
        if (postAvailability != PostAvailability.NONE)
          shareFiles(availableFiles);
        break;
      case 'caption':
        Clipboard.setData(ClipboardData(text: _list[index].description));
        break;
      case 'delete':
        if (await getSdk() < 29 && !(await getDownloadPermission())) {
          responseHelper(context, Status.PERMISSION_NOT_GRANTED);
          return;
        }
        deleteFiles(availableFiles);

        //fire and forget
        DatabaseHelper.instance.delete(_list[index]);
        _list.removeAt(index);
        _length -= 1;
        // update history
        setState(() {});
        break;
      case 'download':
        showDownloadingDialogue(context);
        var status = await updateHistory(
            notAvailableFilesInfo, _list[index].url, notAvailableIndexes);
        Navigator.pop(context);
        responseHelper(context, status, callback: () {
          popUpMenuFunction(value, index);
        });

        //fire and forget
        DatabaseHelper.instance.update(_list[index]);
        // update history
        setState(() {});
        break;
    }
  }

  void checkPermission() async {
    if (await getSdk() > 29 || await getDownloadPermission())
      _permissionGiven = true;
    _initialLoading = false;
    setState(() {});
  }
}
