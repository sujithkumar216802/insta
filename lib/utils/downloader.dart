import 'package:http/http.dart' as http;
import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/utils/database_helper.dart';
import 'package:insta_downloader/utils/extractor.dart';
import 'package:insta_downloader/utils/method_channel.dart';
import 'package:insta_downloader/utils/permission.dart';
import 'package:insta_downloader/utils/web_view.dart';
import 'package:uuid/uuid.dart';

import '../models/history_model.dart';

const uuid = Uuid();

getDetailsPost(String url, {bool update = false}) async {
  await WebViewHelper.loadUrl(url);

  String html = await WebViewHelper.controller.getHtml();

  var valuesDict = extract(html, p: Uri.parse(url).path);
  if (valuesDict is Status) return valuesDict;
  return await downloadAndSaveFiles(valuesDict, url, update: update);
}

getDetailsStory(String url, {bool update = false}) async {
  String html, toLoad;
  var storyId;
  String linkStoryId = "";
  Uri uri = Uri.parse(url);
  bool fullHighlights = uri.pathSegments.contains('highlights');
  bool highlights = fullHighlights || uri.pathSegments.contains('s');

  //for stories and posts with single highlight(/s/)
  if (!fullHighlights) {
    await WebViewHelper.loadUrl(url);

    html = await WebViewHelper.controller.evaluateJavascript(
        source: "window.document.getElementsByTagName('html')[0].outerHTML;");

    storyId = highlights
        ? extract(html, highlightsId: true)
        : extract(html, storyId: true);
    if (storyId is Status) return storyId;
  } else {
    storyId = uri.pathSegments[2];
  }

  toLoad = highlights
      ? 'https://www.instagram.com/graphql/query/?query_hash=52a36e788a02a3c612742ed5146f1676&variables={"reel_ids":[],"stories_video_dash_manifest":false,"location_ids":[],"story_viewer_cursor":"","precomposed_overlay":false,"highlight_reel_ids":["$storyId"],"tag_names":[],"show_story_viewer_list":false}'
      : 'https://www.instagram.com/graphql/query/?query_hash=52a36e788a02a3c612742ed5146f1676&variables={"reel_ids":["$storyId"],"stories_video_dash_manifest":false,"location_ids":[],"story_viewer_cursor":"","precomposed_overlay":false,"highlight_reel_ids":[],"tag_names":[],"show_story_viewer_list":false}';

  await WebViewHelper.loadUrl(toLoad);

  html = await WebViewHelper.controller.evaluateJavascript(
      source: "window.document.getElementsByTagName('html')[0].outerHTML;");

  linkStoryId = uri.queryParameters['story_media_id'] ?? "";
  linkStoryId = linkStoryId != ""
      ? linkStoryId.substring(0, linkStoryId.indexOf('_'))
      : "";

  var valuesDict = highlights
      ? extract(html, storyDetails: true, linkStoryId: linkStoryId)
      : extract(html, storyDetails: true, linkStoryId: uri.pathSegments[2]);
  if (valuesDict is Status) return valuesDict;

  return await downloadAndSaveFiles(valuesDict, url, update: update);
}

updateHistory(List<FileInfo> list, String url, List<int> listIndexes) async {
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
    var status;
    if (Uri.parse(url).pathSegments.contains('stories') ||
        Uri.parse(url).pathSegments.contains('s')) {
      var temp = await WebViewHelper.isLoggedIn();
      if (temp is Status) return temp;

      if (temp)
        status = await getDetailsStory(url, update: true);
      else
        return Status.INACCESSIBLE;
    } else {
      status = await getDetailsPost(url, update: true);
    }

    if (status is Status)
      return status;
    else {
      for (int i = 0; i < listIndexes.length; i++) {
        list[i].url = status[listIndexes[i]].url;
        list[i].uri = status[listIndexes[i]].uri;
        list[i].name = status[listIndexes[i]].name;
      }
    }
  }

  return Status.SUCCESS;
}

downloadAndSaveFiles(var values, String postUrl, {bool update = false}) async {
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

  if (update) return values['links'];

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
