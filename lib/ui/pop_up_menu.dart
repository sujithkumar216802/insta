import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TripleDot extends StatelessWidget {
  const TripleDot(
      {Key key,
      @required this.function,
      @required this.index})
      : super(key: key);
  final function;
  final int index;

  static const values =
    {
      'name': ['Open post', 'Share', 'Copy caption', 'Delete'],
      'value': ['url', 'share', 'caption', 'delete']
    };

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert),
      itemBuilder: (context) {
        return List.generate(
            values['name'].length,
            (index) => PopupMenuItem(
                  child: Text(values['name'][index]),
                  value: values['value'][index],
                ));
      },
      onSelected: (String value) {
        function(value, index);
      },
    );
  }
}
