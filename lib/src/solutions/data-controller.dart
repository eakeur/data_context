import 'package:datacontext/datacontext.dart';
import 'package:flutter/widgets.dart';

/// Stores data classes into lists or model views and allows objects to listen to changes on this object
class DataController<T extends DataClass> extends ChangeNotifier {
  /// This list stores data fetched by a data provider or setted by other source
  List<T> list = <T>[];

  /// This object stores typed data fetched by a data provider or setted by other source
  T? _model;

  /// Total records available in the remote server;
  int totalRecords = 0;

  /// This object stores typed data fetched by a data provider or setted by other source
  T? get model => _model;

  /// Sets the model to the model passed as parameter and notifier any listener
  void setModel(T mod) {
    _model = mod;
    notifyListeners();
  }

  /// Clears all data from the list and notifies listeners
  void clearList() {
    list.clear();
    notifyListeners();
  }

  /// Clears the model and notifies listeners
  void clearModel() {
    _model = null;
    notifyListeners();
  }
}
