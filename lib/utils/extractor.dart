import 'dart:convert';

class Extractor {
  static const videoHeader = "\"video_url\":\"";

  static const videoFooter = "\",";

  static const displayHeader = "\"display_url\":\"";

  static const displayFooter = "\",";

  static const jsonHeader = '<script type="application/ld+json">';

  static const jsonFooter = "</script>";

  //extractor
  static extract(String html) {
    List<String> tempLinks = [];
    List<int> tempType = [];
    List<String> links = [];
    List<int> type = [];
    String descriptionString = "";
    String thumbnailUrl = "";
    String accountTagString = "";
    int videoFooterIndex = 0;
    int videoHeaderIndex = 0;
    int displayHeaderIndex = 0;
    int displayFooterIndex = 0;
    int jsonHeaderIndex = 0;
    int jsonFooterIndex = 0;
    bool video = false;
    bool display = false;
    bool json = false;
    var jsonDict = {};
    int linkStartIndex, linkEndIndex;

    String temp;

    //TODO fool proof... basically using json instead of this

    for (int i = 0; i < html.length; i++) {
      //VIDEO LINKS
      if (!video) {
        if (videoHeader[videoHeaderIndex] == html[i])
          videoHeaderIndex++;
        else
          videoHeaderIndex = 0;

        if (videoHeader.length == videoHeaderIndex) {
          video = true;
          linkStartIndex = i + 1;
        }
      } else {
        if (videoFooter[videoFooterIndex] == html[i])
          videoFooterIndex++;
        else
          videoFooterIndex = 0;

        if (videoFooterIndex == videoFooter.length) {
          linkEndIndex = i - videoFooter.length + 1;
          temp = html.substring(linkStartIndex, linkEndIndex);
          tempLinks.add(temp.replaceAll("\\u0026", '&'));
          tempType.add(2);
          video = false;
          videoHeaderIndex = 0;
          videoFooterIndex = 0;
        }
      }

      //Display LINKS
      if (!display) {
        if (displayHeader[displayHeaderIndex] == html[i])
          displayHeaderIndex++;
        else
          displayHeaderIndex = 0;

        if (displayHeader.length == displayHeaderIndex) {
          display = true;
          linkStartIndex = i + 1;
        }
      } else {
        if (displayFooter[displayFooterIndex] == html[i])
          displayFooterIndex++;
        else
          displayFooterIndex = 0;

        if (displayFooterIndex == displayFooter.length) {
          linkEndIndex = i - displayFooter.length + 1;
          temp = html.substring(linkStartIndex, linkEndIndex);
          tempLinks.add(temp.replaceAll("\\u0026", '&'));
          tempType.add(1);
          display = false;
          displayHeaderIndex = 0;
          displayFooterIndex = 0;
        }
      }

      //json LINKS
      if (!json) {
        if (jsonHeader[jsonHeaderIndex] == html[i])
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
          jsonDict = jsonDecode(html.substring(linkStartIndex, linkEndIndex));
          json = false;
          jsonHeaderIndex = 0;
          jsonFooterIndex = 0;
        }
      }
    }

    thumbnailUrl = tempLinks[0];
    //thumbnail for video posts and multi photo
    if (tempLinks.length > 1) {
      tempLinks.removeAt(0);
      tempType.removeAt(0);
    }

    //removing useless links
    for (int i = tempLinks.length - 1; i >= 0; i--) {
      links.add(tempLinks[i]);
      type.add(tempType[i]);
      if (tempType[i] == 2) {
        i--;
      }
    }

    if (jsonDict['caption'] != null) descriptionString = jsonDict['caption'];
    accountTagString = jsonDict['author']['alternateName'];

    return {
      "links": links,
      "type": type,
      "description": descriptionString,
      "thumbnail_url": thumbnailUrl,
      "account_tag": accountTagString,
    };
  }
}
