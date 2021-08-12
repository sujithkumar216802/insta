import 'package:http/http.dart' as http;
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';

import '../models/history_model.dart';

class Downloader {

  static downloadFile(var values, String postUrl) async {

    //post download
    List<String> links = values["links"];
    List<int> type = values["type"];
    List<FileInfo> fileInfos = [];

    for (int i=0;i<links.length;i++) {
      var response = await http.get(Uri.parse(links[i]));
      fileInfos.add(FileInfo(type[i], response.bodyBytes));
    }

    //thumbnail
    var response = await http.get(Uri.parse(values["thumbnail_url"]));

    //insert into db
    await DatabaseHelper.instance.insert(History(postUrl, response.bodyBytes,
        fileInfos, values['description'], values['account_tag']));
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
