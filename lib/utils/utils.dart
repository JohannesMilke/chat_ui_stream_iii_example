import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class Utils {
  static DateTime toDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value);
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toIso8601String();
  }

  static List<Map<String, dynamic>> toJsonList<E>(json) => json == null
      ? []
      : json
          .map<Map<String, dynamic>>((map) => Map<String, dynamic>.from(map))
          .toList();
}
