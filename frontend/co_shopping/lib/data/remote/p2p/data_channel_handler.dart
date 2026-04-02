import 'dart:async';
import '../../models/shopping_item.dart';
import 'webrtc_service.dart';

/// Procesa mensajes del DataChannel y los routea al SyncManager
class DataChannelHandler {
  final WebRTCService _webRTCService;
  final StreamController<List<ShoppingItem>> _syncController =
      StreamController<List<ShoppingItem>>.broadcast();

  Stream<List<ShoppingItem>> get onItemsReceived => _syncController.stream;

  DataChannelHandler(this._webRTCService) {
    _webRTCService.onMessage = _handleMessage;
  }

  void _handleMessage(String type, dynamic payload) {
    switch (type) {
      case 'SYNC_ITEMS':
        // Cast explícito para evitar errores de tipo
        if (payload is List) {
          final items = payload
              .map(
                  (json) => ShoppingItem.fromJson(json as Map<String, dynamic>))
              .toList();
          _syncController.add(items);
        }
        break;

      case 'ITEM_UPDATE':
        // Cast explícito del Map
        if (payload is Map) {
          final item =
              ShoppingItem.fromJson(Map<String, dynamic>.from(payload));
          _syncController.add([item]);
        }
        break;

      case 'ITEM_DELETE':
        // Cast seguro del uuid
        if (payload is Map) {
          final uuid = payload['uuid'] as String?;
          if (uuid != null) {
            print('Remote delete requested for: $uuid');
            // TODO: Notificar al repositorio para soft delete
          }
        }
        break;

      case 'PING':
        _sendPong();
        break;

      default:
        print('Unknown message type: $type');
    }
  }

  void _sendPong() {
    _webRTCService
        .sendMessage('PONG', {'time': DateTime.now().toIso8601String()});
  }

  Future<void> requestFullSync() async {
    await _webRTCService.sendMessage('REQUEST_FULL_SYNC', <String, dynamic>{});
  }

  Future<void> sendItems(List<ShoppingItem> items) async {
    final payload = items.map((e) => e.toJson()).toList();
    await _webRTCService.sendMessage('SYNC_ITEMS', payload);
  }

  void dispose() {
    _syncController.close();
  }
}
