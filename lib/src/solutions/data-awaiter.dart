import 'dart:convert';
import 'package:datacontext/datacontext.dart';

class DataAwaiter<T extends DataClass> {
  final String json;

  dynamic value;

  bool get isList {
    try {
      if (value == null) return false;
      return (value as List) is List;
    } catch (e) {
      return false;
    }
  }

  dynamic data;

  DataAwaiter(this.json);

  DataAwaiter<T> load() {
    try {
      if (json.isEmpty) throw MalformedJsonException(json: json);
      value = jsonDecode(json);
      return this;
    } catch (e) {
      throw MalformedJsonException(json: json);
    }
  }

  List<T> getList(T Function(Map<String, dynamic>) parser) {
    if (isList) return (value as List).map((e) => parser(e)).toList();
    throw ArgumentError('Ops! Tried to convert data to list, but data was not at list. It is actually ${value.runtimeType.toString()}');
  }

  T getModel(T Function(Map<String, dynamic>) parser) {
    if (!isList) return parser(value);
    throw ArgumentError('Ops! Tried to convert list to class, but data was a list.');
  }
}
