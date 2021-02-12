import 'package:chat_ui_stream_iii_example/api/stream_story_api.dart';
import 'package:chat_ui_stream_iii_example/model/user_story.dart';
import 'package:chat_ui_stream_iii_example/widget/story_card_widget.dart';
import 'package:flutter/material.dart';

class StoriesGridWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserStory>>(
      future: StreamStoryApi.getStories(),
      builder: (context, snapshot) {
        final double padding = 10;

        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return Center(child: Text('Something Went Wrong Try later'));
            } else {
              final stories = snapshot.data;

              return GridView.builder(
                itemCount: stories.length + 1,
                padding: EdgeInsets.all(padding),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: padding,
                  mainAxisSpacing: padding,
                  childAspectRatio: 3 / 4,
                ),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return AddStoryCardWidget();
                  } else {
                    final story = stories[index - 1];

                    return UserStoryCardWidget(story: story);
                  }
                },
              );
            }
        }
      },
    );
  }
}
