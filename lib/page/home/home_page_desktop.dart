import 'package:chat_ui_stream_iii_example/chats_page.dart';
import 'package:chat_ui_stream_iii_example/page/chat/chat_page_mobile.dart';
import 'package:chat_ui_stream_iii_example/provider/channel_provider.dart';
import 'package:chat_ui_stream_iii_example/widget/user_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class HomePageDesktop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedChannel =
        Provider.of<ChannelProvider>(context).selectedChannel;

    return Scaffold(
      body: Row(
        children: [
          Expanded(child: buildChats(context)),
          VerticalDivider(indent: 0, endIndent: 0, thickness: 0.5, width: 0.5),
          Expanded(flex: 3, child: buildChat(selectedChannel))
        ],
      ),
    );
  }

  Widget buildChats(BuildContext context) => Column(
        children: [
          AppBar(
            leading: UserImageWidget(),
            title: Text('Chats'),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.edit, size: 20, color: Colors.black),
              ),
              SizedBox(width: 8),
            ],
          ),
          Expanded(child: ChatsPage()),
        ],
      );

  Widget buildChat(Channel selectedChannel) {
    if (selectedChannel == null) {
      return Center(
        child: Text(
          'Select A Chat',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return ChatPageMobile(channel: selectedChannel);
  }
}
