import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoP extends StatefulWidget {
  const VideoP({Key key, @required this.video}) : super(key: key);

  final File video;

  @override
  _VideoPState createState() => _VideoPState(video);
}

class _VideoPState extends State<VideoP> {
  File video;
  VideoPlayerController _controller;

  _VideoPState(File video) {
    this.video = video;
  }

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(video)
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
          child: _controller.value.isInitialized
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
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
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
