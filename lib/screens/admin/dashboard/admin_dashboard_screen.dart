import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_service.dart';
import '../../../widgets/admin_bottom_navbar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _customerCount = 0;
  int _pendingCount = 0;
  int _serviceCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getCustomers(),
        ApiService.getPayments(),
        ApiService.getServices(),
      ]);

      if (!mounted) return;

      _customerCount = results[0]['count'] ?? 0;
      _pendingCount = ((results[1]['data'] as List?) ?? [])
          .where((p) => p['verified'] == false)
          .length;
      _serviceCount = results[2]['count'] ?? 0;

      setState(() => _isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FF);
    const blue = Color(0xFF1877F2);
    const grey = Color(0xFF8A8A9A);
    const dark = Color(0xFF1A1A2E);
    const white = Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // APPBAR CUSTOM
                    Container(
                      color: white,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                                  fontWeight: FontWeight.w700,
                                  color: blue,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.notifications_outlined,
                            color: blue,
                            size: 24,
                          ),
                        ],
                      ),
                    ),

                    // SECTION 1 - JUDUL
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Admin Dashboard',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ringkasan operasional harian PDAM hari ini.',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 2 - 3 STAT CARDS
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // CARD 1 - JUMLAH CUSTOMER
                          _buildStatCard(
                            iconBg: const Color(0xFFEEF4FF),
                            icon: Icons.people_alt_outlined,
                            iconColor: blue,
                            badge: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8FAF0),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+ 12%',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF22C55E),
                                ),
                              ),
                            ),
                            label: 'Jumlah Customer',
                            value: '$_customerCount',
                            valueColor: blue,
                            marginBottom: 12,
                          ),

                          // CARD 2 - PEMBAYARAN BELUM DIVERIFIKASI
                          _buildStatCard(
                            iconBg: const Color(0xFFFFF0EE),
                            icon: Icons.edit_note_outlined,
                            iconColor: const Color(0xFFFF3B30),
                            badge: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF0EE),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Penting',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFFF3B30),
                                ),
                              ),
                            ),
                            label: 'Pembayaran Belum Diverifikasi',
                            value: '$_pendingCount',
                            valueColor: const Color(0xFFFF3B30),
                            marginBottom: 12,
                            leftBorderColor: const Color(0xFFFF3B30),
                          ),

                          // CARD 3 - JUMLAH LAYANAN
                          _buildStatCard(
                            iconBg: const Color(0xFFEEF4FF),
                            icon: Icons.build_outlined,
                            iconColor: blue,
                            badge: const SizedBox(),
                            label: 'Jumlah Layanan',
                            value: '$_serviceCount',
                            valueColor: blue,
                            marginBottom: 12,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 3 - TREND KONSUMSI AIR
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Trend Konsumsi Air',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: dark,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE0E0E0)),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '7 Hari Terakhir',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: grey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        size: 16,
                                        color: grey,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200,
                              child: BarChart(
                                BarChartData(
                                  barGroups: List.generate(7, (i) => BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: [3.5, 4.2, 2.8, 5.1, 4.0, 6.2, 4.8][i],
                                        color: i == 5
                                            ? const Color(0xFF1877F2)
                                            : const Color(0xFF90CAF9).withValues(alpha: 0.6 + i * 0.05),
                                        width: 28,
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                      ),
                                    ],
                                  )),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              days[idx],
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: grey,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 4 - LAYANAN AKTIF CARD
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Layanan Aktif',
                                    style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Semua sistem distribusi air berjalan normal di seluruh wilayah',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  OutlinedButton(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.white, width: 1.5),
                                      foregroundColor: white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    ),
                                    child: Text(
                                      'Lihat Detail Peta',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              Icons.verified_outlined,
                              color: white.withValues(alpha: 0.4),
                              size: 60,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // SECTION 5 - AKTIVITAS TERBARU
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktivitas Terbaru',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: dark,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Item 1
                          _buildActivityItem(
                            iconBg: const Color(0xFFE8F5E9),
                            icon: Icons.payments_outlined,
                            iconColor: const Color(0xFF22C55E),
                            title: 'Pembayaran Masuk - #ORD-8821',
                            subtitle: 'Bpk. Slamet - Rp 142.500',
                            time: '2m ago',
                          ),

                          const SizedBox(height: 8),

                          // Item 2
                          _buildActivityItem(
                            iconBg: const Color(0xFFEEF4FF),
                            icon: Icons.person_add_outlined,
                            iconColor: blue,
                            title: 'Pendaftaran Baru',
                            subtitle: 'Ibu Siti Aminah - Wilayah Timur',
                            time: '15m ago',
                          ),

                          const SizedBox(height: 8),

                          // Item 3
                          _buildActivityItem(
                            iconBg: const Color(0xFFFFF8E1),
                            icon: Icons.warning_amber_outlined,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'Tagihan Jatuh Tempo',
                            subtitle: '5 pelanggan belum bayar',
                            time: '1h ago',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildStatCard({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required Widget badge,
    required String label,
    required String value,
    required Color valueColor,
    double marginBottom = 0,
    Color? leftBorderColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: leftBorderColor != null
            ? Border(left: BorderSide(color: leftBorderColor, width: 4))
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              badge,
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF8A8A9A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF8A8A9A),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF8A8A9A),
            ),
          ),
        ],
      ),
    );
  }
}