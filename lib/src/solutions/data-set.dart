import 'dart:collection';
import 'dart:convert';
import 'package:datacontext/src/models.dart';
import 'package:datacontext/src/solutions.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

class DataSet<Model extends DataClass> extends ChangeNotifier implements DataProvider<Model> {
  final http.Client _server;

  final void Function(http.Response) _bodyParser;

  final Model _data;

  final Map<String, DataSet> _children = {};

  late Map<String, String> _lastRequestHeaders;

  String _route;

  UnmodifiableMapView get lastRequestHeaders => UnmodifiableMapView(_lastRequestHeaders);

  DataSet(Model instance, {required String route, Map<String, dynamic> Function(http.Response)? bodyParser})
      : _server = http.Client(),
        _route = route,
        _bodyParser = bodyParser ?? DataContextGlobalResources.bodyParser,
        _data = instance;

  @override
  Future<Model> add(Model data) async {
    try {
      _startLoading(changeStatus);
      var uri = Uri.parse(_origin + _route);
      var body = data.toJson();
      var result = await _server.post(uri, body: body, headers: DataContextGlobalResources.headers);
      _lastRequestHeaders = result.headers;
      _bodyParser(result);
      var res = _data.fromMap(jsonDecode(result.body) as Map<String, dynamic>) as Model;
      _succeedLoading(changeStatus);
      return res;
    } catch (e) {
      _failLoading(changeStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<List<Model>> get({Map<String, dynamic> filters = const {}}) async {
    try {
      _startLoading(loadStatus);
      var queryParams = _generateQueryParameters(filters);
      var uri = Uri.parse(_origin + _route + queryParams);
      var result = await _server.get(uri, headers: DataContextGlobalResources.headers);
      _lastRequestHeaders = result.headers;
      _bodyParser(result);
      var res = (jsonDecode(result.body) as List<Map<String, dynamic>>).map((e) => _data.fromMap(e));
      _succeedLoading(loadStatus);
      return res.toList() as List<Model>;
    } catch (e) {
      _failLoading(loadStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Model> getOne(dynamic uniqueID) async {
    try {
      _startLoading(loadStatus);
      var uri = Uri.parse(_origin + _route + '/$uniqueID');
      var result = await _server.get(uri, headers: DataContextGlobalResources.headers);
      _lastRequestHeaders = result.headers;
      _bodyParser(result);
      var res = _data.fromMap(jsonDecode(result.body) as Map<String, dynamic>) as Model;
      _succeedLoading(loadStatus);
      return res;
    } catch (e) {
      _failLoading(loadStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> update(dynamic uniqueID, Model data) async {
    try {
      _startLoading(changeStatus);
      var uri = Uri.parse(_origin + _route + '/$uniqueID');
      var body = data.toJson();
      var result = await _server.put(uri, body: body, headers: DataContextGlobalResources.headers);
      _lastRequestHeaders = result.headers;
      _bodyParser(result);
      _succeedLoading(changeStatus);
    } catch (e) {
      _failLoading(changeStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> remove(dynamic uniqueID) async {
    try {
      _startLoading(deletionStatus);
      var uri = Uri.parse(_origin + _route + '/$uniqueID');
      var result = await _server.delete(uri, headers: DataContextGlobalResources.headers);
      _lastRequestHeaders = result.headers;
      _bodyParser(result);
      _succeedLoading(deletionStatus);
    } catch (e) {
      _failLoading(deletionStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  DataSet<Model> addChild<T extends DataClass>(String relationName, T instance, String routeTemplate) {
    var child = DataSet<T>(instance, route: routeTemplate);
    if (_children[relationName] != null) throw Exception();
    _children[relationName] = child;
    return this;
  }

  DataSet<T> rel<T extends DataClass>(String relationName, {dynamic parentId}) {
    if (_children[relationName] == null) throw Exception();
    var child = _children[relationName] as DataSet<T>;
    var route = child._route;
    if (parentId != null) route.replaceAll(':parentId', parentId);
    child.updateRoute(route);
    return child;
  }

  String _generateQueryParameters(Map<String, dynamic> map) => map.keys.reduce((value, key) => value == '' ? value += '?$key=${map[key]}' : '&$key=${map[key]}');

  void updateRoute(String newRoute) => _route = newRoute;
  void _startLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.LOADING;
  void _succeedLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.LOADING;
  void _failLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.LOADING;

  String get _origin => DataContextGlobalResources.dataOrigin;

  @override
  ValueNotifier<LoadStatus> changeStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);

  @override
  ValueNotifier<LoadStatus> deletionStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);

  @override
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);
}
