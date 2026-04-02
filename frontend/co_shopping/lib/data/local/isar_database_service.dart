import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/shopping_item.dart';
import '../models/shopping_list.dart';

class IsarDatabaseService {
  static Isar? _instance;

  // Singleton getter
  static Isar get instance {
    if (_instance == null) {
      throw StateError(
          'IsarDatabaseService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  // Inicialización asíncrona
  static Future<void> initialize() async {
    if (_instance != null) return;

    final dir = await getApplicationDocumentsDirectory();

    _instance = await Isar.open(
      [
        ShoppingItemSchema,
        ShoppingListSchema,
      ],
      directory: dir.path,
      name: 'co_shopping_db',
      inspector: true, // Habilita inspector en desarrollo (localhost:5678)
    );

    print('✅ Isar inicializado en: ${dir.path}');
  }

  // Cierre limpio
  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }

  // Helper para verificar si está listo
  static bool get isInitialized => _instance != null;
}
