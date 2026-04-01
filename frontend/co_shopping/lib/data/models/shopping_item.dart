class ShoppingItem {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final bool isChecked;
  final bool isAI;
  final bool isHighlighted; // <-- Nuevo campo

  ShoppingItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    this.isChecked = false,
    this.isAI = false,
    this.isHighlighted = false, // Por defecto falso
  });

  ShoppingItem copyWith({bool? isChecked, bool? isHighlighted, String? name}) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      subtitle: subtitle,
      category: category,
      isChecked: isChecked ?? this.isChecked,
      isAI: isAI,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }
}
