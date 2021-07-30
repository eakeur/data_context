import 'package:datacontext/datacontext.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class DataContext extends ChangeNotifier {
  abstract String origin;

  abstract void Function(Uri, Map<String, String>, Map<String, dynamic>?, DataOperation) onSending;

  abstract void Function(Response) onReceiving;

  DataContext() {
    DataContextGlobalResources.onSending = onSending;
    DataContextGlobalResources.onReceiving = onReceiving;
    DataContextGlobalResources.dataOrigin = origin;
  }

  void setHeader(String key, String value) => DataContextGlobalResources.headers[key] = value;

  void clearHeaders() => DataContextGlobalResources.headers.clear();

  void changeOrigin(String newOrigin) => DataContextGlobalResources.dataOrigin = newOrigin;

  static T of<T extends DataContext>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }
}

class DataContextGlobalResources {
  static String dataOrigin = '';

  static void Function(Uri, Map<String, String>, Map<String, dynamic>?, DataOperation) onSending = (a, b, c, d) {};

  static void Function(Response) onReceiving = (a) {};

  static Map<String, String> headers = {};
}
