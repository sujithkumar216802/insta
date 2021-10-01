import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

const uuid = Uuid();

downloadFile(var values, String postUrl) async {

  //post download
  var urls = values["links"];
  for (FileInfo url in urls) {
    var response = await http.get(Uri.parse(url.url));
    var name = uuid.v1();
    if (url.type == 2)
      url.file = await saveFile(response.bodyBytes, name, 2);
    else
      url.file = await saveFile(response.bodyBytes, name, 1);
    url.name = name;
  }

  //thumbnail
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

updateHistory(List<FileInfo> list) async {
  File file;

  //post download
  for (FileInfo url in list) {
    var response = await http.get(Uri.parse(url.url));
    file = new File(url.file);
    await file.writeAsBytes(response.bodyBytes);
  }
}

getDetails(String url) async {
  try {
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      await downloadFile(extract(response.body), url);
      return;
    } else {
      return null;
    }
  } catch (ex) {
    return null;
  }
}
