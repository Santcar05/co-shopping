import 'package:co_shopping/data/models/shopping_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier()
      : super([
          ShoppingItem(
              id: '1',
              name: 'Organic Kale',
              subtitle: 'Added by Sarah',
              category: 'PRODUCE'),
          ShoppingItem(
              id: '2',
              name: 'Honeycrisp Apples',
              subtitle: 'AI Sorted',
              category: 'PRODUCE',
              isAI: true),
          ShoppingItem(
              id: '3',
              name: 'Pasture Raised Eggs',
              subtitle: 'Sarah got this',
              category: 'DAIRY & EGGS',
              isChecked: true),
        ]);

  void toggleItem(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isChecked: !item.isChecked) else item,
    ];
  }

  void addItem(String name, String category) {
    state = [
      ...state,
      ShoppingItem(
        id: DateTime.now().toString(),
        name: name,
        subtitle: "Added manually",
        category: category,
      )
    ];
  }

  void deleteItem(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void toggleHighlight(String id) {
    state = state
        .map((item) => item.id == id
            ? item.copyWith(isHighlighted: !item.isHighlighted)
            : item)
        .toList();
  }

  void editItem(String id, String newName) {
    state = state
        .map((item) => item.id == id ? item.copyWith(name: newName) : item)
        .toList();
  }
}

final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  return ShoppingListNotifier();
});
