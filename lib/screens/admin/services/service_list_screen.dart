import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/service_model.dart';
import '../../../widgets/admin_bottom_navbar.dart';
import 'service_form_screen.dart';

class ServiceListScreen extends StatefulWidget {
  const ServiceListScreen({super.key});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  bool _isLoading = true;
  List<ServiceModel> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getServices();
      final data = response['data'] as List? ?? [];
      setState(() {
        _services = data.map((s) => ServiceModel.fromJson(s)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteService(ServiceModel service) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Layanan'),
        content: Text('Yakin hapus layanan ${service.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteService(service.id);
                if (!mounted) return;
                _loadServices();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Layanan berhasil dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFFF3B30))),
          ),
        ],
      ),
    );
  }

  IconData _getServiceIcon(int index) {
    if (index == 0) return Icons.home_outlined;
    if (index == 1) return Icons.store_outlined;
    return Icons.business_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // APPBAR CUSTOM
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                left: 12,
                right: 12,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/water_drop.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'WATERCASH',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1877F2),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF1877F2),
                  ),
                ],
              ),
            ),

            // BODY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1 - JUDUL
                  const SizedBox(height: 16),
                  Text(
                    'Manage Services',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Konfigurasikan tingkatan layanan air dan model penetapan harga.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SECTION 2 - LIST SERVICES
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_services.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Text(
                          'Belum ada layanan',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF8A8A9A),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _services.length,
                      itemBuilder: (ctx, idx) {
                        final service = _services[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFE8F0FE),
                              width: 1.5,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF4FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  _getServiceIcon(idx),
                                  color: const Color(0xFF1877F2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service.name,
                                            style: GoogleFonts.poppins(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF1A1A2E),
                                            ),
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color: Color(0xFF1877F2),
                                                size: 20,
                                              ),
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => ServiceFormScreen(
                                                      isEdit: true,
                                                      service: service,
                                                    ),
                                                  ),
                                                );
                                                if (result == true) _loadServices();
                                              },
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFFFF3B30),
                                                size: 20,
                                              ),
                                              onPressed: () => _deleteService(service),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // KOLOM 1 - Min Usage
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Min Usage',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF8A8A9A),
                                              ),
                                            ),
                                            Text(
                                              '${service.minUsage} m³',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1A1A2E),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // KOLOM 2 - Max Usage
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Max Usage',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF8A8A9A),
                                              ),
                                            ),
                                            Text(
                                              service.maxUsage > 999
                                                  ? 'Unlimited'
                                                  : '${service.maxUsage} m³',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1A1A2E),
                                              ),
                                            ),
                                          ],
                                        ),
                                        // KOLOM 3 - Price
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Price / m³',
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF8A8A9A),
                                              ),
                                            ),
                                            Text(
                                              'Rp ${service.price}',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1877F2),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1877F2),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ServiceFormScreen(isEdit: false),
            ),
          );
          if (result == true) _loadServices();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
