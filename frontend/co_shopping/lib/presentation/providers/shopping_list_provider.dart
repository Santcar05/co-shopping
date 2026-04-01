import 'package:co_shopping/data/models/shopping_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Definimos el StateNotifier para manejar la lógica
class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingListNotifier()
      : super([
          ShoppingItem(
            id: '1',
            name: 'Organic Kale',
            subtitle: 'Added by Sarah',
            category: 'PRODUCE',
          ),
          ShoppingItem(
            id: '2',
            name: 'Honeycrisp Apples',
            subtitle: 'AI Sorted',
            category: 'PRODUCE',
            isAI: true,
          ),
          ShoppingItem(
            id: '3',
            name: 'Pasture Raised Eggs',
            subtitle: 'Sarah got this',
            category: 'DAIRY & EGGS',
            isChecked: true,
          ),
        ]);

  // Función para alternar el estado de un item
  void toggleItem(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(isChecked: !item.isChecked) else item,
    ];
    // TODO: Aquí llamarías al SyncEngine para enviar el cambio por WebRTC
  }

  // Función para agregar desde el Smart Refill
  void addItem(ShoppingItem item) {
    state = [...state, item];
  }
}

// El provider que usaremos en la UI
final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  return ShoppingListNotifier();
});
