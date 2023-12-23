// ignore_for_file: library_private_types_in_public_api

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../models/user_provider.dart';

class VideoPreviewer extends StatefulWidget {

  const VideoPreviewer({super.key,});

  @override
  _VideoPreviewerState createState() => _VideoPreviewerState();
}

class _VideoPreviewerState extends State<VideoPreviewer> {
  late VideoPlayerController controller;
  late Future<void> initializationFuture;
  @override
  void initState() {
    super.initState();
     final userProvider = context.read<UserProvider>();
    controller = VideoPlayerController.file(File(userProvider.video?.path ?? ''));
   initializationFuture = controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.select<UserProvider,PlatformFile?>((provider)=>provider.video);
    return Center(
      child: FutureBuilder(
          future: initializationFuture,
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                controller.value.isInitialized) {
              return InkWell(
                onTap: () {
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                },
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator()
              );
            }
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
