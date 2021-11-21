import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/models/history_model.dart';
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
  final UrlController = TextEditingController();
  var valuesJsonDict = {};
  String html;
  BuildContext _context;

  Input({String share}) {
    if (share != null) UrlController.text = share;
  }

  @override
  Widget build(BuildContext context) {
    _context = context;

    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: EdgeInsets.fromLTRB(10, 20, 10, 20),
              width: MediaQuery.of(context).size.width - 20,
              child: TextField(
                controller: UrlController,
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
                    download(context);
                  },
                  child: Text("Download")),
              width: MediaQuery.of(context).size.width / 2 - 20,
            )
          ],
        )
      ],
    );
  }

  Future<void> download(BuildContext context) async {
    String url = UrlController.text;

    if (url == "https://www.instagram.com/reel/" ||
        url == "https://www.instagram.com/p/" ||
        url == "https://www.instagram.com/tv/" ||
        url == "https://www.instagram.com/stories/" ||
        (!url.startsWith("https://www.instagram.com/tv/") &&
            !url.startsWith("https://www.instagram.com/p/") &&
            !url.startsWith("https://www.instagram.com/reel/") &&
            !url.startsWith("https://www.instagram.com/stories/"))) {
      //show dialog
      showDialogueWithText(context, 'Invalid Link', 'The link is not valid');
      return;
    }

    if (await getSdk() < 29 && !(await getDownloadPermission())) {
      responseHelper(context, Status.PERMISSION_NOT_GRANTED);
      return;
    }

    //check duplicates
    List<String> urlList = await DatabaseHelper.instance.getUrls();
    for (String x in urlList) {
      if (x.contains(url)) {
        //getting the history
        History history = await DatabaseHelper.instance.getHistory(x);

        Map check = await checkAllFiles(history);
        PostAvailability postAvailability = check['post_availability'];
        List<FileInfo> notAvailableFilesInfo =
            check['not_available_files_info'];
        List<int> notAvailableIndexes = check['not_available_indexes'];

        if (postAvailability == PostAvailability.ALL) {
          //show dialog
          showDialogueWithText(context, 'Already Downloaded', 'Check History');
          return;
        } else {
          showDialogueWithLoadingBar(context, 'Downloading');
          var status = await updateHistory(
              notAvailableFilesInfo, history.url, notAvailableIndexes);
          Navigator.pop(context);
          responseHelper(context, status);

          //update history in db
          //fire and forget
          DatabaseHelper.instance.update(history);
          return;
        }
      }
    }
    showDialogueWithLoadingBar(context, 'Downloading');

    if (url.startsWith("https://www.instagram.com/stories/")) {
      if (await WebViewHelper.isLoggedIn()) {
        var status = await getDetailsStory(url);
        Navigator.pop(context);
        responseHelper(context, status);
      } else {
        login();
      }
    } else {
      var status = await getDetails(url);
      if (status == Status.PRIVATE) {
        if (await WebViewHelper.isLoggedIn()) {
          status = await getDetailsPrivate(url);
          Navigator.pop(context);
          responseHelper(context, status);
        } else {
          login();
        }
      } else {
        Navigator.pop(context);
        responseHelper(context, status);
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
                  if (extract(await controller.getHtml(), checkLogin: true)) {
                    loginCompleted();
                    Navigator.pop(_context);
                  }
                },
              ),
            ));
  }

  void paste() {
    Clipboard.getData(Clipboard.kTextPlain)
        .then((value) => UrlController.text = value.text);
  }

  loginCompleted() async {
    var status;
    if (UrlController.text.startsWith("https://www.instagram.com/stories/"))
      status = await getDetailsStory(UrlController.text);
    else
      status = await getDetailsPrivate(UrlController.text);

    Navigator.pop(_context);
    responseHelper(_context, status);
  }
}
