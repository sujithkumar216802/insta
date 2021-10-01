import 'dart:io';

import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/models/history_model.dart';
import 'package:insta_downloader/utils/method_channel.dart';

/*
available = 0 :- all are available...
available = 1 :- partial availability
available = 2 :- no availabiility
*/

checkAllFiles(History history) async {
  //updating the file availability info
  int available = 0;
  List<int> indexes = [];
  List<String> files = [];
  List<FileInfo> notAvailableFiles = [];

  for (int i = 0; i < history.files.length; i++) {
    if (await checkIfFileExists(history.files[i].file)) {
      available++;
      indexes.add(i);
      files.add(history.files[i].file);
    } else
      notAvailableFiles.add(history.files[i]);
  }

  if (indexes.length == history.files.length)
    available = 0;
  else if (indexes.length != 0) available = 1;
  return {
    'type': available,
    'available_indexes': indexes,
    'files': files,
    'not_available': notAvailableFiles
  };
}
