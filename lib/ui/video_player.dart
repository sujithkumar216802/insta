import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({Key key, @required this.video}) : super(key: key);

  final File video;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState(video);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  File video;
  VideoPlayerController _controller;

  _VideoPlayerWidgetState(File video) {
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
        (_controller != null && _controller.value.isInitialized)
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : Container(),
        GestureDetector(
            onTap: () {
              if (_controller != null) {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              }
            },
            child: Icon(
              (_controller != null && _controller.value.isPlaying)
                  ? Icons.pause
                  : Icons.play_arrow,
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
