import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class DataContext extends ChangeNotifier {

  void setHeader(String key, String value) => DataContextGlobalResources.headers[key] = value;
  void clearHeaders() => DataContextGlobalResources.headers.clear();
  void changeOrigin(String newOrigin) => DataContextGlobalResources.dataOrigin = newOrigin;
}

class DataContextGlobalResources {
  static void Function(Response) bodyParser = (res) => jsonDecode(res.body);

  static String dataOrigin = '';

  static Map<String, String> headers = {};
}
