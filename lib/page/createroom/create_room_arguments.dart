import 'package:chat_ui_stream_iii_example/model/user.dart';
import 'package:meta/meta.dart';

class CreateRoomArguments {
  final List<User> members;

  const CreateRoomArguments({
    @required this.members,
  });
}
