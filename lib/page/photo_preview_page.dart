import 'dart:io';

import 'package:chat_ui_stream_iii_example/api/stream_story_api.dart';
import 'package:chat_ui_stream_iii_example/model/story.dart';
import 'package:flutter/material.dart';

import '../app_routes.dart';

class PhotoPreviewPage extends StatelessWidget {
  final File imageFile;

  const PhotoPreviewPage({
    Key key,
    @required this.imageFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(imageFile, fit: BoxFit.cover),
            Positioned(
              bottom: 10,
              right: 10,
              child: Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.white,
                    iconSize: 30,
                    onPressed: () => uploadStory(context),
                  ),
                  Text(
                    'Add to Story',
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ],
        ),
      );

  void uploadStory(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    final story = Story(time: DateTime.now(), imageUrl: 'NOOP');
    await StreamStoryApi.addStory(story, imageFile);

    // hide dialog
    Navigator.pop(context);

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.people,
      ModalRoute.withName('/'),
    );
  }
}
