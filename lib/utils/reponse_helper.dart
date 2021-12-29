import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/utils/dialogue_helper.dart';

responseHelper(context, status, {callback}) {
  switch (status) {
    case Status.SUCCESS:
      showDialogueWithText(
          context, 'Success', 'File(s) downloaded successfully');
      break;
    case Status.FAILURE:
      showDialogueWithText(context, 'Failure', 'Something went wrong');
      break;
    case Status.INACCESSIBLE_LOGGED_IN:
      showDialogueWithText(
          context, 'Cannot Access', 'This post cannot be accessed');
      break;
    case Status.NOT_FOUND:
      showDialogueWithText(context, 'Not found', 'Post does not exist');
      break;
    case Status.INACCESSIBLE:
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                title: Text('LOGIN REQUIRED'),
                content: Text('Login to access the post'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel')),
                  TextButton(onPressed: callback, child: Text('Login')),
                ],
              ));
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
