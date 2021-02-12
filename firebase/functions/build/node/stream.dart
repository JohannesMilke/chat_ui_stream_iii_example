@JS()
library stream;

import 'dart:async';

import 'package:js/js.dart';
import 'package:meta/meta.dart';
import 'package:node_interop/node.dart';
import 'package:node_interop/util.dart';

@JS()
@anonymous
abstract class Stream {
  external void generateToken(String idUser, doneCallback);
}

Future<String> generateToken({
  @required String idUser,
}) {
  final stream = require('./stream.js');

  final completer = Completer();
  final doneCallback = allowInterop((result) => completer.complete(result));
  stream.generateToken(idUser, doneCallback);

  return completer.future.then(dartify);
}
