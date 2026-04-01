class ShoppingItem {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final bool isChecked;
  final bool isAI;

  ShoppingItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    this.isChecked = false,
    this.isAI = false,
  });

  // Copia con cambios (para inmutabilidad de Riverpod)
  ShoppingItem copyWith({bool? isChecked}) {
    return ShoppingItem(
      id: id,
      name: name,
      subtitle: subtitle,
      category: category,
      isChecked: isChecked ?? this.isChecked,
      isAI: isAI,
    );
  }
}
