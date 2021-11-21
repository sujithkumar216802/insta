import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/utils/dialogue_helper.dart';

responseHelper(context, status) {
  switch (status) {
    case Status.SUCCESS:
      showDialogueWithText(
          context, 'Success', 'File(s) downloaded successfully');
      break;
    case Status.FAILURE:
      showDialogueWithText(context, 'Failure', 'Something went wrong');
      break;
    case Status.NO_INTERNET:
      showDialogueWithText(
          context, 'No Internet', 'Please be online while downloading');
      break;
    case Status.NOT_FOUND:
      showDialogueWithText(context, 'Not found', 'Post does not exist');
      break;
    // case Status.PRIVATE:
    //   showDialogueWithText(
    //       context, 'Private', 'Post is private');
      break;
    case Status.PERMISSION_NOT_GRANTED:
      showDialogueWithText(
          context, 'Permission Required', 'Permission not granted');
      break;
    case Status.ERROR_WHILE_SAVING_FILE:
      showDialogueWithText(context, 'Error', 'Error while saving file');
      break;
    case Status.NOT_LOGGED_IN:
      showDialogueWithText(context, 'Not logged in', 'Not logged in');
      break;
  }
}
