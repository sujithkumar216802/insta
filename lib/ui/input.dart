import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/models/history_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/downloader.dart';
import 'package:insta_downloader/utils/file_checker.dart';

class Input extends StatelessWidget {
  final UrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

    //check url TODO
    if (url == "https://www.instagram.com/reel/" ||
        url == "https://www.instagram.com/p/" ||
        url == "https://www.instagram.com/tv/" ||
        (!url.startsWith("https://www.instagram.com/tv/") &&
            !url.startsWith("https://www.instagram.com/p/") &&
            !url.startsWith("https://www.instagram.com/reel/")) ||
        url.startsWith("https://www.instagram.com/stories")) {
      //show dialog
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('Invalid Link'),
                content: Text('The link is fked up my dude'),
              ));
      return;
    }

    //check duplicates
    List<String> urlList = await DatabaseHelper.instance.getUrls();
    for (String x in urlList) {
      if (x.contains(url)) {
        //getting the history
        History history = await DatabaseHelper.instance.getHistory(x);

        Map temp = await checkAllFiles(history);
        int type = temp['type'];
        List<FileInfo> notAvailable = temp['not_available'];

        if (type == 0) {
          //show dialog
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    title: Text('Already Downloaded'),
                    content: Text('Check History'),
                  ));
          return;
        } else {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (_) => AlertDialog(
                  title: Text('Downloading'),
                  content: Align(
                    child: Container(
                        child: CircularProgressIndicator(),
                        padding: EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.width / 5),
                    alignment: Alignment.center,
                    heightFactor: 1,
                  )));
          await updateHistory(notAvailable);
          Navigator.pop(context);
          return;
        }
      }
    }
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
            title: Text('Downloading'),
            content: Align(
              child: Container(
                  child: CircularProgressIndicator(),
                  padding: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width / 5,
                  height: MediaQuery.of(context).size.width / 5),
              alignment: Alignment.center,
              heightFactor: 1,
            )));
    await getDetails(url);
    Navigator.pop(context);
  }

  void paste() {
    Clipboard.getData(Clipboard.kTextPlain)
        .then((value) => UrlController.text = value.text);
  }
}
