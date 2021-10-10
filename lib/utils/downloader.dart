import 'package:http/http.dart' as http;
import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

const uuid = Uuid();

downloadFile(var values, String postUrl) async {
  //post download
  var urls = values["links"];
  for (FileInfo url in urls) {
    var response = await http.get(Uri.parse(url.url));
    var name = uuid.v1();
    if (url.fileType == FileType.VIDEO)
      url.uri =
          await saveFile(response.bodyBytes, name, FileType.VIDEO.toInt());
    else
      url.uri =
          await saveFile(response.bodyBytes, name, FileType.IMAGE.toInt());
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
  //post download
  for (FileInfo url in list) {
    try {
      var response = await http.get(Uri.parse(url.url));
      if (url.fileType == FileType.VIDEO)
        url.uri = await saveFile(
            response.bodyBytes, url.name, FileType.VIDEO.toInt());
      else
        url.uri = await saveFile(
            response.bodyBytes, url.name, FileType.IMAGE.toInt());
    } catch (ex) {
      // post deleted or the account went private
      return Status.FAILURE;
    }
  }

  return Status.SUCCESS;
}

getDetails(String url) async {
  try {
    var response = await http.get(Uri.parse(url));

    switch (response.statusCode) {
      case 200:
        var extractedInfo = extract(response.body);

        if (extractedInfo != Status.PRIVATE) {
          try {
            await downloadFile(extractedInfo, url);
          } catch (ex) {
            return Status.FAILURE;
          }
        } else {
          return extractedInfo;
        }

        return Status.SUCCESS;
        break;
      case 404:
        return Status.NOT_FOUND;
        break;
    }
  } catch (ex) {
    return Status.NO_INTERNET;
  }
}
