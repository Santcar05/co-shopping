import 'package:co_shopping/presentation/screens/home_screen/home_screen.dart';
import 'package:co_shopping/presentation/screens/sync_partner_screen/sync_partner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Importa Riverpod

void main() {
  // 2. Envuelve la App en un ProviderScope
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
// En main.dart

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CoShopping P2P',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF008966)),
      ),
      // Definimos rutas nombradas
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/sync': (context) => const SyncPartnerScreen(),
      },
    );
  }
}
