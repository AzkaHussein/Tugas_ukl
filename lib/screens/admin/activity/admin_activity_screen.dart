import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/payment_model.dart';
import '../../../models/bill_model.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/admin_bottom_navbar.dart';

class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  bool _isLoading = true;
  List<PaymentModel> _payments = [];
  List<BillModel> _bills = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<PaymentModel> _getDummyPayments() {
    return [
      PaymentModel(
        id: 1,
        billId: 1,
        totalAmount: 75000,
        verified: true,
        paymentDate: '2026-06-01T10:30:00',
        paymentProof: 'proof_1.jpg',
        ownerToken: 'dummy',
        bill: BillModel(
          id: 1,
          customerId: 1,
          adminId: 1,
          month: 6,
          year: 2026,
          measurementNumber: 'WM-001234',
          usageValue: 15,
          price: 75000,
          serviceId: 1,
          paid: true,
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
        ),
      ),
      PaymentModel(
        id: 2,
        billId: 2,
        totalAmount: 60000,
        verified: false,
        paymentDate: '2026-06-01T09:15:00',
        paymentProof: 'proof_2.jpg',
        ownerToken: 'dummy',
        bill: BillModel(
          id: 2,
          customerId: 2,
          adminId: 1,
          month: 5,
          year: 2026,
          measurementNumber: 'WM-001235',
          usageValue: 12,
          price: 60000,
          serviceId: 1,
          paid: false,
          ownerToken: 'dummy',
          customer: CustomerModel(
            id: 2,
            userId: 2,
            customerNumber: '001235',
            name: 'Jane Smith',
            phone: '08123456790',
            address: 'Jl. Example No. 2',
            serviceId: 1,
            ownerToken: 'dummy',
            createdAt: '',
            updatedAt: '',
          ),
        ),
      ),
      PaymentModel(
        id: 3,
        billId: 3,
        totalAmount: 90000,
        verified: false,
        paymentDate: '2026-05-30T14:20:00',
        paymentProof: 'proof_3.jpg',
        ownerToken: 'dummy',
        bill: BillModel(
          id: 3,
          customerId: 3,
          adminId: 1,
          month: 5,
          year: 2026,
          measurementNumber: 'WM-001236',
          usageValue: 18,
          price: 90000,
          serviceId: 1,
          paid: false,
          ownerToken: 'dummy',
          customer: CustomerModel(
            id: 3,
            userId: 3,
            customerNumber: '001236',
            name: 'Bob Wilson',
            phone: '08123456791',
            address: 'Jl. Test No. 3',
            serviceId: 1,
            ownerToken: 'dummy',
            createdAt: '',
            updatedAt: '',
          ),
        ),
      ),
    ];
  }

  List<BillModel> _getDummyBills() {
    return [
      BillModel(
        id: 4,
        customerId: 4,
        adminId: 1,
        month: 6,
        year: 2026,
        measurementNumber: 'WM-001237',
        usageValue: 20,
        price: 100000,
        serviceId: 1,
        paid: false,
        ownerToken: 'dummy',
        customer: CustomerModel(
          id: 4,
          userId: 4,
          customerNumber: '001237',
          name: 'Alice Brown',
          phone: '08123456792',
          address: 'Jl. Sample No. 4',
          serviceId: 1,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
      BillModel(
        id: 5,
        customerId: 5,
        adminId: 1,
        month: 6,
        year: 2026,
        measurementNumber: 'WM-001238',
        usageValue: 25,
        price: 125000,
        serviceId: 1,
        paid: false,
        ownerToken: 'dummy',
        customer: CustomerModel(
          id: 5,
          userId: 5,
          customerNumber: '001238',
          name: 'Charlie Davis',
          phone: '08123456793',
          address: 'Jl. Mock No. 5',
          serviceId: 1,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
    ];
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Demo mode - use dummy data directly without API
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _payments = _getDummyPayments();
      _bills = _getDummyBills();
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _activityItems {
    List<Map<String, dynamic>> items = [];

    // Verifikasi Admin
    for (final p in _payments) {
      final customerName = p.bill?.customer?.name ?? 'Pelanggan';
      if (p.verified) {
        items.add({
          'type': 'admin_verif',
          'title': 'Verifikasi Admin',
          'subtitle': '$customerName - ${_formatTanggalJam(p.paymentDate)}',
          'amount': p.totalAmount,
          'status': 'VERIFIED',
        });
      } else {
        items.add({
          'type': 'admin_verif',
          'title': 'Verifikasi Admin',
          'subtitle': '$customerName - ${_formatTanggalJam(p.paymentDate)}',
          'amount': p.totalAmount,
          'status': 'PENDING',
        });
      }
    }

    // Kelola Service
    items.add({
      'type': 'service',
      'title': 'Kelola Service',
      'subtitle': 'Paket Rumah Tangga - 15 Juni 2026',
      'amount': 4500,
      'status': 'ADDED',
    });
    items.add({
      'type': 'service',
      'title': 'Kelola Service',
      'subtitle': 'Paket Bisnis - 10 Juni 2026',
      'amount': 7500,
      'status': 'UPDATED',
    });

    // Kelola Bills
    for (final b in _bills) {
      items.add({
        'type': 'bill',
        'title': 'Kelola Bills',
        'subtitle': '${b.customer?.name ?? 'Pelanggan'} - ${FormatHelper.formatBulan(b.month)} ${b.year}',
        'amount': b.price,
        'status': b.paid ? 'PAID' : 'UNPAID',
      });
    }

    return items;
  }

  String _formatTanggalJam(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${FormatHelper.formatBulan(date.month)} ${date.year} ${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  num get _totalPaid {
    if (_payments.isEmpty) return 0;
    return _payments.where((p) => p.verified).fold(0, (s, p) => s + p.totalAmount);
  }

  int get _verifiedCount => _payments.isEmpty ? 0 : _payments.where((p) => p.verified).length;

  int get _pendingCount => _payments.isEmpty ? 0 : _payments.where((p) => !p.verified).length;

  int get _totalActivities => _activityItems.length;

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'Verifikasi Admin') {
      return _activityItems.where((i) => i['type'] == 'admin_verif').toList();
    }
    if (_selectedFilter == 'Kelola Service') {
      return _activityItems.where((i) => i['type'] == 'service').toList();
    }
    if (_selectedFilter == 'Kelola Bills') {
      return _activityItems.where((i) => i['type'] == 'bill').toList();
    }
    return _activityItems;
  }

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1877F2);
    const grey = Color(0xFF8A8A9A);
    const dark = Color(0xFF1A1A2E);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Image.asset('assets/images/water_drop.png', width: 28, height: 28),
                  const SizedBox(width: 8),
                  Text('WATERCASH',
                    style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w700, color: blue)),
                  const Spacer(),
                  Icon(Icons.notifications_outlined, color: blue),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: blue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Total Aktivitas',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('$_totalActivities Aktivitas',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('$_verifiedCount Terverifikasi',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text('$_pendingCount Menunggu',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Icon(Icons.history,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 56),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: ['Semua', 'Verifikasi Admin', 'Kelola Service', 'Kelola Bills'].map((label) {
                            final isActive = _selectedFilter == label;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedFilter = label),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isActive ? blue : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isActive ? blue : const Color(0xFFE0E0E0)),
                                ),
                                child: Text(label,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive ? Colors.white : grey)),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text('Riwayat Aktivitas',
                          style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.w700, color: dark)),
                      ),
                      const SizedBox(height: 12),

                      if (_isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filteredItems.length,
                          itemBuilder: (ctx, idx) {
                            final item = _filteredItems[idx];
                            final type = item['type'] as String;
                            final status = item['status'] as String;

                            Color iconBg;
                            Color iconColor;
                            IconData iconData;
                            Color statusBg;
                            Color statusColor;

                            if (type == 'admin_verif') {
                              iconBg = const Color(0xFFDCFCE7);
                              iconColor = const Color(0xFF22C55E);
                              iconData = Icons.check_circle_outline;
                              statusBg = status == 'VERIFIED'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFFFF3CD);
                              statusColor = status == 'VERIFIED'
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFF59E0B);
                            } else if (type == 'service') {
                              iconBg = const Color(0xFFEEF4FF);
                              iconColor = const Color(0xFF1877F2);
                              iconData = Icons.settings_outlined;
                              statusBg = status == 'ADDED'
                                  ? const Color(0xFFDCFCE7)
                                  : const Color(0xFFEEF4FF);
                              statusColor = status == 'ADDED'
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFF1877F2);
                            } else {
                              iconBg = const Color(0xFFEEF4FF);
                              iconColor = const Color(0xFF1877F2);
                              iconData = Icons.description_outlined;
                              statusBg = status == 'UNPAID'
                                  ? const Color(0xFFFFE4E4)
                                  : const Color(0xFFDCFCE7);
                              statusColor = status == 'UNPAID'
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFF22C55E);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48, height: 48,
                                    decoration: BoxDecoration(
                                      color: iconBg,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(iconData, color: iconColor, size: 24),
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
                                                item['title'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 14,
                                                  color: dark,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Rp ${FormatHelper.formatRupiah(item['amount'] as num)}',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                color: blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item['subtitle'] as String,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: statusBg,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                status,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: statusColor,
                                                ),
                                              ),
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }
}