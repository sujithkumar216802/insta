import 'dart:convert';

import 'package:insta_downloader/models/file_info_model.dart';

class Extractor {
  static const jsonHeader = 'window._sharedData = ';

  static const jsonFooter = ';</script>';

  //extractor
  static extract(String html) {
    List<FileInfo> links = [];
    String descriptionString = "";
    String thumbnailUrl = "";
    String accountName = "";
    String accountPhotoUrl = "";
    int jsonHeaderIndex = 0;
    int jsonFooterIndex = 0;
    bool json = false;
    var valuesJsonDict = {};
    int linkStartIndex, linkEndIndex;

    for (int i = 0; i < html.length; i++) {
      //json LINKS
      if (!json) {
        if (jsonHeader[jsonHeaderIndex] == html[i])
          jsonHeaderIndex++;
        else if (jsonHeader[jsonHeaderIndex] == html[i])
          jsonHeaderIndex++;
        else
          jsonHeaderIndex = 0;

        if (jsonHeader.length == jsonHeaderIndex) {
          json = true;
          linkStartIndex = i + 1;
        }
      } else {
        if (jsonFooter[jsonFooterIndex] == html[i])
          jsonFooterIndex++;
        else
          jsonFooterIndex = 0;

        if (jsonFooterIndex == jsonFooter.length) {
          linkEndIndex = i - jsonFooter.length + 1;
          valuesJsonDict =
              jsonDecode(html.substring(linkStartIndex, linkEndIndex));
          break;
        }
      }
    }

    valuesJsonDict = valuesJsonDict['entry_data']['PostPage'][0]['graphql']
        ['shortcode_media'];
    thumbnailUrl = valuesJsonDict['display_resources'][0]['src'];
    accountPhotoUrl = valuesJsonDict['owner']['profile_pic_url'];
    accountName = valuesJsonDict['owner']['username'];
    if (valuesJsonDict['edge_media_to_caption']['edges'].length > 0)
      descriptionString =
          valuesJsonDict['edge_media_to_caption']['edges'][0]['node']['text'];

    if (valuesJsonDict['is_video'])
      links.add(FileInfo(2, valuesJsonDict['video_url']));
    else if (valuesJsonDict['edge_sidecar_to_children'] == null)
      links.add(FileInfo(1, valuesJsonDict['display_url']));
    else {
      var valuesArray = valuesJsonDict['edge_sidecar_to_children']['edges'];
      for (int i = 0; i < valuesArray.length; i++) {
        if (valuesArray[i]['node']['is_video'])
          links.add(FileInfo(2, valuesArray[i]['node']['video_url']));
        else
          links.add(FileInfo(1, valuesArray[i]['node']['display_url']));
      }
    }

    return {
      "links": links,
      "description": descriptionString,
      "thumbnail_url": thumbnailUrl,
      "account_tag": accountName,
      "account_pic_url": accountPhotoUrl
    };
  }
}
