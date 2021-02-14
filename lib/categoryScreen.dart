import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'api.dart';
import 'backdrop.dart';
import 'categoryWidget.dart';
import 'categoryTile.dart';
import 'unit.dart';
import 'unitConverter.dart';

//? loads in unit conversion data, and displays the data.
//?
//? This is the main screen to our app. It retrieves conversion data from a
//? JSON asset and from an API. it displays the [Categories] in the back panel
//? of a [Backdrop] widget and shows the [Unit Converter] in the front panel.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen();

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  Category _defaultCategory;
  Category _currentCategory;
  //? Widget are supposed to be deeply immutable objects. We can update and edit
  //? _categories as we build our app, and when we pass it into a widget's
  //? 'children' property, we call .toList() on it.
  final _categories = <Category>[];

  //? Colors for [Categories]
  static const _baseColors = <ColorSwatch>[
    //? Color 1
    ColorSwatch(0xFF00FFCC, {
      'highlight': Color(0xFF00FFCC),
      'splash': Color(0xFF62FFE2),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 2
    ColorSwatch(0xFFFF9900, {
      'highlight': Color(0xFFFF9900),
      'splash': Color(0xFFFFC164),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 3
    ColorSwatch(0xFFFC78BE, {
      'highlight': Color(0xFFFC78BE),
      'splash': Color(0xFFFF94CBF),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 4
    ColorSwatch(0xFF4BA7F7, {
      'highlight': Color(0xFF4BA7F7),
      'splash': Color(0xFFA9CAE8),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 5
    ColorSwatch(0xFFFFCF20, {
      'highlight': Color(0xFFFFCF20),
      'splash': Color(0xFFFFE070),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 6
    ColorSwatch(0xFF7FFC40, {
      'highlight': Color(0xFF7FFC40),
      'splash': Color(0xFF7CC159),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 7
    ColorSwatch(0xFFC245FC, {
      'highlight': Color(0xFFC245FC),
      'splash': Color(0xFFCA90E5),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
    //? Color 8
    ColorSwatch(0xFFFF3939, {
      'highlight': Color(0xFFFF3939),
      'splash': Color(0xFFF94D56),
      'error': Color(0xFFFF0000),
      // 'arrows': Color(0xFF20877E),
      // 'border': Color(0xFF20877E)
    }),
  ];

  //? Add Icons for every category selection according to their arrangement
  static const _icons = <String>[
    'assets/icons/length.png',
    'assets/icons/area.png',
    'assets/icons/volume.png',
    'assets/icons/mass.png',
    'assets/icons/time.png',
    'assets/icons/digitalStorage.png',
    'assets/icons/power.png',
    'assets/icons/currency.png',
  ];

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    //? We have static unit conversions located in our
    //? assets/data/regularUnits.json
    //? We also want to obtain up-to-date Currency Conversion from the web
    //? We only want to load our data once
    if (_categories.isEmpty) {
      await _retrieveLocalCategories();
      await _retreiveApiCategory();
    }
  }

  //? Retrieve a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    //? Consider omitting the types for local variables.
    final json = DefaultAssetBundle.of(context)
        .loadString('assets/data/goofyUnits.json');
    final data = JsonDecoder().convert(await json);
    if (data is! Map) {
      throw ('Data retrieved from API is not a Map');
    }

    var categoryIndex = 0;
    data.keys.forEach((key) {
      final List<Unit> units =
          data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();

      var category = Category(
        name: key,
        units: units,
        color: _baseColors[categoryIndex],
        iconLocation: _icons[categoryIndex],
      );

      setState(() {
        if (categoryIndex == 0) {
          _defaultCategory = category;
        }
        _categories.add(category);
      });
      categoryIndex += 1;
    });
  }

//? Retreives a [Category] and its [Unit]s from an API on the Web
  Future<void> _retreiveApiCategory() async {
    //? Add a placeholder while we fetch the Currency category using the API
    setState(() {
      _categories.add(Category(
          name: apiCategory['name'],
          color: _baseColors.last,
          units: [],
          iconLocation: _icons.last));
    });
    final api = Api();
    final jsonUnits = await api.getUnits(apiCategory['route']);
    //? If the API errors out or we have no internet connection, this category
    //? remains in placeholder mode (disabled).
    if (jsonUnits != null) {
      final units = <Unit>[];
      for (var unit in jsonUnits) {
        units.add(Unit.fromJson(unit));
      }
      setState(() {
        _categories.removeLast();
        _categories.add(Category(
            name: apiCategory['name'],
            units: units,
            color: _baseColors.last,
            iconLocation: _icons.last));
      });
    }
  }

  //? Function to call when a [Category] is tapped
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  //? Makes the correct number of rows for the list view, based on whether the
  //? device is potrait or landscape.
  //? For potrait, we use a [ListView]. For landscape, we use a [Gridview].
  Widget _buildCategoryWidgets(Orientation orientation) {
    if (orientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          var _category = _categories[index];
          return CategoryTile(
            category: _category,
            onTap:
                _category.name == apiCategory['name'] && _category.units.isEmpty
                    ? null
                    : _onCategoryTap,
          );
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        children: _categories.map((Category c) {
          return CategoryTile(
            category: c,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180.0,
          width: 180.0,
          child: CircularProgressIndicator(),
        ),
      );
    }

    //? Based on the device size, figrue out how to best lay out the list
    //? You can also use MediaQuery.of(context).size to calculate the orientation
    assert(debugCheckHasMediaQuery(context));
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );

    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? UnitConverter(category: _defaultCategory)
          : UnitConverter(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }
}
