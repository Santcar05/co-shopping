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
  bool _showQR = false; // Nueva bandera para diferir el renderizado pesado

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  Future<void> _startSimulation() async {
    // 1. Esperamos a que la transición de la pantalla termine para mostrar el QR
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _showQR = true);

    // 2. Simulamos el inicio del escaneo
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;
    setState(() => _isSyncing = true);

    // 3. Simulamos el éxito final
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
        title: const Text("CoShopping",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildTextHeader(),
              const SizedBox(height: 40),

              // Animación principal con optimización de escala
              Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    );
                  },
                  child: _isSuccess
                      ? _buildSuccessCard()
                      : _buildQRCard("482-901"),
                ),
              ),

              const SizedBox(height: 32),
              _buildStatusTile(
                icon: _isSuccess
                    ? Icons.check_circle
                    : (_isSyncing ? Icons.sync : Icons.hourglass_empty),
                title: _isSuccess
                    ? "Connection established"
                    : (_isSyncing
                        ? "Syncing data..."
                        : "Waiting for partner..."),
                subtitle:
                    _isSuccess ? "Linked to Mike's iPhone" : "Ready to connect",
                color: AppColors.primaryGreen,
                showLoading: _isSyncing,
              ),
              const SizedBox(height: 40),
              _buildActionButtons(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isSuccess ? "Partners Connected!" : "Sync with a Partner",
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          _isSuccess
              ? "You are now collaborating with Mike. Everything is ready."
              : "Invite someone to collaborate on your shopping lists.",
          style:
              TextStyle(fontSize: 16, color: Colors.grey.shade600, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildQRCard(String sessionId) {
    return Container(
      key: const ValueKey("qr_container"),
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30)
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // OPTIMIZACIÓN: RepaintBoundary aísla el renderizado del QR
              RepaintBoundary(
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
                        : const SizedBox(
                            width: 200, height: 200), // Placeholder inicial
                  ),
                ),
              ),
              if (_isSyncing)
                const CircularProgressIndicator(
                    color: AppColors.primaryGreen, strokeWidth: 3),
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
            color: AppColors.primaryGreen.withOpacity(0.3), width: 2),
      ),
      child: const Column(
        children: [
          Icon(Icons.check_circle, size: 100, color: AppColors.primaryGreen),
          SizedBox(height: 20),
          Text("Perfect!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(Icons.person, color: Colors.white)),
              SizedBox(width: 10),
              Icon(Icons.link, color: Colors.grey),
              SizedBox(width: 10),
              CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text("M", style: TextStyle(color: Colors.white))),
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
          if (showLoading)
            const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            Icon(icon, color: color),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (!_isSuccess)
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.copy, color: Colors.white),
            label: const Text("Copy Invite Link"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(_isSuccess ? "Go Back" : "Cancel",
              style: const TextStyle(
                  color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
