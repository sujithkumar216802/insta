import 'package:flutter/cupertino.dart';
import 'package:insta_downloader/models/history_model.dart';
import 'package:insta_downloader/utils/reponse_helper.dart';

import '../enums/post_availability_enum.dart';
import '../models/file_info_model.dart';
import 'database_helper.dart';
import 'dialogue_helper.dart';
import 'downloader.dart';
import 'file_checker.dart';

checkAndUpdateMissing(String url, BuildContext context) async {

  //check duplicates
  List<String> urlList = await DatabaseHelper.instance.getUrls();
  for (String x in urlList) {
    if (x == url) {
      //getting the history
      History history = await DatabaseHelper.instance.getHistory(x);

      Map check = await checkAllFiles(history);
      PostAvailability postAvailability = check['post_availability'];
      List<FileInfo> notAvailableFilesInfo =
      check['not_available_files_info'];
      List<int> notAvailableIndexes = check['not_available_indexes'];

      if (postAvailability == PostAvailability.ALL) {
        //show dialog
        showDialogueWithText(context, 'Already Downloaded', 'Check History');
        return true;
      } else {
        showDownloadingDialogue(context);
        var status = await updateHistory(
            notAvailableFilesInfo, history.url, notAvailableIndexes);
        Navigator.pop(context);
        responseHelper(context, status);

        //update history in db
        //fire and forget
        DatabaseHelper.instance.update(history);
        return true;
      }
    }
  }
  return false;
}