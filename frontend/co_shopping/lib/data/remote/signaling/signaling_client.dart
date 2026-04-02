import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Mensajes del protocolo de signaling
enum SignalingMessageType {
  joinRoom,
  leaveRoom,
  offer,
  answer,
  iceCandidate,
  peerJoined,
  peerLeft,
  error,
}

class SignalingMessage {
  final SignalingMessageType type;
  final String roomId;
  final String? peerId;
  final dynamic payload;
  final DateTime timestamp;

  SignalingMessage({
    required this.type,
    required this.roomId,
    this.peerId,
    this.payload,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'roomId': roomId,
        'peerId': peerId,
        'payload': payload,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SignalingMessage.fromJson(Map<String, dynamic> json) {
    return SignalingMessage(
      type: SignalingMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SignalingMessageType.error,
      ),
      roomId: json['roomId'],
      peerId: json['peerId'],
      payload: json['payload'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// Cliente WebSocket para comunicación con Spring Boot Signaling Server
class SignalingClient {
  WebSocket? _socket;
  final StreamController<SignalingMessage> _messageController =
      StreamController<SignalingMessage>.broadcast();

  Stream<SignalingMessage> get messageStream => _messageController.stream;

  bool get isConnected =>
      _socket != null && _socket!.readyState == WebSocket.open;

  /// Conectar al servidor de signaling
  Future<void> connect(String url) async {
    try {
      _socket = await WebSocket.connect(url);
      _socket!.listen(
        (data) => _handleMessage(data),
        onError: (error) => _messageController.add(
          SignalingMessage(
            type: SignalingMessageType.error,
            roomId: '',
            payload: error.toString(),
          ),
        ),
        onDone: () {
          _messageController.add(
            SignalingMessage(
              type: SignalingMessageType.peerLeft,
              roomId: '',
              payload: 'Connection closed',
            ),
          );
        },
      );
    } catch (e) {
      throw Exception('Failed to connect to signaling server: $e');
    }
  }

  void _handleMessage(String data) {
    try {
      final json = jsonDecode(data);
      final message = SignalingMessage.fromJson(json);
      _messageController.add(message);
    } catch (e) {
      print('Error parsing signaling message: $e');
    }
  }

  /// Unirse a una sala (room)
  void joinRoom(String roomId, String peerId) {
    _send(SignalingMessage(
      type: SignalingMessageType.joinRoom,
      roomId: roomId,
      peerId: peerId,
    ));
  }

  /// Enviar SDP Offer
  void sendOffer(String roomId, RTCSessionDescription offer) {
    _send(SignalingMessage(
      type: SignalingMessageType.offer,
      roomId: roomId,
      payload: {
        'sdp': offer.sdp,
        'type': offer.type,
      },
    ));
  }

  /// Enviar SDP Answer
  void sendAnswer(String roomId, RTCSessionDescription answer) {
    _send(SignalingMessage(
      type: SignalingMessageType.answer,
      roomId: roomId,
      payload: {
        'sdp': answer.sdp,
        'type': answer.type,
      },
    ));
  }

  /// Enviar candidato ICE
  void sendIceCandidate(String roomId, RTCIceCandidate candidate) {
    _send(SignalingMessage(
      type: SignalingMessageType.iceCandidate,
      roomId: roomId,
      payload: {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      },
    ));
  }

  void _send(SignalingMessage message) {
    if (isConnected) {
      _socket!.add(jsonEncode(message.toJson()));
    } else {
      throw Exception('Signaling socket not connected');
    }
  }

  void disconnect() {
    _socket?.close();
    _socket = null;
  }
}
