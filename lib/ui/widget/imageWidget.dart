import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/widget/pop_up_menu.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget(
      {Key key,
      @required this.list,
      @required this.function,
      @required this.index})
      : super(key: key);

  final Uint8List list;
  final function;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.memory(list, alignment: Alignment.center,),
        Align(
          alignment: Alignment.topRight,
          child: TripleDot(callbackFunction: function, index: index, isSingleFile: true),
        )
      ],
    );
  }
}
