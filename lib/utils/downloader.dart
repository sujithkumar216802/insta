import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/path_provider_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

class Downloader {
  static const uuid = Uuid();

  static downloadFile(var values, String postUrl) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String dir = prefs.getString('download_location') ??
        await PathProviderUtil.getDownloadPath();

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
      url.isAvailable = true;
    }

    //thumbnail
    var response = await http.get(Uri.parse(values["thumbnail_url"]));

    //insert into db
    await DatabaseHelper.instance.insert(History(postUrl, response.bodyBytes,
        values['links'], true, values['description'], values['account_tag']));
  }

  static updateHistory(History history) async {
    File file;

    //post download
    for (FileInfo url in history.files) {
      if (!url.isAvailable) {
        var response = await http.get(Uri.parse(url.url));
        file = new File(url.file);
        await file.writeAsBytes(response.bodyBytes);
        url.isAvailable = true;
      }
    }

    //update db
    await DatabaseHelper.instance.update(history);
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
