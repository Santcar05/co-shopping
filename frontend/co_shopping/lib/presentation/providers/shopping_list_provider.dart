import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/shopping_item.dart';
import '../../data/repositories/shopping_item_repository.dart';

/// Notifier que actúa como puente entre la UI y Isar (Single Source of Truth)
class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  final ShoppingItemRepository _repository;
  StreamSubscription<List<ShoppingItem>>? _subscription;

  ShoppingListNotifier(this._repository) : super([]) {
    _init();
  }

  /// Se suscribe al stream de Isar para que cualquier cambio (local o P2P)
  /// actualice el estado de la UI automáticamente.
  void _init() {
    _subscription = _repository.watchAllActive().listen((items) {
      state = items;
    });
  }

  // --- ACCIONES ---
  // Nota: Todas las acciones ahora persisten en Isar.
  // No modificamos 'state' manualmente; el stream de arriba se encarga de eso.

  Future<void> addItem(String name, String category,
      {bool isAI = false}) async {
    final newItem = ShoppingItem.create(
      name: name,
      category: category,
      isAI: isAI,
      subtitle: isAI ? 'AI Suggested' : 'Added by you',
    );
    await _repository.insert(newItem);
  }

  Future<void> toggleItem(String uuid) async {
    final item = await _repository.getByUuid(uuid);
    if (item != null) {
      item.isChecked = !item.isChecked;
      await _repository.update(item);
    }
  }

  Future<void> deleteItem(String uuid) async {
    // Usamos softDelete para mantener consistencia en la sincronización P2P
    await _repository.softDelete(uuid);
  }

  Future<void> toggleHighlight(String uuid) async {
    final item = await _repository.getByUuid(uuid);
    if (item != null) {
      item.isHighlighted = !item.isHighlighted;
      await _repository.update(item);
    }
  }

  Future<void> editItem(String uuid, String newName) async {
    final item = await _repository.getByUuid(uuid);
    if (item != null) {
      item.name = newName;
      await _repository.update(item);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// --- PROVIDERS ---

/// Provider para el repositorio (puedes moverlo a un archivo de repositorios si prefieres)
final shoppingRepositoryProvider = Provider<ShoppingItemRepository>((ref) {
  return ShoppingItemRepository();
});

/// Provider global de la lista de compras
final shoppingListProvider =
    StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ShoppingListNotifier(repo);
});
