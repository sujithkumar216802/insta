import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/widget/pop_up_menu.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(
      {Key key,
      this.list,
      this.file,
      @required this.function,
      @required this.index})
      : super(key: key);

  final Uint8List list;
  final function;
  final int index;
  final File file;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        (list != null) ? Image.memory(list) : Image.file(file),
        TripleDot(callbackFunction: function, index: index, isSingleFile: true)
      ],
    );
  }
}
