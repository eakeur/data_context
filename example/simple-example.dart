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
  MyContext get myContext => DataContext.of<MyContext>(context);

  List<Restaurant> restaurants = [];
  List<Food> foods = [];

  @override
  void initState() {
    super.initState();
    myContext.restaurants.get().then((r) => restaurants = r);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<LoadStatus>(
      valueListenable: myContext.restaurants.loadStatus,
      builder: (context, status, child) {
        if (status == LoadStatus.LOADING) {
          return CircularProgressIndicator();
        } else {
          return ListView(
            children: restaurants
                .map(
                  (restaurant) => TextButton(
                    onPressed: () => myContext.restaurants.rel<Food>('foods', parentId: restaurant.id).get().then((f) => foods = f),
                    child: Text(restaurant.name ?? 'No name'),
                  ),
                )
                .toList(),
          );
        }
      },
    );
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
