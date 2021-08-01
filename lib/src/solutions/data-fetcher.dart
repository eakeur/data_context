import 'package:datacontext/datacontext.dart';
import 'package:http/http.dart';

import 'data-awaiter.dart';
import 'data-context.dart';

class DataFetcher {
  final void Function(Uri, Map<String, String>, Map<String, dynamic>?, DataOperation)? onSending;

  final void Function(Response)? onReceiving;

  Map<String, String> get headers => DataContextGlobalResources.context.resources.headers;

  String get path => DataContextGlobalResources.context.resources.data['origin']!;

  final Client client;

  DataFetcher({this.onSending, this.onReceiving}) : client = Client();

  Future<DataAwaiter<T>> get<T extends DataClass>(String route, Map<String, dynamic> query) async {
    var uri = mountUri(route, query);
    if (onSending != null) onSending!(uri, headers, query, DataOperation.GET);
    var response = await client.get(uri, headers: headers);
    if (onReceiving != null) onReceiving!(response);
    return DataAwaiter<T>(response.body);
  }

  Future<DataAwaiter<T>> add<T extends DataClass>(String route, T data) async {
    var uri = mountUri(route, {});
    if (onSending != null) onSending!(uri, headers, null, DataOperation.ADD);
    var body;
    try {
      body = data.toJson();
    } catch (e) {
      throw ArgumentError('Failed converting data to JSON: ${data.toString()}');
    }
    var response = await client.post(uri, body: body as String, headers: headers);
    if (onReceiving != null) onReceiving!(response);
    return DataAwaiter<T>(response.body);
  }

  Future<DataAwaiter<T>> update<T extends DataClass>(String route, T data) async {
    var uri = mountUri(route, {});
    if (onSending != null) onSending!(uri, headers, null, DataOperation.UPDATE);
    var body;
    try {
      body = data.toJson();
    } catch (e) {
      throw ArgumentError('Failed converting data to JSON: ${data.toString()}');
    }
    var response = await client.put(uri, body: body as String, headers: headers);
    if (onReceiving != null) onReceiving!(response);
    return DataAwaiter<T>(response.body);
  }

  Future<DataAwaiter<T>> remove<T extends DataClass>(String route, {T? data, Map<String, dynamic> query = const <String, String>{}}) async {
    var uri = mountUri(route, query);
    if (onSending != null) onSending!(uri, headers, query, DataOperation.REMOVE);
    var body;
    try {
      if (data != null) body = data.toJson();
    } catch (e) {
      throw ArgumentError('Failed converting data to JSON: ${data.toString()}');
    }
    var response = await client.delete(uri, body: body, headers: headers);
    if (onReceiving != null) onReceiving!(response);
    return DataAwaiter<T>(response.body);
  }

  Uri mountUri(String route, Map<String, dynamic> query) {
    var params = mountQueryParameters(query);
    var members = <String>[path, route, params];
    var url = members.reduce((val, el) => val + (el.startsWith('/') ? el : '/$el'));
    return Uri.parse(url);
  }

  String mountQueryParameters(Map<String, dynamic> map) => map.isEmpty ? '' : map.keys.reduce((value, key) => value == '' ? value += '?$key=${map[key]}' : '&$key=${map[key]}');
}
