import 'dart:io';

import 'package:flutter/material.dart';
import 'package:insta_downloader/ui/widget/pop_up_menu.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget(
      {Key key,
      @required this.video,
      @required this.function,
      @required this.index})
      : super(key: key);

  final File video;
  final function;
  final int index;

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController _controller;

  _VideoPlayerWidgetState();

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.video)
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
            )),
        Align(
          alignment: Alignment.topRight,
          child: TripleDot(
              callbackFunction: widget.function,
              index: widget.index,
              isSingleFile: true),
        )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
