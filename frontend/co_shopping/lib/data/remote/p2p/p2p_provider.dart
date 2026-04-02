import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'p2p_repository.dart';
import 'p2p_states.dart';

/// Provider del repositorio P2P (singleton)
final p2pRepositoryProvider = Provider<P2PRepository>((ref) {
  final repo = P2PRepository();
  ref.onDispose(() => repo.dispose());
  return repo;
});

/// Stream del estado de conexión para la UI
final p2pStateProvider = StreamProvider<P2PState>((ref) {
  final repo = ref.watch(p2pRepositoryProvider);
  return repo.stateStream;
});

/// Provider simple para acceso al estado actual
final p2pStatusProvider = Provider<AsyncValue<P2PState>>((ref) {
  return ref.watch(p2pStateProvider);
});
