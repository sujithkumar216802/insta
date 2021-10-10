import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta_downloader/enums/post_availability_enum.dart';

class TripleDot extends StatelessWidget {
  const TripleDot(
      {Key key,
      @required this.callbackFunction,
      @required this.index,
      this.postAvailability = PostAvailability.NONE,
      this.isSingleFile = false})
      : super(key: key);
  final callbackFunction;
  final int index;
  final PostAvailability postAvailability;
  final bool isSingleFile;

  static const single_post = {
    'name': ['Share', 'Delete'],
    'value': ['share', 'delete']
  };

  static const values = {
    PostAvailability.ALL: {
      'name': ['Open post', 'Share', 'Copy caption', 'Delete'],
      'value': ['url', 'share', 'caption', 'delete']
    },
    PostAvailability.PARTIAL: {
      'name': [
        'Open post',
        'Download Remaining',
        'Share remaining',
        'Copy caption',
        'Delete remaining'
      ],
      'value': ['url', 'download', 'share', 'caption', 'delete']
    },
    PostAvailability.NONE: {
      'name': ['Open post', 'Download', 'Copy caption', 'Delete listing'],
      'value': ['url', 'download', 'caption', 'delete']
    }
  };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        if (isSingleFile) {
          return List.generate(
              single_post['name'].length,
              (index) => PopupMenuItem(
                    child: Text(single_post['name'][index]),
                    value: single_post['value'][index],
                  ));
        } else {
          return List.generate(
              values[postAvailability]['name'].length,
              (index) => PopupMenuItem(
                    child: Text(values[postAvailability]['name'][index]),
                    value: values[postAvailability]['value'][index],
                  ));
        }
      },
      onSelected: (value) {
        callbackFunction(value, index);
      },
    );
  }
}
