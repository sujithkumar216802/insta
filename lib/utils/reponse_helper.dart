import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/status_enum.dart';
import 'package:insta_downloader/utils/dialogue_helper.dart';

responseHelper(context, status) {
  switch (status) {
    case Status.SUCCESS:
      showDialogueWithText(context, 'Success', 'File(s) downloaded successfully');
      break;
    case Status.FAILURE:
      showDialogueWithText(context, 'Failure', 'Something went wrong');
      break;
    case Status.NO_INTERNET:
      showDialogueWithText(context, 'No Internet', 'Please be online while downloading');
      break;
    case Status.NOT_FOUND:
      showDialogueWithText(context, 'Not found', 'Post does not exist');
      break;
    case Status.PRIVATE:
      showDialogueWithText(context, 'Success', 'File(s) downloaded successfully');
      break;
}}
