import 'package:chat_ui_stream_iii_example/app_routes.dart';
import 'package:flutter/material.dart';

import '../api/stream_channel_api.dart';
import '../api/stream_user_api.dart';
import '../model/user.dart';
import '../page/chat/chat_page_mobile.dart';
import 'profile_image_widget.dart';

class ActiveUsersRowWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FutureBuilder<List<User>>(
        future: StreamUserApi.getAllUsers(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(child: Text('Something Went Wrong Try later'));
              } else {
                final users = snapshot.data;

                return buildActiveUsers(context, users);
              }
          }
        },
      );

  Widget buildActiveUsers(BuildContext context, List<User> users) =>
      ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: users.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return buildCreateRoom(context);
          } else {
            final user = users[index - 1];

            return buildActiveUser(context, user);
          }
        },
      );

  Widget buildActiveUser(BuildContext context, User user) => Container(
        width: 75,
        padding: const EdgeInsets.all(4),
        child: GestureDetector(
          onTap: () async {
            final currentChannel = await StreamChannelApi.searchChannel(
              idUser: user.idUser,
              username: user.name,
            );

            if (currentChannel == null) {
              final channel = await StreamChannelApi.createChannelWithUsers(
                context,
                name: user.name,
                urlImage: user.imageUrl,
                idMembers: [user.idUser],
              );

              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatPageMobile(channel: channel),
              ));
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ChatPageMobile(channel: currentChannel),
              ));
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProfileImageWidget(
                imageUrl: user.imageUrl,
                radius: 25,
              ),
              Text(
                user.name,
                maxLines: 2,
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      );

  Widget buildCreateRoom(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.participants),
        child: Container(
          width: 75,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                child: Icon(Icons.video_call, size: 28, color: Colors.black),
                radius: 25,
              ),
              Text(
                'Create\nRoom',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );
}
