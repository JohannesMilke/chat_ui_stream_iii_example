import 'package:chat_ui_stream_iii_example/page/home/home_page_desktop.dart';
import 'package:chat_ui_stream_iii_example/page/home/home_page_mobile.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';

class HomePage extends StatelessWidget {
  final int tabIndex;

  const HomePage({
    Key key,
    @required this.tabIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
        builder: (context, sizingInfo) => sizingInfo.isDesktop
            ? HomePageDesktop()
            : HomePageMobile(tabIndex: tabIndex),
      );
}
