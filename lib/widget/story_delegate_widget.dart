import 'package:chat_ui_stream_iii_example/model/user_story.dart';
import 'package:flutter/material.dart';
import 'package:story_view/controller/story_controller.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:timeago/timeago.dart' as timeago;

class StoryDelegateWidget extends StatefulWidget {
  final UserStory userStory;
  final List<UserStory> allStories;
  final PageController pageController;

  const StoryDelegateWidget({
    @required this.userStory,
    @required this.pageController,
    @required this.allStories,
  });

  @override
  _StoryDelegateWidgetState createState() => _StoryDelegateWidgetState();
}

class _StoryDelegateWidgetState extends State<StoryDelegateWidget> {
  final controller = StoryController();
  List<StoryItem> storyItems = [];
  String when = '';

  @override
  void initState() {
    super.initState();
    addStoryItems();

    when = timeago.format(widget.userStory.stories[0].time);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: <Widget>[
          Material(
            type: MaterialType.transparency,
            child: StoryView(
              storyItems: storyItems,
              controller: controller,
              onComplete: handleCompleted,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
              onStoryShow: (storyItem) {
                final index = storyItems.indexOf(storyItem);
                if (index > 0) {
                  setState(() {
                    when = timeago.format(widget.userStory.stories[index].time);
                  });
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 48, left: 16, right: 16),
            child: ProfileWidget(
              userName: widget.userStory.userName,
              userImage: widget.userStory.userImageUrl,
              when: when,
            ),
          )
        ],
      );

  void addStoryItems() {
    widget.userStory.stories.forEach((story) {
      storyItems.add(StoryItem.pageImage(
        url: story.imageUrl,
        controller: controller,
        caption: '',
        duration: Duration(milliseconds: (10 * 1000).toInt()),
      ));
    });
  }

  void handleCompleted() {
    widget.pageController
        .nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeIn);

    final currentIndex = widget.allStories.indexOf(widget.userStory);
    final isLastPage = widget.allStories.length - 1 == currentIndex;

    if (isLastPage) {
      Navigator.of(context).pop();
    }
  }
}

class ProfileWidget extends StatelessWidget {
  final String userName;
  final String userImage;
  final String when;

  const ProfileWidget({
    Key key,
    @required this.userName,
    @required this.when,
    @required this.userImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
        type: MaterialType.transparency,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage(userImage),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    userName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    when,
                    style: TextStyle(color: Colors.white38),
                  )
                ],
              ),
            )
          ],
        ),
      );
}
