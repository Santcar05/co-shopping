import 'dart:async';
import 'dart:convert';
import 'package:co_shopping/data/remote/p2p/p2p_repository.dart';

import '../../data/models/shopping_item.dart';
import '../../data/repositories/shopping_item_repository.dart';

class SyncManager {
  final ShoppingItemRepository _isarRepo;
  final P2PRepository _p2pRepo;

  StreamSubscription<List<ShoppingItem>>? _isarSubscription;
  bool _isProcessingRemoteUpdate = false;

  SyncManager(this._isarRepo, this._p2pRepo);

  void initialize() {
    // 1. Escuchar cambios de Isar y enviarlos al peer
    _isarSubscription = _isarRepo.watchAllActive().listen((items) {
      if (_isProcessingRemoteUpdate) return; // Evitar eco de mensajes

      _broadcastSync(items);
    });

    // 2. Configurar el callback para recibir actualizaciones del peer
    _p2pRepo.initializeSync(onItemsReceived: (dynamic payload) async {
      await _handleIncomingSync(payload);
    });
  }

  /// Envía el estado actual al peer con el formato JSON solicitado
  Future<void> _broadcastSync(List<ShoppingItem> items) async {
    final message = {
      'type': 'SYNC',
      'items': items.map((e) => e.toJson()).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    try {
      // Usamos el webRTCService a través del repositorio
      // Nota: Asegúrate de que P2PRepository exponga un método para enviar Map/JSON
      await _p2pRepo.sendRawData(message);
    } catch (e) {
      print('SyncManager: Error enviando broadcast: $e');
    }
  }

  /// Procesa el mensaje SYNC entrante y mergea con LWW
  Future<void> _handleIncomingSync(dynamic payload) async {
    if (payload is! Map<String, dynamic> || payload['type'] != 'SYNC') return;

    _isProcessingRemoteUpdate = true;
    try {
      final List<dynamic> itemsJson = payload['items'] as List<dynamic>;
      final remoteItems = itemsJson
          .map((json) => ShoppingItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      // 3. Resolver conflictos: mergeFromRemote ya usa LWW basado en updatedAt
      await _isarRepo.mergeFromRemote(remoteItems);

      print('SyncManager: Sincronización completada con éxito');
    } catch (e) {
      print('SyncManager: Error procesando SYNC: $e');
    } finally {
      // Pequeño delay para asegurar que los streams de Isar se calmen
      await Future.delayed(const Duration(milliseconds: 100));
      _isProcessingRemoteUpdate = false;
    }
  }

  void dispose() {
    _isarSubscription?.cancel();
  }
}
