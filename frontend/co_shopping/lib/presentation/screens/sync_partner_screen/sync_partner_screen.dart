import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:co_shopping/core/constants/theme.dart';

class SyncPartnerScreen extends StatefulWidget {
  const SyncPartnerScreen({super.key});

  @override
  State<SyncPartnerScreen> createState() => _SyncPartnerScreenState();
}

class _SyncPartnerScreenState extends State<SyncPartnerScreen> {
  bool _isSyncing = false;
  bool _isSuccess = false;
  bool _showQR = false;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  Future<void> _startSimulation() async {
    // 1. Espera pequeña para que la transición de pantalla sea fluida
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _showQR = true);

    // 2. Simulación de "Alguien escaneó el código"
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() => _isSyncing = true);

    // 3. Simulación de "Conexión exitosa"
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _isSyncing = false;
      _isSuccess = true;
    });
  }

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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              _isSuccess ? "Partners Connected!" : "Sync with a Partner",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _isSuccess
                  ? "You are now collaborating with Mike. Everything stays private and secure."
                  : "Invite someone to collaborate on your shopping lists in real-time.",
              style: TextStyle(
                  fontSize: 16, color: Colors.grey.shade600, height: 1.5),
            ),
            const SizedBox(height: 40),

            // Tarjeta Principal Animada
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child:
                    _isSuccess ? _buildSuccessCard() : _buildQRCard("482-901"),
              ),
            ),

            const SizedBox(height: 32),

            _buildStatusTile(
              icon: _isSuccess
                  ? Icons.check_circle
                  : (_isSyncing ? Icons.sync : Icons.hourglass_empty),
              title: _isSuccess
                  ? "Connection established"
                  : (_isSyncing ? "Syncing data..." : "Waiting for partner..."),
              subtitle:
                  _isSuccess ? "Linked to Mike's iPhone" : "Ready to connect",
              color: AppColors.primaryGreen,
              showLoading: _isSyncing,
            ),

            const SizedBox(height: 32),

            // Botones de acción dinámicos
            if (!_isSuccess) ...[
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
            ] else ...[
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text("Back to Home",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],

            const SizedBox(height: 120), // Espacio para el BottomNav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGETS DE APOYO ---

  Widget _buildQRCard(String sessionId) {
    return Container(
      key: const ValueKey("qr_card"),
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
          Stack(
            alignment: Alignment.center,
            children: [
              RepaintBoundary(
                // Aísla el QR para evitar lag en la animación
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        width: 2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Opacity(
                    opacity: _isSyncing ? 0.1 : 1.0,
                    child: _showQR
                        ? QrImageView(
                            data: sessionId,
                            version: QrVersions.auto,
                            size: 200.0)
                        : const SizedBox(width: 200, height: 200),
                  ),
                ),
              ),
              if (_isSyncing)
                const CircularProgressIndicator(color: AppColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 24),
          Text(sessionId,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4)),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      key: const ValueKey("success_card"),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
            color: AppColors.primaryGreen.withOpacity(0.4), width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle,
              size: 80, color: AppColors.primaryGreen),
          const SizedBox(height: 20),
          const Text("Synced Successfully!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.person, color: Colors.white)),
              const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.link, color: Colors.grey)),
              CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Text("M")),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      bool showLoading = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          showLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Icon(icon, color: color),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- TU BOTTOM NAVIGATION ORIGINAL ---

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
          _navItem(Icons.home_filled, "Home",
              isSelected: false, onTap: () => Navigator.pop(context)),
          _navItem(Icons.history, "History", isSelected: false, onTap: () {}),
          _navItem(Icons.auto_awesome, "Insights",
              isSelected: false, onTap: () {}),
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
