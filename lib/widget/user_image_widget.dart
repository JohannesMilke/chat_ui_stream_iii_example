import 'package:chat_ui_stream_iii_example/page/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class UserImageWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = StreamChat.of(context).user;
    final urlImage = user.extraData['image'];

    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProfilePage(),
      )),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: CircleAvatar(
          backgroundImage: NetworkImage(urlImage),
        ),
      ),
    );
  }
}
