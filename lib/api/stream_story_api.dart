import 'dart:convert';
import 'dart:io';

import 'package:chat_ui_stream_iii_example/model/story.dart';
import 'package:chat_ui_stream_iii_example/model/user_story.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:uuid/uuid.dart';

import 'firebase_google_api.dart';
import 'stream_api.dart';

class StreamStoryApi {
  static Future addStory(Story story, File imageFile) async {
    final user = StreamApi.client.state.user;
    final userJson = user.toJson();

    // Upload image
    final idStory = Uuid().v4();
    final urlImage = await FirebaseGoogleApi.uploadImage(
        'user/${user.id}/stories/$idStory', imageFile);
    final newStory = story.copy(imageUrl: urlImage);

    // Add new stories
    final currentStories = userJson['stories'] ?? [];
    final stories = currentStories..add(newStory.toJson());

    final newUserJson = userJson..addAll({'stories': stories});
    final newUser = User.fromJson(newUserJson);

    await StreamApi.client.updateUser(newUser);
  }

  static Future<List<UserStory>> getStories() async {
    final sort = SortOption('last_message_at');
    final response = await StreamApi.client.queryUsers(sort: [sort]);

    final allStories = response.users
        .where((user) => user.extraData['stories'] != null)
        .map<UserStory>((user) {
      final storiesJson = user.extraData['stories'];

      final stories =
          storiesJson.map<Story>((json) => Story.fromJson(json)).toList();

      return UserStory(
        stories: stories,
        userName: user.name,
        userImageUrl: user.extraData['image'],
      );
    }).toList();

    return allStories;
  }
}
