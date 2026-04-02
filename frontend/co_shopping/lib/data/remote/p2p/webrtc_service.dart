import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'p2p_states.dart';

typedef OnDataChannelMessage = void Function(String type, dynamic payload);
typedef OnConnectionStateChange = void Function(P2PConnectionStatus state);

/// Singleton que maneja la conexión WebRTC P2P
class WebRTCService {
  static final WebRTCService _instance = WebRTCService._internal();
  factory WebRTCService() => _instance;
  WebRTCService._internal();

  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;

  final _configuration = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      // Agrega TURN servers en producción (ej: Twilio, Xirsys)
    ],
    'sdpSemantics': 'unified-plan',
  };

  P2PConnectionStatus _status = P2PConnectionStatus.disconnected;
  P2PConnectionStatus get status => _status;

  final StreamController<P2PConnectionStatus> _statusController =
      StreamController<P2PConnectionStatus>.broadcast();
  Stream<P2PConnectionStatus> get statusStream => _statusController.stream;

  String? _currentRoomId;
  String? get currentRoomId => _currentRoomId;

  // Callbacks para integración
  OnDataChannelMessage? onMessage;
  OnConnectionStateChange? onStateChange;

  void _updateStatus(P2PConnectionStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
    onStateChange?.call(newStatus);
  }

  /// Inicializar conexión como Host (crea oferta)
  Future<RTCSessionDescription> createOffer(String roomId) async {
    _currentRoomId = roomId;
    await _initializePeerConnection();
    _updateStatus(P2PConnectionStatus.connecting);

    final dataChannelInit = RTCDataChannelInit()
      ..ordered = true
      ..maxRetransmits = 30;

    _dataChannel = await _peerConnection!
        .createDataChannel('shoppingSync', dataChannelInit);
    _setupDataChannel();

    final offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    return offer;
  }

  /// Inicializar conexión como Guest (recibe oferta, crea respuesta)
  Future<RTCSessionDescription> createAnswer(
      String roomId, RTCSessionDescription remoteOffer) async {
    _currentRoomId = roomId;
    await _initializePeerConnection();
    _updateStatus(P2PConnectionStatus.connecting);

    await _peerConnection!.setRemoteDescription(remoteOffer);
    final answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);

    return answer;
  }

  /// Recibir respuesta SDP (como Host)
  Future<void> setRemoteAnswer(RTCSessionDescription answer) async {
    await _peerConnection?.setRemoteDescription(answer);
  }

  /// Agregar candidato ICE recibido del peer
  Future<void> addIceCandidate(RTCIceCandidate candidate) async {
    await _peerConnection?.addCandidate(candidate);
  }

  Future<void> _initializePeerConnection() async {
    _peerConnection = await createPeerConnection(_configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      // El signaling client debe escuchar esto y enviarlo al otro peer
      print('ICE Candidate generated: ${candidate.candidate}');
    };

    _peerConnection!.onConnectionState = (state) {
      print('Connection state: $state');
      switch (state) {
        case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
          _updateStatus(P2PConnectionStatus.connected);
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
        case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
          _updateStatus(P2PConnectionStatus.error);
          _attemptReconnection();
          break;
        case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
          _updateStatus(P2PConnectionStatus.disconnected);
          break;
        default:
          break;
      }
    };

    _peerConnection!.onDataChannel = (channel) {
      _dataChannel = channel;
      _setupDataChannel();
    };
  }

  void _setupDataChannel() {
    if (_dataChannel == null) return;

    _dataChannel!.onDataChannelState = (state) {
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        _updateStatus(P2PConnectionStatus.connected);
      } else if (state == RTCDataChannelState.RTCDataChannelClosed) {
        _updateStatus(P2PConnectionStatus.disconnected);
      }
    };

    _dataChannel!.onMessage = (message) {
      if (message.type == MessageType.text) {
        _handleIncomingMessage(message.text);
      }
    };
  }

  void _handleIncomingMessage(String? text) {
    if (text == null) return;
    try {
      final json = jsonDecode(text);
      final type = json['type'] as String;
      final payload = json['payload'];
      onMessage?.call(type, payload);
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  /// Enviar datos al peer via DataChannel
  Future<void> sendMessage(String type, dynamic payload) async {
    if (_dataChannel?.state != RTCDataChannelState.RTCDataChannelOpen) {
      throw Exception('DataChannel not open');
    }

    final message = jsonEncode({
      'type': type,
      'payload': payload,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await _dataChannel!.send(RTCDataChannelMessage(message));
  }

  void _attemptReconnection() {
    // Implementación simple de reconexión
    if (_status == P2PConnectionStatus.error) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_status == P2PConnectionStatus.error) {
          print('Attempting to reconnect...');
          // En una implementación real, reintentaríamos el signaling
        }
      });
    }
  }

  Future<void> dispose() async {
    await _dataChannel?.close();
    await _peerConnection?.close();
    _dataChannel = null;
    _peerConnection = null;
    _updateStatus(P2PConnectionStatus.disconnected);
  }
}
