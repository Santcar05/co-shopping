import 'package:co_shopping/presentation/screens/home_screen/widgets/item_list_section.dart';
import 'package:co_shopping/presentation/screens/sync_partner_screen/sync_partner_screen.dart';
import 'package:co_shopping/presentation/widgets/smart_refill_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:co_shopping/core/constants/theme.dart';
import 'package:co_shopping/presentation/providers/shopping_list_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String tempCategory = 'PRODUCE'; // Categoría inicial

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        // Permite actualizar el estado dentro del modal
        builder: (context, setModalState) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add New Item",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Item name (e.g. Greek Yogurt)",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("Select Category",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _categoryChip("PRODUCE", tempCategory, (val) {
                      setModalState(() => tempCategory = val);
                    }),
                    const SizedBox(width: 10),
                    _categoryChip("DAIRY & EGGS", tempCategory, (val) {
                      setModalState(() => tempCategory = val);
                    }),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      ref
                          .read(shoppingListProvider.notifier)
                          .addItem(nameController.text, tempCategory);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Create Item",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para los chips de categoría
  Widget _categoryChip(
      String label, String currentSelected, Function(String) onSelected) {
    bool isSelected = label == currentSelected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => onSelected(label),
      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
      backgroundColor: Colors.grey[100],
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryGreen : Colors.grey[600],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: isSelected ? AppColors.primaryGreen : Colors.transparent),
      ),
      showCheckmark: false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allItems = ref.watch(shoppingListProvider);
    final produceItems =
        allItems.where((item) => item.category == 'PRODUCE').toList();
    final dairyItems =
        allItems.where((item) => item.category == 'DAIRY & EGGS').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context, ref),
        backgroundColor: AppColors.primaryGreen,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 32),
              const SmartRefillCard(),
              const SizedBox(height: 32),
              if (produceItems.isNotEmpty)
                ItemListSection(title: "PRODUCE", items: produceItems),
              if (dairyItems.isNotEmpty)
                ItemListSection(title: "DAIRY & EGGS", items: dairyItems),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // ... (Los métodos _buildHeader, _buildBottomNav y _navItem se mantienen igual que en tu código anterior)
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.bubble_chart, color: AppColors.primaryGreen, size: 32),
            CircleAvatar(
                radius: 20,
                backgroundImage:
                    NetworkImage('https://i.pravatar.cc/150?u=user')),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Weekly Essentials",
            style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text("Shared with Sarah & Mike",
                style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: BorderRadius.circular(12)),
              child: const Row(
                children: [
                  CircleAvatar(
                      radius: 3, backgroundColor: AppColors.primaryGreen),
                  SizedBox(width: 4),
                  Text("SYNCING ACTIVE",
                      style: TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 10),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_filled, "Home", isSelected: true, onTap: () {}),
          _navItem(Icons.history, "History", isSelected: false, onTap: () {}),
          _navItem(Icons.auto_awesome, "Insights",
              isSelected: false, onTap: () {}),
          _navItem(Icons.sync, "Sync", isSelected: false, onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const SyncPartnerScreen()));
          }),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label,
      {required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0F2F1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon,
                color: isSelected ? AppColors.primaryGreen : Colors.grey),
          ),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primaryGreen : Colors.grey)),
        ],
      ),
    );
  }
}
