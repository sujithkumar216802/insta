import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripleDot extends StatelessWidget {
  const TripleDot(
      {Key key,
      @required this.function,
      @required this.index,
      @required this.type})
      : super(key: key);
  final function;
  final int index;
  final int type;

  static const values =
  [
    {
      'name': ['Open post', 'Share', 'Copy caption', 'Delete'],
      'value': ['url', 'share', 'caption', 'delete']
    },
    {
      'name': ['Share'],
      'value': ['share']
    }
  ];

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        return List.generate(
            values[type]['name'].length,
            (index) => PopupMenuItem(
                  child: Text(values[type]['name'][index]),
                  value: values[type]['value'][index],
                ));
      },
      onSelected: (String value) {
        function(value, index);
      },
    );
  }
}
