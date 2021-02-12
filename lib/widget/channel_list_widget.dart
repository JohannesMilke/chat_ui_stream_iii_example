import 'package:chat_ui_stream_iii_example/page/chat/chat_page_mobile.dart';
import 'package:chat_ui_stream_iii_example/widget/profile_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

import '../provider/channel_provider.dart';

class ChannelListWidget extends StatelessWidget {
  final Channel channel;

  const ChannelListWidget({
    Key key,
    @required this.channel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = channel.extraData['name'];
    final urlImage = channel.extraData['image'];

    final hasMessage = channel.state.messages.isNotEmpty;
    final lastMessage = hasMessage ? channel.state.messages.last.text : '';
    final lastMessageAt = _formatDateTime(channel.lastMessageAt);

    return buildChannel(
      context,
      channel: channel,
      name: name,
      urlImage: urlImage,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
    );
  }

  Widget buildChannel(
    BuildContext context, {
    @required Channel channel,
    @required String name,
    @required String urlImage,
    @required String lastMessage,
    @required String lastMessageAt,
  }) =>
      ListTile(
        onTap: () {
          final isMobile = getDeviceType(MediaQuery.of(context).size) ==
              DeviceScreenType.mobile;
          final provider = Provider.of<ChannelProvider>(context, listen: false);

          if (isMobile) {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => ChatPageMobile(channel: channel),
            ));
          } else {
            provider.setChannel(channel);
          }
        },
        leading: ProfileImageWidget(imageUrl: urlImage),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Row(
          children: [
            Expanded(child: Text(lastMessage)),
            Text(lastMessageAt),
          ],
        ),
      );

  String _formatDateTime(DateTime lastMessageAt) {
    if (lastMessageAt == null) return '';

    final isRecently = lastMessageAt.difference(DateTime.now()).inDays == 0;
    final dateFormat = isRecently ? DateFormat.jm() : DateFormat.MMMd();

    return dateFormat.format(lastMessageAt);
  }
}
