abstract class DataClass {
  DataClass();
  
  Map<String, dynamic> toMap();

  String toJson();

  DataClass fromMap(Map<String, dynamic> map);

  DataClass.fromMap(Map<String, dynamic> map);

  DataClass.fromJson(String source);
}
