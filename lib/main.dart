import 'package:chat_ui_stream_iii_example/api/stream_api.dart';
import 'package:chat_ui_stream_iii_example/api/stream_user_api.dart';
import 'package:chat_ui_stream_iii_example/app_routes.dart';
import 'package:chat_ui_stream_iii_example/page/auth_page.dart';
import 'package:chat_ui_stream_iii_example/page/createroom/create_room_arguments.dart';
import 'package:chat_ui_stream_iii_example/page/createroom/create_room_page.dart';
import 'package:chat_ui_stream_iii_example/page/home/home_page.dart';
import 'package:chat_ui_stream_iii_example/page/home/home_page_mobile.dart';
import 'package:chat_ui_stream_iii_example/page/participants_page.dart';
import 'package:chat_ui_stream_iii_example/provider/channel_provider.dart';
import 'package:chat_ui_stream_iii_example/provider/google_signin_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Run web app: flutter run -d chrome --web-port 5000
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final String title = 'Facebook Messenger';

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => GoogleSignInProvider()),
          ChangeNotifierProvider(create: (context) => ChannelProvider()),
        ],
        builder: (context, _) => StreamChat(
          streamChatThemeData: StreamChatThemeData(),
          client: StreamApi.client,
          child: ChannelsBloc(
            child: MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              title: title,
              theme: ThemeData(
                primaryColor: Colors.white,
              ),
              initialRoute: getInitialRoute(),
              onGenerateRoute: (route) => getRoute(route),
            ),
          ),
        ),
      );

  String getInitialRoute() => AppRoutes.auth;

  Route getRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return buildRoute(AuthPage(), settings: settings);
      case AppRoutes.home:
        return buildRoute(HomePage(tabIndex: 0), settings: settings);
      case AppRoutes.people:
        return buildRoute(HomePage(tabIndex: 1), settings: settings);
      case AppRoutes.participants:
        return buildRoute(ParticipantsPage(), settings: settings);
      case AppRoutes.createRoom:
        final CreateRoomArguments args = settings.arguments;

        return buildRoute(
          CreateRoomPage(participants: args.members),
          settings: settings,
        );

      default:
        return null;
    }
  }

  MaterialPageRoute buildRoute(Widget child, {RouteSettings settings}) =>
      MaterialPageRoute(settings: settings, builder: (context) => child);
}
