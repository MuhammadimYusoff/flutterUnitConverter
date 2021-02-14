import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'categoryWidget.dart';

const _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

//? A [Category Tile] to display a [Category].
class CategoryTile extends StatelessWidget {
  final Category category;
  final ValueChanged<Category> onTap;

  //? The [CategoryTile] showws the name and color of a [Category] for unit
  //? conversions.
  //?
  //?Tapping on it brings you to the unit converter.
  const CategoryTile({
    Key key,
    @required this.category,
    this.onTap,
  })  : assert(category != null),
        super(key: key);

  //? Builds a custom widget that shows [Category] information.
  //? This information includes the icon, name and color for the [Category].
  @override
  //? This 'context' parameter describes the location of thid widget in the
  //? widget tree. it can be used for obtaining Theme data from the nearest
  //? Theme ancestor in the tree. Below, we obtain the display1 text theme.
  Widget build(BuildContext context) {
    return Material(
      color:
          onTap == null ? Color.fromRGBO(50, 50, 50, 0.2) : Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
          borderRadius: _borderRadius,
          highlightColor: category.color['highlight'],
          splashColor: category.color['splash'],
          //? We can use either the () => function() or the () {function();}
          //? syntax
          onTap: onTap == null ? null : () => onTap(category),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              //? There are two ways to denote a list: '[]' and 'List()'.
              //? Prefer to use the literal syntax '[]'.
              //? You can add the type argument if you'd like, <Widget>[]
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Image.asset(category.iconLocation),
                ),
                Center(
                  child: Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
