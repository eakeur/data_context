import 'dart:convert';
import 'package:datacontext/datacontext.dart';
import 'package:flutter/material.dart';
import 'package:http/src/response.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context) => MyContext(), child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late DataSet<Restaurant> restaurants;

  @override
  void initState() {
    super.initState();
    restaurants = DataContext.of<MyContext>(context).restaurants;
    restaurants.get();
  }

  @override
  Widget build(BuildContext context) {
    return LoadStatusWidget(
        status: restaurants.loadStatus,
        loadWidget: (context) => ListView(
              children: restaurants.list
                  .map(
                    (restaurant) => TextButton(
                      onPressed: () => restaurants.rel<Food>('foods', parentId: restaurant.id).get(),
                      child: Text(restaurant.name ?? 'No name'),
                    ),
                  )
                  .toList(),
            ));
  }
}

class MyContext extends DataContext {
  DataSet<Restaurant> restaurants = DataSet<Restaurant>(Restaurant(), route: '/restaurants').addChild('foods', Food(), '/restaurants/:parentId/foods');

  @override
  String origin = 'https://localhost/api';

  String? token;

  @override
  void onReceiving(Response response) {
    print('RESULT: ${response.statusCode} - REQUEST: ${response.request!.url.toString()}');
  }

  @override
  void onSending(Uri uri, Map<String, String> headers, Map<String, dynamic>? data, DataOperation operation) {
    if (token != null) setHeader('Authorization', token!);
  }
}

class Food extends DataClass {
  String? id;
  String? name;
  double? price;

  Food({this.id, this.name, this.price});

  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};
  @override
  Food fromMap(Map<String, dynamic> map) => Food.fromMap(map);
  @override
  String toJson() => json.encode(toMap());

  factory Food.fromMap(Map<String, dynamic> map) => Food(id: map['id'], name: map['name'], price: map['price']);
  factory Food.fromJson(String source) => Food.fromMap(json.decode(source));
}

class Restaurant extends DataClass {
  String? id;
  String? name;

  Restaurant({this.id, this.name});

  @override
  Map<String, dynamic> toMap() => {'id': id, 'name': name};
  @override
  Restaurant fromMap(Map<String, dynamic> map) => Restaurant.fromMap(map);
  @override
  String toJson() => json.encode(toMap());

  factory Restaurant.fromMap(Map<String, dynamic> map) => Restaurant(id: map['id'], name: map['name']);
  factory Restaurant.fromJson(String source) => Restaurant.fromMap(json.decode(source));
}
