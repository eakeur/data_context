DataContext is a library that allows you to map your server API and create a context containing all your data. It encapsulates a HttpClient that makes the necessary IO thing to send and fetch your data to and from the API. It also enables you to add relations to your DataSets so that you can navigate easily through the DataContext. In additon, alongside the 'provider' package, you can also add the DataContext to your widget tree, in order to access your data from anywhere in your app.

Some outstanding features you might like: 
  - [Data is saved in memory and you can control them](#data_is_saved_in_memory_and_you_can_control_them)
  - [You can track the IO process in many ways](#you_can_track_the_IO_process_in_many_ways)
  - [You can use specific widgets to avoid showing broken data to users](#you_can_use_specific_widgets_to_avoid_showing_broken_data_to_users)

## Usage

To set up your application and use this package with all its features, follow these steps (after you've added it to your `pupspeck.yaml`:
  - [Build the data model](#build_the_data_model)
  - [Build the data context](#build_the_data_contex)
  - [Use it!](#use_it!)
 
Observations: To illustrate this package's features, we're building a simple app that shows restaurants and the food they provide. The data is fetched from a hypotetical API.

### Build the data model
First, your data models have to extend the abstract class DataClass, provided by our package. It implies that your classes have methods and constructors that do the parsing and (de)serialization process. But calm down, you don't need to do it with your bare hands. Check [this extension][extension] out, that creates most of the methods for you. Thus, you can install it, create your class, extend DataClass and create the methods based on this extension.

```dart
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
```

### Build the data context
In this step, create a class that extends DataContext. You will be asked to override the `String origin` property, that sets the base URL to the API, and the `onSending` and `onReceiving` methods, that are middleware-like methods that are called before and after every request, respectively.

Also, here's where you'll declare your data context properties. For each endpoint or model that you will consume from the API, create a DataSet object in this class with the parameter type of your model, just like the example below. In case the endpoint has a child or a URL like 'path/:parentId/path2/:childId', you can add a child to it with the method `.addChild()`, which is fluent. 

```dart
import 'package:data_context/data_context.dart';
class MyContext extends DataContext {

  DataSet<Restaurant> restaurants = DataSet<Restaurant>(Restaurant(), route: '/restaurants')
    .addChild('foods', Food(), '/restaurants/:parentId/foods');

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
```

### Use it!
After building up your DataContext, you can use it by accessing sn instance of it from anywhere. Dart allows you to do it in many ways. In our case, we're using it with the ChangeNotifierProvider widget that comes with the `package:provider/provider.dart` package, so that we can add it to the top of our widget tree and restore it with the `Provider.of(context)` feature.
Now, to fetch data from the API you just have to call `context.restaurants.get()`.

```dart
import 'package:datacontext/datacontext.dart';
import 'package:provider/provider.dart';
void main(){
  runApp(ChangeNotifierProvider(create: (context) => ComiesController(), child: MyApp()));
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
      )
    );
  }
}
```


## Features

### Data is saved in memory and you can control them
Every DataSet comes with the list and data properties and every request result saves the data in them. You can access it, change it and clear it when you feel like. With them, you can save up time by not creating variables everywhere in your app and also share resources with unrelated widgets.

### You can track the IO process in many ways
Every request you make can be tracked by the methods `onSending` and `onReceiving` in your data context. But also, every DataSet has these properties: 'changeStatus, loadStatus and deletionStatus'. The first one is triggered by the `add()` and `update()` process. The second, by the `get()` and `getOne()` process. The third, by the `remove()` process. Each of these properties has four states: 'initial, loaded, loading, failed'. Encapsulated with a ValueNotifier object, you can control when and how your requests are being made. With that, you know exactly what and when to show your users a widget.  

### You can use specific widgets to avoid showing broken data to users
This package also has some widgets!. With the IsNullWidget, you can track if an object is null. If so, it will render a widget and listen when the object changes value. When it does, it renders another widget of your choice.
Also, it has the LoadStatusWidget, that renders specific widgets of your choice for every LoadStatus state from statuses properties in the data sets.


Hope you like it!!!

## Bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/eakeur/data_context/issues
[extension]: https://marketplace.visualstudio.com/items?itemName=BendixMa.dart-data-class-generator
