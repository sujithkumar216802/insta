import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/pop_up_menu.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({Key key, @required this.file, @required this.function, @required this.index}) : super(key: key);

  final File file;
  final function;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Image.file(file),
        TripleDot(function: function, index: index, type: 0, single: true)
      ],
    );
  }
}
