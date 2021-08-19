import 'dart:io';

import 'package:insta_downloader/models/history_model.dart';

import 'database_helper.dart';

/*
available = 0 :- all are available...
available = 1 :- partial availability
available = 2 :- no availabiility
*/

class FileChecker {
  static checkAllFiles(History history) {
    //updating the file availability info
    bool change = false;
    int available = 0;
    List<int> indexes = [];

    for (int i = 0; i < history.files.length; i++) {
      if (history.files[i].isAvailable !=
          File(history.files[i].file).existsSync()) {
        history.files[i].isAvailable = !history.files[i].isAvailable;
        change = true;
      }

      if (history.files[i].isAvailable) indexes.add(i);
    }

    if (change) DatabaseHelper.instance.update(history);

    if (indexes.length == history.files.length)
      available = 0;
    else if (indexes.length != 0) available = 1;
    return [available, indexes];
  }
}
