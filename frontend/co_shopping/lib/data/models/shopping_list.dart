import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'shopping_list.g.dart';

@Collection()
class ShoppingList {
  Id localId = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;
  DateTime createdAt = DateTime.now();

  @Index()
  DateTime updatedAt = DateTime.now();

  late String ownerPeerId;

  // SIMPLE: Solo guardamos UUIDs de items (más fácil para sincronización P2P)
  List<String> itemUuids = [];

  // IDs de peers conectados
  List<String> connectedPeers = [];

  // Constructor requerido
  ShoppingList();

  factory ShoppingList.create({
    required String name,
    String? ownerPeerId,
  }) {
    final list = ShoppingList();
    list.uuid = const Uuid().v4();
    list.name = name;
    list.ownerPeerId = ownerPeerId ?? "local";
    list.updatedAt = DateTime.now();
    return list;
  }

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'ownerPeerId': ownerPeerId,
        'itemUuids': itemUuids,
      };

  void touch() {
    updatedAt = DateTime.now();
  }
}
