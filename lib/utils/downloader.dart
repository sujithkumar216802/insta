//TODO IMPROVEMENTS delete unnecessary files, make it readable.. just rewrite afterwards
import 'package:http/http.dart' as http;
import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

const uuid = Uuid();

downloadFile(var values, String postUrl, {bool update = false}) async {
  if (await getSdk() < 29 && !(await getDownloadPermission()))
    return Status.PERMISSION_NOT_GRANTED;

  //post download
  var urls = values["links"];
  for (FileInfo url in urls) {
    try {
      var response = await http.get(Uri.parse(url.url));
      var name = uuid.v1();
      if (url.fileType == FileType.VIDEO)
        url.uri =
            await saveFile(response.bodyBytes, name, FileType.VIDEO.toInt());
      else
        url.uri =
            await saveFile(response.bodyBytes, name, FileType.IMAGE.toInt());

      if (url.uri == "uri is null") return Status.ERROR_WHILE_SAVING_FILE;
      url.name = name;
    } catch (ex) {
      return Status.FAILURE;
    }
  }

  if (update) {
    return values['links'];
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

  return Status.SUCCESS;
}

updateHistory(List<FileInfo> list, String url, List<int> listIndexes) async {
  //post download
  bool expired = false;

  if (await getSdk() < 29 && !(await getDownloadPermission()))
    return Status.PERMISSION_NOT_GRANTED;

  for (FileInfo url in list) {
    try {
      var response = await http.get(Uri.parse(url.url));
      if (response.statusCode == 403) {
        expired = true;
        break;
      }
      if (url.fileType == FileType.VIDEO)
        url.uri = await saveFile(
            response.bodyBytes, url.name, FileType.VIDEO.toInt());
      else
        url.uri = await saveFile(
            response.bodyBytes, url.name, FileType.IMAGE.toInt());

      if (url.uri == "uri is null") return Status.ERROR_WHILE_SAVING_FILE;
    } catch (ex) {
      return Status.FAILURE;
    }
  }

  if (expired) {
    var ret = await getDetails(url, update: true);
    if (ret is Status) return ret;
    for (int i = 0; i < listIndexes.length; i++) {
      list[i].url = ret[listIndexes[i]].url;
      list[i].uri = ret[listIndexes[i]].uri;
      list[i].name = ret[listIndexes[i]].name;
    }
  }

  return Status.SUCCESS;
}

getDetails(String url, {bool update = false}) async {
  //TODO default return val
  try {
    var response = await http.get(Uri.parse(url));

    switch (response.statusCode) {
      case 200:
        var extractedInfo = extract(response.body);
        if (extractedInfo != Status.PRIVATE) {
          try {
            return await downloadFile(extractedInfo, url, update: update);
          } catch (ex) {
            return Status.FAILURE;
          }
        } else {
          return Status.PRIVATE;
        }
        break;
      case 404:
        return Status.NOT_FOUND;
        break;
      default:
        return Status.FAILURE;
    }
  } catch (ex) {
    return Status.NO_INTERNET;
  }
}
