import 'package:datacontext/datacontext.dart';
import 'package:flutter/widgets.dart';

import 'data-context.dart';

class DataSet<Model extends DataClass> extends ChangeNotifier implements DataProvider<Model> {
  final Model _instance;

  final Map<String, DataSet> _children = {};

  late Model Function(Map<String, dynamic>) _parser;

  late DataFetcher _fetcher;

  String _route;

  String get route => _route;

  String _initialRoute;

  DataSet(Model instance, {required String route, String? origin})
      : _instance = instance,
        _route = route,
        _initialRoute = route {
    _parser = (map) => _instance.fromMap(map) as Model;
    _fetcher = DataFetcher(
      customOrigin: origin,
      onSending: (a, b, c, d) => DataContextGlobalResources.context.resources.onSending(a, b, c, d),
      onReceiving: (res) {
        _setTotalCount(res.headers['x-total-count']);
        DataContextGlobalResources.context.resources.onReceiving(res);
      },
    );
    var ds = DataContextGlobalResources.context.resources.datasets[Model];
    if (ds == null) DataContextGlobalResources.context.resources.datasets[Model] = this;
  }

  static DataSet<T> of<T extends DataClass>() {
    return DataContextGlobalResources.context.resources.datasets[T] as DataSet<T>;
  }

  @override
  void create(Model? model) {
    data = model ?? _instance;
  }

  @override
  Future<void> add([Model? model]) async {
    try {
      _startLoading();
      var res = (await _fetcher.add<Model>(_route, model ?? data!)).load();
      var mod = res.getModel(_parser);
      data = mod;
      list.add(model ?? data!);
      _succeedLoading();
    } catch (e) {
      _failLoading();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<List<Model>> get({Map<String, dynamic> filters = const {}, bool cache = true}) async {
    try {
      _startLoading();
      var res = (await _fetcher.get<Model>(_route, filters)).load();
      if (res.isList) {
        var li = res.getList(_parser);
        if (cache) {
          li.forEach((el) {
            if (!list.contains(el)) list.add(el);
          });
        }
        _succeedLoading();
        return li;
      }
      throw ArgumentError.value(res.data, 'data', 'Error while fetching list');
    } catch (e) {
      _failLoading();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<Model> getOne(dynamic uniqueID) async {
    try {
      _startLoading();
      var res = (await _fetcher.get<Model>('$_route/$uniqueID', {})).load();
      var mod = res.getModel(_parser);
      data = mod;
      _succeedLoading();
      return mod;
    } catch (e) {
      _failLoading();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> update(dynamic uniqueID, [Model? model]) async {
    try {
      _startLoading();
      await _fetcher.update<Model>('$_route/$uniqueID', model ?? data!);
      data = model ?? data!;
      _succeedLoading();
    } catch (e) {
      _failLoading();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  Future<void> remove(dynamic uniqueID) async {
    try {
      _startLoading();
      await _fetcher.remove<Model>('$_route/$uniqueID');
      _succeedLoading();
    } catch (e) {
      _failLoading();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Relations feature
  /// This method registers a DataSet that will have direct relation to the dataset already instantiated. For that, it uses a relation name as a key for retrieving it later
  DataSet<Model> addChild<T extends DataClass>(String relationName, T instance, String routeTemplate) {
    var child = DataSet<T>(instance, route: routeTemplate);
    if (_children[relationName] != null) throw Exception();
    _children[relationName] = child;
    return this;
  }

  /// Returns the dataset that was stored as a child under the relation name passed as parameter
  DataSet<T> rel<T extends DataClass>(String relationName, {dynamic parentId, bool clear = true}) {
    if (_children[relationName] == null) throw Exception();
    var child = _children[relationName] as DataSet<T>;
    child.updateRoute(child._initialRoute);
    if (parentId != null) {
      child.updateRoute(child._route.replaceAll(':parentId', parentId));
    }
    if (clear) {
      child.clearList();
      child.clearModel();
      child.local = {};
      child.localViews = {};
    }
    return child;
  }

  DataSet<Model> replicate() {
    var ds = DataSet<Model>(_instance, route: _initialRoute, origin: _fetcher.path);
    _children.keys.forEach((key) => ds._children[key] = _children[key]!.replicate());
    return ds;
  }

  // Internal utils
  void updateRoute(String newRoute) => _route = newRoute;

  void _setTotalCount(String? value) => totalRecords = int.tryParse(value ?? '') ?? totalRecords;

  void _startLoading() => loadStatus.value = LoadStatus.LOADING;

  void _succeedLoading() => loadStatus.value = LoadStatus.LOADED;

  void _failLoading() => loadStatus.value = LoadStatus.FAILED;

  //Overrides

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
