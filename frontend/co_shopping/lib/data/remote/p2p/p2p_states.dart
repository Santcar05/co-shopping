enum P2PConnectionStatus {
  disconnected,
  connecting,
  signaling,
  connected,
  error,
}

class P2PState {
  final P2PConnectionStatus status;
  final String? roomId;
  final String? peerId;
  final String? errorMessage;
  final DateTime? lastConnectedAt;
  final int reconnectAttempts;

  const P2PState({
    this.status = P2PConnectionStatus.disconnected,
    this.roomId,
    this.peerId,
    this.errorMessage,
    this.lastConnectedAt,
    this.reconnectAttempts = 0,
  });

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

  @override
  String toString() {
    return 'P2PState(status: $status, roomId: $roomId, peerId: $peerId)';
  }
}
