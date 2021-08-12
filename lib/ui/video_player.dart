import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

class VideoP extends StatefulWidget {
  const VideoP({Key key, @required this.video}) : super(key: key);

  final Uint8List video;

  @override
  _VideoPState createState() => _VideoPState(video);
}

class _VideoPState extends State<VideoP> {
  Uint8List video;
  VideoPlayerController _controller;

  _VideoPState(Uint8List video) {
    this.video = video;
  }

  @override
  void initState() {
    super.initState();
    getVideo();
  }

  void getVideo() async {
    var uuid = Uuid();
    Directory directory = await getApplicationDocumentsDirectory();
    String dir = directory.path;
    File file = File('$dir/' + uuid.v1() + '.mp4');
    await file.writeAsBytes(video);
    _controller = VideoPlayerController.file(file)
      ..initialize().then((value) {
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          child: (_controller!=null && _controller.value.isInitialized)
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : Container(),
        ),
        GestureDetector(
            onTap: () {
              setState(() {
                _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play();
              });
            },
            child: Icon(
              (_controller!=null && _controller.value.isPlaying) ? Icons.pause : Icons.play_arrow,
              size: 60,
              color: Colors.white,
            ))
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
