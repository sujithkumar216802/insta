import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripleDot extends StatelessWidget {
  const TripleDot(
      {Key key,
      @required this.function,
      @required this.index,
      @required this.type,
      this.single = false})
      : super(key: key);
  final function;
  final int index;
  final int type;
  final bool single;

  static const single_post = {
    'name': ['Share'],
    'value': ['share']
  };

  static const values = [
    {
      'name': ['Open post', 'Share', 'Copy caption', 'Delete'],
      'value': ['url', 'share', 'caption', 'delete']
    },
    {
      'name': [
        'Open post',
        'Download Remaining',
        'Share remaining',
        'Copy caption',
        'Delete remaining'
      ],
      'value': ['url', 'download', 'share', 'caption', 'delete']
    },
    {
      'name': ['Open post', 'Download', 'Copy caption', 'Delete listing'],
      'value': ['url', 'download', 'caption', 'delete']
    },
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        if (single) {
          return List.generate(
              single_post['name'].length,
              (index) => PopupMenuItem(
                    child: Text(single_post['name'][index]),
                    value: single_post['value'][index],
                  ));
        } else {
          return List.generate(
              values[type]['name'].length,
              (index) => PopupMenuItem(
                    child: Text(values[type]['name'][index]),
                    value: values[type]['value'][index],
                  ));
        }
      },
      onSelected: (String value) {
        function(value, index);
      },
    );
  }
}
