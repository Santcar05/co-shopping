import 'package:co_shopping/core/constants/theme.dart';
import 'package:co_shopping/presentation/providers/shopping_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartRefillCard extends ConsumerStatefulWidget {
  const SmartRefillCard({super.key});

  @override
  ConsumerState<SmartRefillCard> createState() => _SmartRefillCardState();
}

class _SmartRefillCardState extends ConsumerState<SmartRefillCard> {
  bool isAdded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(isAdded),
        decoration: BoxDecoration(
          color: isAdded ? Colors.grey[50] : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(
            color: isAdded
                ? Colors.grey.shade300
                : AppColors.primaryGreen.withOpacity(0.3),
            width: 2,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "SMART REFILL",
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontSize: 12,
                    color: isAdded ? Colors.grey : Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(isAdded ? Icons.check_circle : Icons.local_drink_outlined,
                    color: isAdded
                        ? AppColors.primaryGreen
                        : const Color(0xFFB2DFDB)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Oat Milk",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              isAdded
                  ? "Perfect! We've added this to your list."
                  : "Based on your weekly habit, you might need this.",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (!isAdded)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 1. Agregar a la lista global
                    ref
                        .read(shoppingListProvider.notifier)
                        .addItem("Oat Milk", "DAIRY & EGGS", isAI: true);
                    // 2. Cambiar estado local del botón
                    setState(() {
                      isAdded = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    "+ Add to list",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
