import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'shopping_item.g.dart';

@Collection()
class ShoppingItem {
  // ID interno de Isar (auto-incremental) - NUNCA se envía por P2P
  Id localId = Isar.autoIncrement;

  // UUID para sincronización P2P (este es el ID externo)
  @Index(unique: true, replace: true)
  late String uuid;

  late String name;
  late String subtitle;

  // Índice para filtrado rápido por categoría
  @Index()
  late String category;

  bool isChecked = false;
  bool isAI = false;
  bool isHighlighted = false;

  // Soft delete para sincronización P2P (no borramos físicamente)
  bool isDeleted = false;

  // Timestamps para resolución de conflictos (LWW - Last Write Wins)
  DateTime createdAt = DateTime.now();

  @Index() // Índice para queries de sincronización eficientes
  DateTime updatedAt = DateTime.now();

  // Identificador del dispositivo/peer que creó el item
  late String ownerPeerId;

  // Constructor sin nombre REQUERIDO por Isar
  ShoppingItem();

  // Factory para crear nuevos items fácilmente
  factory ShoppingItem.create({
    required String name,
    required String category,
    String? subtitle,
    bool isAI = false,
    bool isChecked = false,
    bool isHighlighted = false,
    String? ownerPeerId,
  }) {
    final item = ShoppingItem();
    item.uuid = const Uuid().v4();
    item.name = name;
    item.category = category;
    item.subtitle = subtitle ?? (isAI ? "AI Suggested" : "Added manually");
    item.isAI = isAI;
    item.isChecked = isChecked;
    item.isHighlighted = isHighlighted;
    item.ownerPeerId = ownerPeerId ?? "local";
    item.createdAt = DateTime.now();
    item.updatedAt = DateTime.now();
    item.isDeleted = false;
    return item;
  }

  // Actualiza el timestamp al modificar (para sync)
  void touch() {
    updatedAt = DateTime.now();
  }

  // Serialización para envío por WebRTC DataChannel
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'subtitle': subtitle,
        'category': category,
        'isChecked': isChecked,
        'isAI': isAI,
        'isHighlighted': isHighlighted,
        'isDeleted': isDeleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'ownerPeerId': ownerPeerId,
      };

  // Deserialización desde JSON recibido por P2P
  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    final item = ShoppingItem();
    item.uuid = json['uuid'];
    item.name = json['name'];
    item.subtitle = json['subtitle'];
    item.category = json['category'];
    item.isChecked = json['isChecked'] ?? false;
    item.isAI = json['isAI'] ?? false;
    item.isHighlighted = json['isHighlighted'] ?? false;
    item.isDeleted = json['isDeleted'] ?? false;
    item.createdAt = DateTime.parse(json['createdAt']);
    item.updatedAt = DateTime.parse(json['updatedAt']);
    item.ownerPeerId = json['ownerPeerId'] ?? 'unknown';
    return item;
  }

  // Copia inmutable con cambios (útil para Riverpod)
  ShoppingItem copyWith({
    String? name,
    String? subtitle,
    String? category,
    bool? isChecked,
    bool? isHighlighted,
    bool? isDeleted,
  }) {
    final newItem = ShoppingItem();
    newItem.localId = localId; // Preservar ID local
    newItem.uuid = uuid; // UUID nunca cambia
    newItem.name = name ?? this.name;
    newItem.subtitle = subtitle ?? this.subtitle;
    newItem.category = category ?? this.category;
    newItem.isChecked = isChecked ?? this.isChecked;
    newItem.isAI = isAI; // No se puede cambiar
    newItem.isHighlighted = isHighlighted ?? this.isHighlighted;
    newItem.isDeleted = isDeleted ?? this.isDeleted;
    newItem.createdAt = createdAt; // Inmutable
    newItem.updatedAt = DateTime.now(); // Siempre actualiza
    newItem.ownerPeerId = ownerPeerId; // Inmutable
    return newItem;
  }
}
