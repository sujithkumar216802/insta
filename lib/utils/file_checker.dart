import 'package:insta_downloader/enums/post_availability_enum.dart';
import 'package:insta_downloader/models/file_info_model.dart';
import 'package:insta_downloader/models/history_model.dart';
import 'package:insta_downloader/utils/method_channel.dart';

checkAllFiles(History history) async {
  PostAvailability postAvailability = PostAvailability.NONE;
  List<int> availableIndexes = [];
  List<String> uris = [];
  List<FileInfo> notAvailableFilesInfo = [];
  List<int> notAvailableIndexes = [];

  for (int i = 0; i < history.files.length; i++) {
    if (await checkIfFileExists(history.files[i].uri)) {
      availableIndexes.add(i);
      uris.add(history.files[i].uri);
    } else {
      notAvailableFilesInfo.add(history.files[i]);
      notAvailableIndexes.add(i);
    }
  }

  if (availableIndexes.length == history.files.length)
    postAvailability = PostAvailability.ALL;
  else if (availableIndexes.length != 0)
    postAvailability = PostAvailability.PARTIAL;
  return {
    'post_availability': postAvailability,
    'available_indexes': availableIndexes,
    'available_files_uri': uris,
    'not_available_files_info': notAvailableFilesInfo,
    'not_available_indexes': notAvailableIndexes
  };
}
