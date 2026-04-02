import 'package:isar/isar.dart';
import '../local/isar_database_service.dart';
import '../models/shopping_item.dart';

class ShoppingItemRepository {
  final Isar _isar = IsarDatabaseService.instance;

  // CREATE
  Future<void> insert(ShoppingItem item) async {
    await _isar.writeTxn(() async {
      await _isar.shoppingItems.put(item);
    });
  }

  // READ por UUID (para P2P)
  Future<ShoppingItem?> getByUuid(String uuid) async {
    return await _isar.shoppingItems.filter().uuidEqualTo(uuid).findFirst();
  }

  // READ por ID local
  Future<ShoppingItem?> getById(int id) async {
    return await _isar.shoppingItems.get(id);
  }

  // READ todas (no eliminadas)
  Future<List<ShoppingItem>> getAllActive() async {
    return await _isar.shoppingItems
        .filter()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  // READ por categoría
  Future<List<ShoppingItem>> getByCategory(String category) async {
    return await _isar.shoppingItems
        .filter()
        .categoryEqualTo(category)
        .and()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  // READ items modificados después de una fecha (para sincronización P2P)
  Future<List<ShoppingItem>> getItemsUpdatedAfter(DateTime timestamp) async {
    return await _isar.shoppingItems
        .filter()
        .updatedAtGreaterThan(timestamp)
        .findAll();
  }

  // UPDATE
  Future<void> update(ShoppingItem item) async {
    item.touch(); // Actualiza timestamp
    await _isar.writeTxn(() async {
      await _isar.shoppingItems.put(item);
    });
  }

  // SOFT DELETE (marca como eliminado, no borra físicamente)
  Future<void> softDelete(String uuid) async {
    final item = await getByUuid(uuid);
    if (item != null) {
      item.isDeleted = true;
      item.touch();
      await _isar.writeTxn(() async {
        await _isar.shoppingItems.put(item);
      });
    }
  }

  // DELETE físico (solo para limpieza interna)
  Future<void> delete(int localId) async {
    await _isar.writeTxn(() async {
      await _isar.shoppingItems.delete(localId);
    });
  }

  // STREAM para reactividad (UI se actualiza automáticamente)
  Stream<List<ShoppingItem>> watchAllActive() {
    return _isar.shoppingItems
        .filter()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  // STREAM por categoría
  Stream<List<ShoppingItem>> watchByCategory(String category) {
    return _isar.shoppingItems
        .filter()
        .categoryEqualTo(category)
        .and()
        .isDeletedEqualTo(false)
        .sortByUpdatedAtDesc()
        .watch(fireImmediately: true);
  }

  // Bulk insert/update para sincronización P2P (merge)
  Future<void> mergeFromRemote(List<ShoppingItem> remoteItems) async {
    await _isar.writeTxn(() async {
      for (final remote in remoteItems) {
        // Buscar si existe localmente
        final local = await _isar.shoppingItems
            .filter()
            .uuidEqualTo(remote.uuid)
            .findFirst();

        if (local == null) {
          // Nuevo item del peer
          remote.localId = Isar.autoIncrement; // Isar asignará nuevo ID local
          await _isar.shoppingItems.put(remote);
        } else {
          // Conflicto: resolver por timestamp (Last Write Wins)
          if (remote.updatedAt.isAfter(local.updatedAt)) {
            remote.localId = local.localId; // Preservar ID local
            await _isar.shoppingItems.put(remote);
          }
          // Si local es más nuevo, ignorar remoto
        }
      }
    });
  }
}
