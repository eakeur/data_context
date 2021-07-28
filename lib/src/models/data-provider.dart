import 'package:datacontext/src/models.dart';
import 'package:flutter/widgets.dart';

abstract class DataProvider<T extends DataClass> {
  abstract final ValueNotifier<LoadStatus> changeStatus;

  abstract final ValueNotifier<LoadStatus> deletionStatus;

  abstract final ValueNotifier<LoadStatus> loadStatus;

  Future<void> add(T data);

  Future<List<T>> get(Map<String, dynamic> filters);

  Future<T> getOne(dynamic uniqueID);

  Future<void> update(dynamic uniqueID, T data);

  Future<void> remove(dynamic uniqueID);
}
