import 'package:meta/meta.dart';

//? Information about 'Unit'
class Unit {
  final String name;
  final double conversion;

//? A 'Unit' stores data about name (ex: Meter) and conversion (ex: 1.0m)
  const Unit({
    @required this.name,
    @required this.conversion,
  })  : assert(name != null),
        assert(conversion != null);

//? Creates a [Unit] from JSON Object.
  Unit.fromJson(Map jsonMap)
      : assert(jsonMap['name'] != null),
        assert(jsonMap['conversion'] != null),
        name = jsonMap['name'],
        conversion = jsonMap['conversion'].toDouble();
}
