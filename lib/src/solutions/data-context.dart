import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class DataContext extends ChangeNotifier {
  abstract String origin;

  void setHeader(String key, String value) => DataContextGlobalResources.headers[key] = value;

  void clearHeaders() => DataContextGlobalResources.headers.clear();

  void changeOrigin(String newOrigin) => DataContextGlobalResources.dataOrigin = newOrigin;

  static T of<T extends DataContext>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }
}

class DataContextGlobalResources {
  static void Function(Response) bodyParser = (res) => jsonDecode(res.body);

  static String dataOrigin = '';

  static Map<String, String> headers = {};
}
