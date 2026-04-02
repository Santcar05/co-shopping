import 'dart:async';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../signaling/signaling_client.dart';
import 'data_channel_handler.dart';
import 'p2p_states.dart';
import 'webrtc_service.dart';

/// Repositorio unificado que gestiona todo el flujo P2P
class P2PRepository {
  final SignalingClient _signaling;
  final WebRTCService _webRTC;
  DataChannelHandler? _dataHandler;

  StreamSubscription<SignalingMessage>? _signalingSub;

  final StreamController<P2PState> _stateController =
      StreamController<P2PState>.broadcast();
  Stream<P2PState> get stateStream => _stateController.stream;

  P2PState _currentState = const P2PState();

  String? _roomId;
  String _peerId = 'peer_${DateTime.now().millisecondsSinceEpoch}';
  bool _isHost = false;

  P2PRepository()
      : _signaling = SignalingClient(),
        _webRTC = WebRTCService();

  /// Conectar a sala como Host (quien crea la sala)
  Future<void> connectAsHost(String roomId) async {
    _roomId = roomId;
    _isHost = true;
    _updateState(status: P2PConnectionStatus.signaling);

    try {
      // 1. Conectar a signaling server
      await _signaling.connect('ws://localhost:8080/signaling');

      // 2. Escuchar mensajes de signaling
      _setupSignalingListeners();

      // 3. Unirse a la sala
      _signaling.joinRoom(roomId, _peerId);

      // 4. Crear oferta WebRTC
      final offer = await _webRTC.createOffer(roomId);

      // 5. Enviar oferta vía signaling (el servidor la reenviará al guest)
      _signaling.sendOffer(roomId, offer);

      _updateState(status: P2PConnectionStatus.connecting);
    } catch (e) {
      _updateState(
          status: P2PConnectionStatus.error, errorMessage: e.toString());
    }
  }

  /// Conectar a sala como Guest (quien escanea el QR)
  Future<void> connectAsGuest(String roomId) async {
    _roomId = roomId;
    _isHost = false;
    _updateState(status: P2PConnectionStatus.signaling);

    try {
      await _signaling.connect('ws://localhost:8080/signaling');
      _setupSignalingListeners();
      _signaling.joinRoom(roomId, _peerId);
      // Esperar a recibir la oferta del host...
    } catch (e) {
      _updateState(
          status: P2PConnectionStatus.error, errorMessage: e.toString());
    }
  }

  void _setupSignalingListeners() {
    _signalingSub = _signaling.messageStream.listen((message) async {
      if (message.roomId != _roomId && message.roomId.isNotEmpty) return;

      switch (message.type) {
        case SignalingMessageType.offer:
          if (!_isHost) {
            // Guest recibe oferta
            final offer = RTCSessionDescription(
              message.payload['sdp'],
              message.payload['type'],
            );
            final answer = await _webRTC.createAnswer(_roomId!, offer);
            _signaling.sendAnswer(_roomId!, answer);
            _updateState(status: P2PConnectionStatus.connecting);
          }
          break;

        case SignalingMessageType.answer:
          if (_isHost) {
            // Host recibe respuesta
            final answer = RTCSessionDescription(
              message.payload['sdp'],
              message.payload['type'],
            );
            await _webRTC.setRemoteAnswer(answer);
          }
          break;

        case SignalingMessageType.iceCandidate:
          final candidate = RTCIceCandidate(
            message.payload['candidate'],
            message.payload['sdpMid'],
            message.payload['sdpMLineIndex'],
          );
          await _webRTC.addIceCandidate(candidate);
          break;

        case SignalingMessageType.peerJoined:
          print('Peer joined: ${message.peerId}');
          _updateState(peerId: message.peerId);
          break;

        case SignalingMessageType.error:
          _updateState(
            status: P2PConnectionStatus.error,
            errorMessage: message.payload,
          );
          break;

        default:
          break;
      }
    });

    // Escuchar estado de WebRTC para actualizar UI
    _webRTC.statusStream.listen((status) {
      _updateState(status: status);
    });
  }

  /// Inicializar DataChannelHandler para sincronización de datos
// En P2PRepository
  void initializeSync({required Function(dynamic) onItemsReceived}) {
    _dataHandler = DataChannelHandler(_webRTC);
    // Escuchamos el stream crudo de mensajes que no son mapeados aún
    _webRTC.onMessage = (type, payload) {
      if (type == 'SYNC') {
        onItemsReceived(
            {'type': 'SYNC', 'payload': payload}); // Ajustado para el manager
      }
    };
  }

// Nuevo método para enviar el mapa completo
  Future<void> sendRawData(Map<String, dynamic> data) async {
    await _webRTC.sendMessage(data['type'], data);
  }

  /// Enviar datos al peer conectado
  Future<void> sendSyncData(List<dynamic> items) async {
    if (_dataHandler == null) throw Exception('Sync not initialized');
    // Nota: Cambiar dynamic por tu tipo real ShoppingItem
    // await _dataHandler!.sendItems(items);
  }

  /// Desconectar limpiamente
  Future<void> disconnect() async {
    await _signalingSub?.cancel();
    _dataHandler?.dispose();
    await _webRTC.dispose();
    _signaling.disconnect();
    _updateState(status: P2PConnectionStatus.disconnected);
  }

  void _updateState({
    P2PConnectionStatus? status,
    String? peerId,
    String? errorMessage,
  }) {
    _currentState = _currentState.copyWith(
      status: status ?? _currentState.status,
      roomId: _roomId,
      peerId: peerId ?? _currentState.peerId,
      errorMessage: errorMessage,
      lastConnectedAt: status == P2PConnectionStatus.connected
          ? DateTime.now()
          : _currentState.lastConnectedAt,
    );
    _stateController.add(_currentState);
  }

  void dispose() {
    _stateController.close();
    disconnect();
  }
}

// Extensión para copyWith de P2PState (si usas freezed no necesitas esto)
extension P2PStateCopyWith on P2PState {
  P2PState copyWith({
    P2PConnectionStatus? status,
    String? roomId,
    String? peerId,
    String? errorMessage,
    DateTime? lastConnectedAt,
    int? reconnectAttempts,
  }) {
    return P2PState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      peerId: peerId ?? this.peerId,
      errorMessage: errorMessage ?? this.errorMessage,
      lastConnectedAt: lastConnectedAt ?? this.lastConnectedAt,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
    );
  }
}
