DataContext is a library that allows you to map your server API and create a context containing all your data. It encapsulates a HttpClient that makes the necessary IO thing to send and fetch your data to and from the API. It also enables you to add relations to your DataSets so that you can navigate easily through the DataContext. In additon, alongside the 'provider' package, you can also add the DataContext to your widget tree, in order to access your data from anywhere in your app.

To map an enpoint of your API, you have to first create a class that extends DataContext and override the origin property. Then create another class with the properties related to your endpoint. This class must extend DataClass so that the magic works. After that, you can declare a DataSet with the type you created and your endpoint route inside your DataContext. 
Each DataSet created inside your DataContext comes with CRUD methods and ValueNotifiers of type LoadStatus(INITIAL, LOADED, LOADING, FAILED) so that you monitor each step of the IO process. At the moment, you can monitor the load process, triggered by get() and getOne() methods, change process, triggered by add() and update() methods, and deletion process, triggered by the remove() method.
## Usage

In this example, there's an app that shows restaurants and the food they provide. The data is fetched form an hypotetical API. 


Firts, there must be two classes extending the DataClass interface provider by our package

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

Using these data classes, a DataContext is needed, in which the restaurant has foods as a child model. For that, a class must extend the DataContext class, provided by our package

```dart
import 'package:data_context/data_context.dart';
class MyContext extends DataContext {

  DataSet<Restaurant> restaurants = DataSet<Restaurant>(Restaurant(), route: '/restaurants')
    .addChild('foods', Food(), '/restaurants/:parentId/foods');

  @override
  String origin = 'https://localhost/api';
}
```


In order to access the DataContext from anywhere in the Flutter app, the DataContext provider has to be added to the top of the widget tree using the provider package
```dart
import 'package:data_context/data_context.dart';
import 'package:provider/provider.dart';
void main(){
  runApp(ChangeNotifierProvider(create: (context) => ComiesController(), child: MyApp()));
}
```

After the DataContext is all set up, it can be called just like the example widget below
```dart
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
                    onPressed: () => myContext.restaurants.rel<Food>('foods', parentId: restaurant.id).get()
                      .then((f) => foods = f),
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
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/eakeur/data_context/issues
