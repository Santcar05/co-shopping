import 'package:co_shopping/core/constants/theme.dart';
import 'package:co_shopping/data/models/shopping_item.dart';
import 'package:co_shopping/presentation/providers/shopping_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// En item_list_card.dart
class ItemListCard extends ConsumerWidget {
  final ShoppingItem item;
  const ItemListCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            item.isHighlighted ? Colors.yellow.withOpacity(0.2) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: item.isHighlighted
            ? Border.all(color: Colors.orangeAccent, width: 2)
            : null,
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isChecked,
          activeColor: AppColors.primaryGreen,
          onChanged: (val) =>
              ref.read(shoppingListProvider.notifier).toggleItem(item.id),
        ),
        title: Text(item.name,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration:
                    item.isChecked ? TextDecoration.lineThrough : null)),
        subtitle: Text(item.subtitle, style: const TextStyle(fontSize: 12)),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.grey),
          onSelected: (value) {
            if (value == 'edit') _showEditDialog(context, ref, item);
            if (value == 'highlight')
              ref.read(shoppingListProvider.notifier).toggleHighlight(item.id);
            if (value == 'delete')
              ref.read(shoppingListProvider.notifier).deleteItem(item.id);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'edit',
                child:
                    ListTile(leading: Icon(Icons.edit), title: Text("Editar"))),
            PopupMenuItem(
                value: 'highlight',
                child: ListTile(
                    leading: Icon(
                        item.isHighlighted ? Icons.star : Icons.star_border,
                        color: Colors.orange),
                    title:
                        Text(item.isHighlighted ? "Desmarcar" : "Resaltar"))),
            const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title:
                        Text("Eliminar", style: TextStyle(color: Colors.red)))),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref, ShoppingItem item) {
    final controller = TextEditingController(text: item.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Producto"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(shoppingListProvider.notifier)
                  .editItem(item.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(bool checked) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: checked ? const Color(0xFF006D4E) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: checked ? const Color(0xFF006D4E) : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 18, color: Colors.white)
          : null,
    );
  }
}
