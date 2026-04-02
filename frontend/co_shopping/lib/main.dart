import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/theme.dart';
import 'data/local/isar_database_service.dart';
import 'data/repositories/shopping_item_repository.dart';
import 'presentation/screens/home_screen/home_screen.dart';
import 'presentation/screens/sync_partner_screen/sync_partner_screen.dart';

// Provider global del repositorio (para acceso en toda la app)
final shoppingItemRepositoryProvider =
    Provider((ref) => ShoppingItemRepository());

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inicializar Isar
  await IsarDatabaseService.initialize();

  // 2. Permisos (opcional por ahora)
  // await _requestPermissions();

  runApp(
    const ProviderScope(
      child: CoShoppingApp(),
    ),
  );
}

class CoShoppingApp extends StatelessWidget {
  const CoShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoShopping P2P',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sync': (context) => const SyncPartnerScreen(),
      },
    );
  }
}
