import 'package:flutter/material.dart';
import 'package:co_shopping/data/models/shopping_item.dart';
import 'package:co_shopping/presentation/screens/home_screen/widgets/item_list_card.dart';

class ItemListSection extends StatelessWidget {
  final String title;
  final List<ShoppingItem> items;

  const ItemListSection({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        // Mapeamos los items al nuevo ItemListCard
        ...items
            .map((item) => ItemListCard(key: ValueKey(item.id), item: item)),
      ],
    );
  }
}
