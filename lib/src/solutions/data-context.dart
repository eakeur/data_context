import 'package:datacontext/datacontext.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

abstract class DataContext extends ChangeNotifier {
  late DataContextResources resources;

  abstract String origin;

  DataContext() {
    resources = DataContextResources(
      data: <String, String>{'origin': origin},
      onSending: onSending,
      onReceiving: onReceiving,
      headers: <String, String>{},
      datasets: <Type, DataSet>{},
    );
    DataContextGlobalResources.contextstore = this;
  }

  void onSending(Uri uri, Map<String, String> headers, Map<String, dynamic>? data, DataOperation operation);

  void onReceiving(Response response);

  void setHeader(String key, String value) => resources.headers[key] = value;

  void addHeaders(Map<String, String> map) => map.forEach((key, value) => resources.headers[key] = value);

  void removeHeader(String key) => resources.headers.remove(key);

  void clearHeaders() => resources.headers.clear();

  void changeOrigin(String newOrigin) => resources.data['origin'] = newOrigin;

  static T of<T extends DataContext>(BuildContext context) {
    return Provider.of<T>(context, listen: false);
  }
}

class DataContextResources {
  final Map<String, String> data;

  final void Function(Uri, Map<String, String>, Map<String, dynamic>?, DataOperation) onSending;

  final void Function(Response) onReceiving;

  final Map<String, String> headers;

  final Map<Type, DataSet> datasets;

  DataContextResources({required this.data, required this.onSending, required this.onReceiving, required this.headers, required this.datasets});
}

class DataContextGlobalResources {
  static DataContext get context => contextstore;

  static late DataContext contextstore;
}
