import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/models/history_model.dart';
import 'package:insta_downloader/ui/widget/drawer.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/dialogue_helper.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/file_checker.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';
import 'package:insta_downloader/utils/web_view.dart';

class Input extends StatelessWidget {
  static const String routeName = '/input';

  final _UrlController = TextEditingController();
  String _url;
  Uri _uri;
  BuildContext _context;

  Input({String share}) {
    if (share != null) _UrlController.text = share;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(140, 255, 255, 255),
        title: Text("InstaSave", style: TextStyle(color: Colors.black)),
        elevation: 10,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
                width: MediaQuery.of(context).size.width - 20,
                child: TextField(
                  controller: _UrlController,
                  decoration: InputDecoration(
                    hintText: 'Paste URL here',
                    border: OutlineInputBorder(),
                  ),
                ),
              )
            ],
          ),
          Row(
            children: [
              Container(
                height: 48,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(onPressed: paste, child: Text("Paste")),
                width: MediaQuery.of(context).size.width / 2 - 20,
              ),
              Container(
                height: 48,
                margin: EdgeInsets.all(10),
                child: ElevatedButton(
                    onPressed: () {
                      download();
                    },
                    child: Text("Download")),
                width: MediaQuery.of(context).size.width / 2 - 20,
              )
            ],
          )
        ],
      ),
      drawer: MyDrawer(),
    );
  }

  Future<void> download() async {
    try {
      _uri = Uri.parse(_UrlController.text);
    } catch (e) {
      showDialogueWithText(_context, 'Invalid Link', 'The link is not valid');
      return;
    }

    if (_uri.pathSegments.contains('stories') ||
        _uri.pathSegments.contains('s') ||
        _uri.pathSegments.contains('p') ||
        _uri.pathSegments.contains('tv') ||
        _uri.pathSegments.contains('reel')) {
      _url = 'https://www.instagram.com' + _uri.path;
      if (_uri.queryParameters.containsKey('story_media_id') &&
          _uri.pathSegments.contains('s'))
        _url += '?story_media_id=' + _uri.queryParameters['story_media_id'];
    } else {
      showDialogueWithText(_context, 'Invalid Link', 'The link is not valid');
      return;
    }

    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(_context, Status.PERMISSION_NOT_GRANTED);
      return;
    }

    //check duplicates
    List<String> urlList = await DatabaseHelper.instance.getUrls();
    for (String x in urlList) {
      if (x.contains(_url)) {
        //getting the history
        History history = await DatabaseHelper.instance.getHistory(x);

        Map check = await checkAllFiles(history);
        PostAvailability postAvailability = check['post_availability'];
        List<FileInfo> notAvailableFilesInfo =
            check['not_available_files_info'];
        List<int> notAvailableIndexes = check['not_available_indexes'];

        if (postAvailability == PostAvailability.ALL) {
          //show dialog
          showDialogueWithText(_context, 'Already Downloaded', 'Check History');
          return;
        } else {
          showDownloadingDialogue(_context);
          var status = await updateHistory(
              notAvailableFilesInfo, history.url, notAvailableIndexes);
          Navigator.pop(_context);
          responseHelper(_context, status);

          //update history in db
          //fire and forget
          DatabaseHelper.instance.update(history);
          return;
        }
      }
    }
    showDownloadingDialogue(_context);

    var status;
    if (_uri.pathSegments.contains('stories') ||
        _uri.pathSegments.contains('s')) {
      var temp = await WebViewHelper.isLoggedIn();
      if (temp is Status) {
        Navigator.pop(_context);
        responseHelper(_context, temp);
        return;
      }
      if (temp) {
        status = await getDetailsStory(_url);
        Navigator.pop(_context);
        responseHelper(_context, status);
      } else {
        Navigator.pop(_context);
        login();
      }
    } else {
      status = await getDetailsPost(_url);
      if (status == Status.INACCESSIBLE) {
        Navigator.pop(_context);
        login();
      } else {
        Navigator.pop(_context);
        responseHelper(_context, status);
      }
    }
  }

  login() async {
    //TODO ask the user
    showDialog(
        barrierDismissible: false,
        context: _context,
        builder: (_) => AlertDialog(
              content: InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://www.instagram.com/")),
                onLoadStop: (controller, url) async {
                  var value =
                      extract(await controller.getHtml(), checkLogin: true);
                  if (!(value is Status) && value) {
                    loginCompleted();
                  }
                },
              ),
            ));
  }

  void paste() {
    Clipboard.getData(Clipboard.kTextPlain)
        .then((value) => _UrlController.text = value.text);
  }

  loginCompleted() async {
    Navigator.pop(_context);
    showDownloadingDialogue(_context);

    var status;
    if (_uri.pathSegments.contains('stories') ||
        _uri.pathSegments.contains('s'))
      status = await getDetailsStory(_UrlController.text);
    else
      status = await getDetailsPost(_UrlController.text);

    Navigator.pop(_context);
    responseHelper(_context, status);
  }
}
