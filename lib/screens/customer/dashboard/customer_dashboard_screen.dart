import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/service_model.dart';
import '../../../widgets/customer_bottom_navbar.dart';
import '../payments/bill_selection_screen.dart';
import '../tips/tips_screen.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  bool _isLoading = true;
  String _customerName = '';
  String _customerNumber = '';

  List<BillModel> _bills = [];
  double _currentUsage = 0;
  double _maxUsage = 1;

  bool _toggleUsage = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        ApiService.getCustomerMe(),
        ApiService.getBillsMe(),
      ]);

      if (!mounted) return;

      final customerData = results[0];
      final billsData = results[1];

      final serviceData = customerData['data']?['service'] ?? {};
      final maxUsage = (serviceData['max_usage'] as num?)?.toDouble() ?? 1.0;

      final bills = ((billsData['data'] as List?) ?? []).map((b) => BillModel.fromJson(b)).toList();

      final currentUsage = bills.isNotEmpty ? bills.last.usageValue.toDouble() : 0.0;

      setState(() {
        _customerName = customerData['data']?['name'] ?? 'Customer';
        _customerNumber = customerData['data']?['customer_number'] ?? '-';
        _bills = bills;
        _maxUsage = maxUsage <= 0 ? 1 : maxUsage;
        _currentUsage = currentUsage;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Offline mode - use dummy data
      setState(() {
        _customerName = 'John Doe';
        _customerNumber = '001234';
        _bills = _getDummyBills();
        _maxUsage = 50;
        _currentUsage = 15;
        _isLoading = false;
      });
    }
  }

  int get _unpaidBillsCount {
    final count = _bills.where((b) => b.paid == false).length;
    return count == 0 ? 1 : count; // dummy minimal 1
  }

  int get _paidCount => _bills.where((b) => b.paid).length;

  int get _pendingVerifyCount => _bills.where((b) => b.paid && (b.verifiedPayment == false)).length;

  num get _totalUnpaid {
    final unpaidBills = _bills.where((b) => b.paid == false);
    if (unpaidBills.isEmpty) return 120000; // dummy
    return unpaidBills.fold(0, (sum, b) => sum + b.price);
  }

  List<BillModel> _getDummyBills() {
    return [
      BillModel(
        id: 1,
        customerId: 1,
        adminId: 1,
        month: 6,
        year: 2026,
        measurementNumber: 'WM-001234',
        usageValue: 15,
        price: 75000,
        serviceId: 1,
        paid: false,
        ownerToken: 'dummy',
        customer: CustomerModel(
          id: 1,
          userId: 1,
          customerNumber: '001234',
          name: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Dummy No. 1',
          serviceId: 1,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
        service: ServiceModel(
          id: 1,
          name: 'Paket Rumah Tangga',
          minUsage: 0,
          maxUsage: 50,
          price: 4500,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
      BillModel(
        id: 2,
        customerId: 1,
        adminId: 1,
        month: 5,
        year: 2026,
        measurementNumber: 'WM-001234',
        usageValue: 12,
        price: 60000,
        serviceId: 1,
        paid: false,
        ownerToken: 'dummy',
        customer: CustomerModel(
          id: 1,
          userId: 1,
          customerNumber: '001234',
          name: 'John Doe',
          phone: '08123456789',
          address: 'Jl. Dummy No. 1',
          serviceId: 1,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
        service: ServiceModel(
          id: 1,
          name: 'Paket Rumah Tangga',
          minUsage: 0,
          maxUsage: 50,
          price: 4500,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
    ];
  }

  String _greetingName() => _customerName.isEmpty ? '-' : _customerName;

  double get _usagePercent => ((_currentUsage / _maxUsage).clamp(0.0, 1.0)) * 100.0;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FF);
    const blue = Color(0xFF1877F2);
    const grey = Color(0xFF8A8A9A);
    const dark = Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: bg,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER (custom appbar)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(color: Colors.white),
                        child: Row(
                          children: [
                            Row(
                              children: const [
                                Icon(
                                  Icons.water_drop_outlined,
                                  size: 28,
                                  color: blue,
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                            Text(
                              'WATERCASH',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: blue,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined, size: 24, color: blue),
                            ),
                          ],
                        ),
                      ),

                      // SECTION 1 - HEADER inside body
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DASHBORD',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: grey,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Halo, ${_greetingName()}!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: dark,
                                    ),
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF0F4FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 14, color: blue),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Home ID : $_customerNumber',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: blue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // STATS CARDS - 2 cards row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.receipt_long_outlined, size: 24, color: blue),
                                    const SizedBox(height: 8),
                                    Text(
                                      'TAGIHAN TERBAYAR',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: grey,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_paidCount',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.pending_outlined, size: 24, color: blue),
                                    const SizedBox(height: 8),
                                    Text(
                                      'VERIFIKASI PENDING',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: grey,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$_pendingVerifyCount',
                                      style: GoogleFonts.poppins(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w700,
                                        color: dark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 2 - TAGIHAN CARD
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: blue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'TAGIHAN BELUM DIBAYAR',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF3B30),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Text(
                                      '${_unpaidBillsCount}BILL PENDING',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Rp ${_totalUnpaid.toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Jatuh tempo: ${_bills.isNotEmpty ? '${_bills.last.month}/${_bills.last.year}' : '-'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,

                                        color: Colors.white.withValues(alpha: 0.8),
                                        fontWeight: FontWeight.w600,
                                      ),

                                    ),
                                  ),
                                  ElevatedButton(

                                    onPressed: () async {
                                      // Navigate to bill selection with bills from dashboard
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BillSelectionScreen(initialBills: _bills),
                                        ),
                                      );
                                      if (result == true) _loadData();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: blue,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: Text(
                                      'Bayar Sekarang →',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 3 - CURRENT USAGE CARD
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'PENGGUNAAN SAAT INI',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: grey,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.trending_up, size: 18, color: blue),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    _currentUsage.toStringAsFixed(0),
                                    style: GoogleFonts.poppins(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: dark,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'm³',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: grey,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_currentUsage / _maxUsage).clamp(0.0, 1.0),
                                  backgroundColor: const Color(0xFFE0E0E0),
                                  valueColor: const AlwaysStoppedAnimation<Color>(blue),
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_usagePercent.toStringAsFixed(0)}% dari penggunaan bulanan rata-rata',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 4 - SYSTEM STATUS CARD
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FFF4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: Color(0xFF22C55E),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Sistem',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: dark,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Semua layanan aktif',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF22C55E),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 5 - GRAFIK TAGIHAN (Bar Chart)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Grafik Tagihan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: dark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Data penggunaan selama 6 bulan terakhir',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Toggle
                                  Row(
                                    children: [
                                      _buildToggleChip(label: 'm³', active: _toggleUsage, onTap: () => setState(() => _toggleUsage = true), blue: blue, grey: grey),
                                      const SizedBox(width: 8),
                                      _buildToggleChip(label: 'Rp', active: !_toggleUsage, onTap: () => setState(() => _toggleUsage = false), blue: blue, grey: grey),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 200,
                                child: _bills.isEmpty
                                    ? _buildDummyBarChart()
                                    : BarChart(_buildBarChartData()),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SECTION 6 - SAVE WATER CARD
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4DA6FF),
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
                                      'Hemat Air, Hemat Tagihan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Temukan 5 kiat cepat untuk mengurangi konsumsi air bulanan hingga 20%',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    GestureDetector(
                                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TipsScreen())),
                                      child: Text(
                                        'BACA TIPS',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Opacity(
                                opacity: 0.8,
                                child: Image.asset(
                                  'assets/images/water_drop.png',
                                  width: 80,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 0),
    );
  }

  Widget _buildToggleChip({
    required String label,
    required bool active,
    required VoidCallback onTap,
    required Color blue,
    required Color grey,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? blue : grey.withValues(alpha: 0.4),
            width: 1.2,
          ),
          color: active ? blue.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: active ? blue : grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDummyBarChart() {
    const grey = Color(0xFF8A8A9A);
    final dummyMonths = ['Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt'];
    final dummyValues = [3.5, 4.2, 2.8, 4.0, 3.8, 6.2];
    return BarChart(
      BarChartData(
        barGroups: List.generate(6, (i) => BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(
            toY: dummyValues[i],
            color: i == 5 ? Color(0xFF1877F2) : Color(0xFF90CAF9).withValues(alpha: 0.6),
            width: 32,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          )],
        )),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= 6) return SizedBox.shrink();
                final isLast = idx == 5;
                return Text(
                  dummyMonths[idx],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isLast ? Color(0xFF1877F2) : grey,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  BarChartData _buildBarChartData() {
    const grey = Color(0xFF8A8A9A);
    return BarChartData(
      barGroups: _bills.asMap().entries.map((e) {
        final isLast = e.key == _bills.length - 1;
        final value = _toggleUsage
            ? e.value.usageValue.toDouble()
            : e.value.price.toDouble() / 10000;
        return BarChartGroupData(
          x: e.key,
          barRods: [BarChartRodData(
            toY: value,
            color: isLast ? Color(0xFF1877F2) : Color(0xFF90CAF9).withValues(alpha: 0.6),
            width: 32,
            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
          )],
        );
      }).toList(),
      gridData: FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= _bills.length) return SizedBox.shrink();
              final isLast = idx == _bills.length - 1;
              return Text(
                FormatHelper.formatBulan(_bills[idx].month).substring(0, 3),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isLast ? Color(0xFF1877F2) : grey,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}