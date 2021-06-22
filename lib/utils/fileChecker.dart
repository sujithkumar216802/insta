import 'dart:io';

import 'package:insta_downloader/models/HistoryModel.dart';
import 'package:insta_downloader/models/fileInfoModel.dart';

import 'databaseHelper.dart';

class FileChecker {
  static int checkAllFiles(History history) {
    //updating the file availability info
    bool change = false;
    int available = 0;
    for (FileInfo x in history.files) {
      if (x.isAvailable != File(x.file).existsSync()) {
        x.isAvailable = !x.isAvailable;
        change = true;
      }
      if (!x.isAvailable) available++;
    }
    if (change) DatabaseHelper.instance.update(history);

    if (available == history.files.length)
      available = 2;
    else if (available != 0)
      available = 1;
    return available;
  }
}
