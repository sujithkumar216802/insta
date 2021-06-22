import 'package:insta_downloader/models/fileInfoModel.dart';
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
    List<FileInfo> temp = [];
    List<FileInfo> temp2 = [];
    Set<FileInfo> links = Set();
    String descriptionString ="";
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
          temp.add(FileInfo(
              2, html.substring(linkStartIndex, linkEndIndex)));
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
          temp.add(FileInfo(
              1, html.substring(linkStartIndex, linkEndIndex)));
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


    thumbnailUrl = temp[0].url;
    temp.removeAt(0);

    //removing useless links
    for (int i = temp.length - 1; i >= 0; i--) {
      temp2.add(temp[i]);
      if (temp[i].type == 2) {
        i--;
      }
    }

    //cleaning up the link TODO fool proof... basically using json instead of this shit
    for (FileInfo x in temp2)
      links.add(FileInfo(x.type, x.url.replaceAll("\\u0026", '&')));
    thumbnailUrl = thumbnailUrl.replaceAll("\\u0026", '&');



    if(jsonDict['caption']!=null)
      descriptionString = jsonDict['caption'];
    accountTagString = jsonDict['author']['alternateName'];

    var returnValue = {
      "links": links.toList(),
      "description": descriptionString,
      "thumbnail_url": thumbnailUrl,
      "account_tag": accountTagString,
    };
    return returnValue;
  }
}
