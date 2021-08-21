import 'dart:convert';

import 'package:insta_downloader/models/file_info_model.dart';

class Extractor {
  static const jsonHeader = [
    '<script type="application/ld+json">',
    'window._sharedData = '
  ];

  static const jsonFooter = ['</script>', ';</script>'];

  //extractor
  static extract(String html) {
    List<FileInfo> links = [];
    String descriptionString = "";
    String thumbnailUrl = "";
    String accountTagString = "";
    int jsonHeaderIndex = 0;
    int jsonFooterIndex = 0;
    bool json = false;
    var detailsJsonDict = {};
    var valuesJsonDict = {};
    int jsonIndex = 0;
    int linkStartIndex, linkEndIndex;

    for (int i = 0; i < html.length; i++) {
      //json LINKS
      if (!json) {
        if (jsonHeader[0][jsonHeaderIndex] == html[i]) {
          jsonHeaderIndex++;
          jsonIndex = 0;
        } else if (jsonHeader[1][jsonHeaderIndex] == html[i]) {
          jsonHeaderIndex++;
          jsonIndex = 1;
        } else
          jsonHeaderIndex = 0;

        if (jsonHeader[jsonIndex].length == jsonHeaderIndex) {
          json = true;
          linkStartIndex = i + 1;
        }
      } else {
        if (jsonFooter[jsonIndex][jsonFooterIndex] == html[i])
          jsonFooterIndex++;
        else
          jsonFooterIndex = 0;

        if (jsonFooterIndex == jsonFooter[jsonIndex].length) {
          linkEndIndex = i - jsonFooter[jsonIndex].length + 1;
          if (jsonIndex == 0)
            detailsJsonDict =
                jsonDecode(html.substring(linkStartIndex, linkEndIndex));
          else
            valuesJsonDict =
                jsonDecode(html.substring(linkStartIndex, linkEndIndex));
          json = false;
          jsonHeaderIndex = 0;
          jsonFooterIndex = 0;
        }
      }
    }

    valuesJsonDict =
        valuesJsonDict['entry_data']['PostPage'][0]['graphql']['shortcode_media'];
    thumbnailUrl = valuesJsonDict['display_url'];
    if(valuesJsonDict['is_video']) {
      links.add(FileInfo(2, valuesJsonDict['video_url']));
    }
    else {
      var valuesArray = valuesJsonDict['edge_sidecar_to_children']['edges'];
      for (int i = 0; i < valuesArray.length; i++) {
        if (valuesArray[i]['node']['is_video']) {
          links.add(FileInfo(2, valuesArray[i]['node']['video_url']));
        } else {
          links.add(FileInfo(1, valuesArray[i]['node']['display_url']));
        }
      }
    }

    if (detailsJsonDict['caption'] != null)
      descriptionString = detailsJsonDict['caption'];
    accountTagString = detailsJsonDict['author']['alternateName'];

    var returnValue = {
      "links": links,
      "description": descriptionString,
      "thumbnail_url": thumbnailUrl,
      "account_tag": accountTagString,
    };
    return returnValue;
  }
}
