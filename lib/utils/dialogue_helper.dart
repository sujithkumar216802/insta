import 'package:flutter/material.dart';

showDialogueWithText(context, title, text) {
  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(text),
          ));
}

showDialogueWithLoadingBar(context, title) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => AlertDialog(
          title: Text(title),
          content: Align(
            child: Container(
                child: CircularProgressIndicator(),
                padding: EdgeInsets.all(10),
                width: MediaQuery.of(context).size.width / 5,
                height: MediaQuery.of(context).size.width / 5),
            alignment: Alignment.center,
            heightFactor: 1,
          )));
}
