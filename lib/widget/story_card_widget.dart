import 'package:chat_ui_stream_iii_example/model/user_story.dart';
import 'package:chat_ui_stream_iii_example/page/camera_page.dart';
import 'package:chat_ui_stream_iii_example/page/story_view_page.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AddStoryCardWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => StoryCardWidget(
        title: '',
        urlImage: '',
        onClicked: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CameraPage()),
        ),
      );
}

class UserStoryCardWidget extends StatelessWidget {
  final UserStory story;

  const UserStoryCardWidget({
    Key key,
    @required this.story,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StoryCardWidget(
        title: story.userName,
        urlImage: story.stories.first.imageUrl,
        urlAvatar: story.userImageUrl,
        onClicked: () {
          if (story.stories.isEmpty) return;

          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => StoryViewPage(
              stories: [story],
              userStory: story,
            ),
          ));
        },
      );
}

class StoryCardWidget extends StatelessWidget {
  final String title;
  final String urlImage;
  final String urlAvatar;
  final VoidCallback onClicked;

  const StoryCardWidget({
    Key key,
    @required this.title,
    @required this.urlImage,
    @required this.onClicked,
    this.urlAvatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isSelfUser = urlAvatar == null;

    return GestureDetector(
      onTap: onClicked,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          image: isSelfUser
              ? null
              : DecorationImage(
                  image: NetworkImage(urlImage),
                  fit: BoxFit.cover,
                ),
        ),
        child: isSelfUser
            ? buildAdd()
            : Stack(
                children: [
                  buildAvatar(),
                  Positioned(
                    bottom: 0,
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Widget buildAvatar() => CircleAvatar(
        radius: 18,
        backgroundColor: Colors.blue,
        child: CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage(urlAvatar),
        ),
      );

  Widget buildAdd() => Center(
        child: Icon(Icons.add, size: 72, color: Colors.white),
      );
}
