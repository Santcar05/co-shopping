import 'package:co_shopping/data/models/shopping_item.dart';

class ShoppingList {
  final String id;
  final String name;
  final List<ShoppingItem> items;

  ShoppingList({
    required this.id,
    required this.name,
    required this.items,
  });
}
