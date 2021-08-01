import 'package:datacontext/datacontext.dart';
import 'package:flutter/widgets.dart';

abstract class DataProvider<T extends DataClass> {
  abstract final ValueNotifier<LoadStatus> changeStatus;

  abstract final ValueNotifier<LoadStatus> deletionStatus;

  abstract final ValueNotifier<LoadStatus> loadStatus;

  /// This list stores data fetched by a data provider or setted by other source
  abstract List<T> list;

  /// This object stores typed data fetched by a data provider or setted by other source
  T? get data;

  /// Sets the model to the model passed as parameter and notifier any listener
  set data(T? data);

  void create(T data);

  Future<void> add(T data);

  Future<List<T>> get({Map<String, dynamic> filters});

  Future<T> getOne(dynamic uniqueID);

  Future<void> update(dynamic uniqueID, T data);

  Future<void> remove(dynamic uniqueID);
}
