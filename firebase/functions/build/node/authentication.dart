import 'dart:async';
import 'dart:convert';

import 'package:firebase_functions_interop/firebase_functions_interop.dart'
    hide Message;
import 'package:foundation/model/user_token.dart';
import 'package:foundation/request/authentication_request.dart';
import 'package:foundation/request/authentication_response.dart';

import 'stream.dart';

class Authentication {
  static void handle() {
    functions['createToken'] = functions.https.onRequest(createToken);
  }

  static Future createToken(ExpressHttpRequest request) async {
    try {
      final requestData = AuthenticationRequest.fromJson(request.body);

      print('ID USer: ${requestData.idUser}');

      if (requestData.idUser != null && requestData.idUser.isNotEmpty) {
        final idUser = requestData.idUser;
        print('Got idUser: ${idUser}');

        final token = await generateToken(idUser: idUser);

        print('Got Token: ${token}');

        final userToken = UserToken(idUser: idUser, token: token);
        final response = AuthenticationResponse(userToken: userToken);

        await _sendResponse(request, response);
      } else {
        print('Got not idUser');
        await _sendError(request);
      }
    } catch (e) {
      print('Error: $e');
      await _sendError(request);
    }

    return null;
  }

  static Future _sendError(ExpressHttpRequest request) async {
    final response = AuthenticationResponse(error: 'Some error occurred');

    await _sendResponse(request, response);
  }

  static Future _sendResponse(ExpressHttpRequest request, response) async {
    request.response.headers.add("Access-Control-Allow-Origin", "*");
    request.response.headers.add('Access-Control-Allow-Headers', '*');
    request.response.headers
        .add("Access-Control-Allow-Methods", "POST,GET,DELETE,PUT,OPTIONS");
    request.response.writeln(json.encode(response.toJson()));
    await request.response.close();
  }
}
