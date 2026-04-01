import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:co_shopping/core/constants/theme.dart';

class SyncPartnerScreen extends StatelessWidget {
  const SyncPartnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "CoShopping",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: AppColors.primaryGreen),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "Sync with a Partner",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Invite someone to collaborate on your shopping lists in real-time. Everything stays private and secure.",
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Tarjeta Principal del QR
            _buildQRCard("482-901"),

            const SizedBox(height: 32),

            // Lista de estados/features
            _buildStatusTile(
              icon: Icons.hourglass_empty,
              title: "Waiting for partner...",
              subtitle: "Ready to connect on your second device",
              color: AppColors.primaryGreen,
            ),
            _buildStatusTile(
              icon: Icons.lock_outline,
              title: "End-to-End Private",
              subtitle: "Encryption keys never leave your devices",
              color: Colors.blue.shade400,
            ),
            _buildStatusTile(
              icon: Icons.bolt,
              title: "Real-Time Sync",
              subtitle: "Instantly see changes as they happen",
              color: Colors.blue.shade400,
            ),

            const SizedBox(height: 40),

            // Botones de acción
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.copy, color: Colors.white),
              label: const Text("Copy Invite Link",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.bluetooth, color: Colors.black87),
              label: const Text("Pair via Bluetooth",
                  style: TextStyle(
                      color: Colors.black87, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                side: BorderSide(color: Colors.grey.shade300),
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 120), // Espacio para no chocar con el nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGETS DE LA PANTALLA ---

  Widget _buildQRCard(String sessionId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.1), width: 2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: QrImageView(
              data: sessionId,
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square, color: Colors.black87),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F3F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("UNIQUE SESSION ID:",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1)),
                Text(sessionId,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text("Share this code with your partner",
              style: TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildStatusTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle,
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- NAVEGACIÓN (IDÉNTICA A HOME) ---

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, left: 12, right: 12, top: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // HOME: Ahora te lleva de regreso
          _navItem(Icons.home_filled, "Home", isSelected: false, onTap: () {
            Navigator.pop(context);
          }),
          _navItem(Icons.history, "History", isSelected: false, onTap: () {}),
          _navItem(Icons.auto_awesome, "Insights",
              isSelected: false, onTap: () {}),
          // SYNC: Seleccionado en esta pantalla
          _navItem(Icons.sync, "Sync", isSelected: true, onTap: () {}),
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
