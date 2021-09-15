import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

class Downloader {
  static const uuid = Uuid();

  static downloadFile(var values, String postUrl) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dir = appDocDir.path;

    File file;

    //post download
    var urls = values["links"];
    for (FileInfo url in urls) {
      var response = await http.get(Uri.parse(url.url));
      if (url.type == 2)
        file = new File('$dir/' + uuid.v1() + '.mp4');
      else
        file = new File('$dir/' + uuid.v1() + '.jpg');
      await file.writeAsBytes(response.bodyBytes);
      url.file = file.path;
    }

    var thumbnail = await http.get(Uri.parse(values["thumbnail_url"]));

    //account photo
    var accountPhoto = await http.get(Uri.parse(values["account_pic_url"]));

    //insert into db
    await DatabaseHelper.instance.insert(History(
        postUrl,
        thumbnail.bodyBytes,
        accountPhoto.bodyBytes,
        values['links'],
        values['description'],
        values['account_tag'],
        values['ratio']));
  }

  static getDetails(String url) async {
    try {
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await downloadFile(Extractor.extract(response.body), url);
        return;
      } else {
        return null;
      }
    } catch (ex) {
      return null;
    }
  }
}
