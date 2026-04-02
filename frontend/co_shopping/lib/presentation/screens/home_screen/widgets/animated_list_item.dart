import 'package:co_shopping/data/models/shopping_item.dart';
import 'package:co_shopping/presentation/providers/shopping_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShoppingItemTile extends ConsumerWidget {
  final ShoppingItem item;

  const ShoppingItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: () => ref
            .read(shoppingListProvider.notifier)
            .toggleItem(item.uuid), // CAMBIO: uuid
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _buildCustomCheckbox(item.isChecked),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            decoration: item.isChecked
                                ? TextDecoration.lineThrough
                                : null,
                            color: item.isChecked
                                ? Colors.grey
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                        if (item.isAI) ...[
                          const SizedBox(width: 6),
                          const Icon(Icons.auto_awesome,
                              size: 14, color: Color(0xFF008966)),
                        ],
                      ],
                    ),
                    Text(item.subtitle,
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: Color(0xFFD1D1D6)),
            ],
          ),
        ),
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
