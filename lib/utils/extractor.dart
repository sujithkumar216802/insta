import 'dart:convert';
import 'dart:math';

import 'package:insta_downloader/enums/file_type_enum.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';

const sharedDataHeader = 'window._sharedData = ';

const sharedDataFooter = ';</script>';

const jsonHeader =
    '<html><head></head><body><pre style="word-wrap: break-word; white-space: pre-wrap;">';

const jsonFooter = '</pre></body></html>';

extract(String html,
    {bool storyId = false,
    bool highlightsId = false,
    p = "",
    bool storyDetails = false,
    String linkStoryId = "",
    checkLogin = false}) {
  List<FileInfo> links = [];
  String descriptionString = "";
  String thumbnailUrl = "";
  String accountName = "";
  String accountPhotoUrl = "";
  double ratio = 1;

  int linkStartIndex, linkEndIndex;

  try {
    if (storyDetails) {
      int jsonHeaderIndex = 0;
      int jsonFooterIndex = 0;
      bool json = false;
      var dataDict;

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
            dataDict = jsonDecode(html.substring(linkStartIndex, linkEndIndex));
            break;
          }
        }
      }

      dataDict = dataDict['data']['reels_media'][0];
      accountName = dataDict['owner']['username'];
      accountPhotoUrl = dataDict['owner']['profile_pic_url'];
      dataDict = dataDict['items'];
      for (var item in dataDict) {
        if (linkStoryId == "" || item['id'] == linkStoryId) {
          thumbnailUrl = item['display_url'];
          ratio = max(ratio,
              item['dimensions']['width'] / item['dimensions']['height']);
          if (item['is_video'])
            links.add(FileInfo(
                FileType.VIDEO,
                item['video_resources'][item['video_resources'].length - 1]
                    ['src']));
          else
            links.add(FileInfo(FileType.IMAGE, thumbnailUrl));
        }
      }
    } else {
      int sharedDataHeaderIndex = 0;
      int sharedDataFooterIndex = 0;
      int additionalDataHeaderIndex = 0;
      int additionalDataFooterIndex = 0;

      bool sharedData = false;
      bool sharedDataDone = false;
      bool additionalData = false;
      bool additionalDataDone = false;
      bool login = false;
      bool loopCheck = false;

      var sharedDataDict;
      var additionalDataDict;

      String additionalDataHeader = "window.__additionalDataLoaded('$p',";
      String additionalDataFooter = ");";

      /* When the user is not logged in: -
    *     no matter if the post is accessible or not, ADDITIONAL DATA won't exist
    *     for accessible post 'PostPage' will exist
    *     for inaccessible post 'PostPage' will NOT exist
    *
    * When the user is logged in: -
    *     for accessible post ADDITIONAL DATA will exist
    *     for inaccessible post ADDITIONAL DATA will NOT exist
    *     for accessible post 'PostPage' will exist but it's empty, so don't use that
    *     for inaccessible post 'PostPage' will NOT exist
    *
    *
    *
    *
    * At the end,
    * inaccessible - 'PostPage' will not exist
    *
    * while logged in - ignore 'PostPage'
    * while logged out - use 'PostPage'
    *
    *
    * */

      for (int i = 0; i < html.length; i++) {
        if (!sharedDataDone) {
          if (!sharedData) {
            if (sharedDataHeader[sharedDataHeaderIndex] == html[i])
              sharedDataHeaderIndex++;
            else
              sharedDataHeaderIndex = 0;

            if (sharedDataHeader.length == sharedDataHeaderIndex) {
              sharedData = true;
              linkStartIndex = i + 1;
            }
          } else {
            if (sharedDataFooter[sharedDataFooterIndex] == html[i])
              sharedDataFooterIndex++;
            else
              sharedDataFooterIndex = 0;

            if (sharedDataFooterIndex == sharedDataFooter.length) {
              linkEndIndex = i - sharedDataFooter.length + 1;
              sharedDataDict =
                  jsonDecode(html.substring(linkStartIndex, linkEndIndex));
              sharedDataDone = true;
            }
          }
        }

        if (!additionalDataDone) {
          if (!additionalData) {
            if (additionalDataHeader[additionalDataHeaderIndex] == html[i])
              additionalDataHeaderIndex++;
            else
              additionalDataHeaderIndex = 0;

            if (additionalDataHeader.length == additionalDataHeaderIndex) {
              additionalData = true;
              linkStartIndex = i + 1;
            }
          } else {
            if (additionalDataFooter[additionalDataFooterIndex] == html[i])
              additionalDataFooterIndex++;
            else
              additionalDataFooterIndex = 0;

            if (additionalDataFooterIndex == additionalDataFooter.length) {
              linkEndIndex = i - additionalDataFooter.length + 1;
              additionalDataDict =
                  jsonDecode(html.substring(linkStartIndex, linkEndIndex));
              additionalDataDone = true;
            }
          }
        }

        if (sharedDataDone && !loopCheck) {
          //check if additional data needs to be found
          if (!sharedDataDict['config'].containsKey('viewer') ||
              storyId ||
              highlightsId) break;

          loopCheck = true;
        }
      }

      login = sharedDataDict['config']['viewer'] != null;

      //Check if the user is logged in
      if (checkLogin) return login;

      //STORY ID
      if (storyId)
        return sharedDataDict['entry_data']['StoriesPage'][0]['user']['id'];

      if (highlightsId)
        return sharedDataDict['entry_data']['StoriesPage'][0]['highlight']
            ['id'];

      //check if the post is accessible or not
      if (!sharedDataDict['entry_data'].containsKey('PostPage')) {
        if (login) return Status.INACCESSIBLE_LOGGED_IN;
        return Status.INACCESSIBLE;
      }

      if (!login) {
        additionalDataDict = sharedDataDict['entry_data']['PostPage'][0]
            ['graphql']['shortcode_media'];

        thumbnailUrl = additionalDataDict['display_resources'][0]['src'];
        accountPhotoUrl = additionalDataDict['owner']['profile_pic_url'];
        accountName = additionalDataDict['owner']['username'];
        ratio = max(
            ratio,
            additionalDataDict['dimensions']['width'] /
                additionalDataDict['dimensions']['height']);

        if (additionalDataDict['edge_media_to_caption']['edges'].length > 0)
          descriptionString = additionalDataDict['edge_media_to_caption']
              ['edges'][0]['node']['text'];

        if (additionalDataDict['is_video'])
          links.add(FileInfo(FileType.VIDEO, additionalDataDict['video_url']));
        else if (additionalDataDict['edge_sidecar_to_children'] == null)
          links
              .add(FileInfo(FileType.IMAGE, additionalDataDict['display_url']));
        else {
          var valuesArray =
              additionalDataDict['edge_sidecar_to_children']['edges'];
          for (int i = 0; i < valuesArray.length; i++) {
            if (valuesArray[i]['node']['is_video'])
              links.add(FileInfo(
                  FileType.VIDEO, valuesArray[i]['node']['video_url']));
            else
              links.add(FileInfo(
                  FileType.IMAGE, valuesArray[i]['node']['display_url']));
          }
        }
      } else {
        additionalDataDict = additionalDataDict['items'][0];

        /*
        * "account_tag": additionalDataDict['user']['username']
        * "account_pic_url": additionalDataDict['user']['profile_pic_url']
        * "description": null when empty, descriptionString = additionalDataDict['caption']['text']
        * These 3 are same for all types of post
        *
        * ratio: additionalDataDict['original_width'] / additionalDataDict['original_height']
        * all posts except carousel(different files can have different ratio... I will be taking the max of all)
        *
        * REELS
        * "links": additionalDataDict['video_versions']['url']
        * "thumbnail_url": additionalDataDict['image_versions2']['candidates'][0]['url'];
        *
        * Video
        * "links": additionalDataDict['video_versions'][0]['url']
        * "thumbnail_url": additionalDataDict['thumbnails']['sprite_urls'][0]
        *
        * IGTV
        * "links": additionalDataDict['video_versions'][0]['url']
        * "thumbnail_url": additionalDataDict['thumbnails']['sprite_urls'][0]
        *
        * PHOTO
        * "links": additionalDataDict['image_versions2']['candidates'][0]['url']
        * "thumbnail_url": additionalDataDict['image_versions2']['candidates'][0]['url']... maybe the last element in candidates for size reasons
        *
        * Carousel
        * "links": post['image_versions2']['candidates'][0]['url'] or post['video_versions'][0]['url']
        * post is every item inside 'carousel_media'
        * "thumbnail_url": additionalDataDict['carousel_media'][0]['image_versions2']['candidates'][0]['url']
        *
        * */

        // thumbnailUrl = additionalDataDict['thumbnails']['sprite_urls'][0];
        accountPhotoUrl = additionalDataDict['user']['profile_pic_url'];
        accountName = additionalDataDict['user']['username'];

        if (additionalDataDict['caption'] != null)
          descriptionString = additionalDataDict['caption']['text'];

        //carousel
        if (additionalDataDict.containsKey('carousel_media')) {
          thumbnailUrl = additionalDataDict['carousel_media'][0]
              ['image_versions2']['candidates'][0]['url'];
          for (var post in additionalDataDict['carousel_media']) {
            if (post.containsKey('video_versions')) {
              ratio =
                  max(ratio, post['original_width'] / post['original_height']);
              links.add(
                  FileInfo(FileType.VIDEO, post['video_versions'][0]['url']));
            } else {
              ratio =
                  max(ratio, post['original_width'] / post['original_height']);
              links.add(FileInfo(FileType.IMAGE,
                  post['image_versions2']['candidates'][0]['url']));
            }
          }
        }
        //single video
        else if (additionalDataDict.containsKey('video_versions')) {
          ratio = max(
              ratio,
              additionalDataDict['original_width'] /
                  additionalDataDict['original_height']);
          if (additionalDataDict.containsKey('thumbnail'))
            thumbnailUrl = additionalDataDict['thumbnails']['sprite_urls'][0];
          else
            thumbnailUrl = additionalDataDict['image_versions2']['candidates'][0]['url'];
          links.add(FileInfo(
              FileType.VIDEO, additionalDataDict['video_versions'][0]['url']));
        }
        //single photo
        else {
          ratio = max(
              ratio,
              additionalDataDict['original_width'] /
                  additionalDataDict['original_height']);
          thumbnailUrl =
              additionalDataDict['image_versions2']['candidates'][0]['url'];
          links.add(FileInfo(FileType.IMAGE,
              additionalDataDict['image_versions2']['candidates'][0]['url']));
        }
      }
    }
    return {
      "links": links,
      "description": descriptionString,
      "thumbnail_url": thumbnailUrl,
      "account_tag": accountName,
      "account_pic_url": accountPhotoUrl,
      'ratio': ratio
    };
  } catch (e) {
    return Status.FAILURE;
  }
}
