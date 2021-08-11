import 'package:datacontext/datacontext.dart';
import 'package:flutter/widgets.dart';

import 'data-context.dart';

class DataSet<Model extends DataClass> extends ChangeNotifier implements DataProvider<Model> {
  final Model _instance;

  final Map<String, DataSet> _children = {};

  late Model Function(Map<String, dynamic>) _parser;

  late DataFetcher _fetcher;

  String _route;

  DataSet(Model instance, {required String route, String? origin})
      : _instance = instance,
        _route = route {
    _parser = (map) => _instance.fromMap(map) as Model;
    _fetcher = DataFetcher(
      onSending: (a, b, c, d) => DataContextGlobalResources.context.resources.onSending(a, b, c, d),
      onReceiving: (res) {
        _setTotalCount(res.headers['x-total-count']);
        DataContextGlobalResources.context.resources.onReceiving(res);
      },
    );
  }

  @override
  void create(Model? model) {
    data = model ?? _instance;
  }

  @override
  Future<void> add(Model model) async {
    try {
      _startLoading(changeStatus);
      var res = (await _fetcher.add<Model>(_route, model)).load();
      var mod = res.getModel(_parser);
      data = mod;
      _succeedLoading(changeStatus);
    } catch (e) {
      _failLoading(changeStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<List<Model>> get({Map<String, dynamic> filters = const {}, bool cache = true}) async {
    try {
      _startLoading(loadStatus);
      var res = (await _fetcher.get<Model>(_route, filters)).load();
      if (res.isList) {
        var li = res.getList(_parser);
        if (cache) {
          li.forEach((el) {
            if (!list.contains(el)) list.add(el);
          });
        }
        _succeedLoading(loadStatus);
        return li;
      }
      throw ArgumentError.value(res.data, 'data', 'Error while fetching list');
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
      var res = (await _fetcher.get<Model>('$_route/$uniqueID', {})).load();
      var mod = res.getModel(_parser);
      data = mod;
      _succeedLoading(loadStatus);
      return mod;
    } catch (e) {
      _failLoading(loadStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> update(dynamic uniqueID, Model model) async {
    try {
      _startLoading(changeStatus);
      await _fetcher.update<Model>('$_route/$uniqueID', model);
      data = model;
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
      await _fetcher.remove<Model>('$_route/$uniqueID');
      _succeedLoading(deletionStatus);
    } catch (e) {
      _failLoading(deletionStatus);
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Relations feature
  DataSet<Model> addChild<T extends DataClass>(String relationName, T instance, String routeTemplate) {
    var child = DataSet<T>(instance, route: routeTemplate);
    if (_children[relationName] != null) throw Exception();
    _children[relationName] = child;
    return this;
  }

  DataSet<T> rel<T extends DataClass>(String relationName, {dynamic parentId}) {
    if (_children[relationName] == null) throw Exception();
    var child = _children[relationName] as DataSet<T>;
    if (parentId != null) {
      child.updateRoute(child._route.replaceAll(':parentId', parentId));
    }
    return child;
  }

  DataSet<Model> replicate() {
    return DataSet(_instance, route: _route);
  }

  // Internal utils
  void updateRoute(String newRoute) => _route = newRoute;

  void _setTotalCount(String? value) => totalRecords = int.tryParse(value ?? '') ?? totalRecords;

  void _startLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.LOADING;

  void _succeedLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.LOADED;

  void _failLoading(ValueNotifier<LoadStatus> not) => not.value = LoadStatus.FAILED;

  //Overrides
  @override
  ValueNotifier<LoadStatus> changeStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);

  @override
  ValueNotifier<LoadStatus> deletionStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);

  @override
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier<LoadStatus>(LoadStatus.INITIAL);

  /// This property stores whichever views from the main list. We recommend using it for storing functions that return a different perspective of the list property
  @override
  Map<String, dynamic> localViews = <String, List<Model> Function()>{};

  @override
  Map<String, dynamic> local = <String, dynamic>{};

  /// This list stores data fetched by a data provider or setted by other source
  @override
  List<Model> list = <Model>[];

  /// This object stores typed data fetched by a data provider or setted by other source
  @override
  Model? data;

  /// Total records available in the remote server;
  int totalRecords = 0;

  /// Clears all data from the list and notifies listeners
  void clearList() {
    list.clear();
    notifyListeners();
  }

  /// Clears the model and notifies listeners
  void clearModel() => data = null;
}
