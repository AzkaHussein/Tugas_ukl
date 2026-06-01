import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/payment_model.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/customer_bottom_navbar.dart';
import '../payments/payment_detail_screen.dart';

class CustomerActivityScreen extends StatefulWidget {
  const CustomerActivityScreen({super.key});

  @override
  State<CustomerActivityScreen> createState() => _CustomerActivityScreenState();
}

class _CustomerActivityScreenState extends State<CustomerActivityScreen> {
  bool _isLoading = true;
  List<PaymentModel> _payments = [];
  List<BillModel> _bills = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getPaymentsMe(),
        ApiService.getBillsMe(),
      ]);
      if (!mounted) return;

      List<PaymentModel> payments = [];
      List<BillModel> bills = [];

      if (results[0]['success'] == true) {
        payments = (results[0]['data'] as List? ?? [])
            .map((p) => PaymentModel.fromJson(p))
            .toList();
      }

      if (results[1]['success'] == true) {
        bills = (results[1]['data'] as List? ?? [])
            .map((b) => BillModel.fromJson(b))
            .toList();
      }

      setState(() {
        _payments = payments;
        _bills = bills;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _activityItems {
    List<Map<String, dynamic>> items = [];

    for (final p in _payments) {
      if (p.verified) {
        items.add({
          'type': 'verified',
          'title': 'Pembayaran Terverifi...',
          'subtitle': _formatTanggalJam(p.paymentDate),
          'amount': p.totalAmount,
          'status': 'SUCCESS',
        });
      } else {
        items.add({
          'type': 'pending',
          'title': 'Bukti Bayar Diunggah',
          'subtitle': _formatTanggalJam(p.paymentDate),
          'amount': p.totalAmount,
          'status': 'PENDING',
        });
      }
    }

    for (final b in _bills) {
      items.add({
        'type': 'bill',
        'title': 'Tagihan Baru Diterbit..',
        'subtitle': '${FormatHelper.formatBulan(b.month)} ${b.year}',
        'amount': b.price,
        'status': b.paid ? 'PAID' : 'UNPAID',
      });
    }

    if (items.isEmpty) {
      items = [
        {
          'type': 'verified',
          'title': 'Pembayaran Terverifi...',
          'subtitle': '14 Agu 2026, 09.20',
          'amount': 156400,
          'status': 'SUCCESS',
        },
        {
          'type': 'bill',
          'title': 'Tagihan Baru Diterbit..',
          'subtitle': '10 Jun 2026, 08.00',
          'amount': 172000,
          'status': 'UNPAID',
        },
        {
          'type': 'pending',
          'title': 'Bukti Bayar Diunggah',
          'subtitle': '14 Agu 2026, 09.15',
          'amount': 156400,
          'status': 'PENDING',
        },
        {
          'type': 'pending',
          'title': 'Bukti Bayar Diunggah',
          'subtitle': '10 Jun 2026, 09.00',
          'amount': 172000,
          'status': 'PENDING',
        },
      ];
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
    if (_payments.isEmpty) return 120000;
    return _payments.where((p) => p.verified).fold(0, (s, p) => s + p.totalAmount);
  }

  int get _verifiedCount => _payments.isEmpty ? 1 : _payments.where((p) => p.verified).length;

  int get _pendingCount => _payments.isEmpty ? 0 : _payments.where((p) => !p.verified).length;

  List<Map<String, dynamic>> get _filteredItems {
    if (_selectedFilter == 'Terverifikasi') {
      return _activityItems.where((i) => i['type'] == 'verified').toList();
    }
    if (_selectedFilter == 'Pembayaran') {
      return _activityItems.where((i) => i['type'] == 'verified' || i['type'] == 'pending').toList();
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
                                Text('Total Pembayaran',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 13)),
                                const SizedBox(height: 4),
                                Text('Rp ${FormatHelper.formatRupiah(_totalPaid)}',
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
                            Icon(Icons.account_balance_wallet_outlined,
                              color: Colors.white.withValues(alpha: 0.3),
                              size: 56),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: ['Semua', 'Terverifikasi', 'Pembayaran'].map((label) {
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
                        child: Text('Riwayat Transaksi',
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

                            if (type == 'verified') {
                              iconBg = const Color(0xFFDCFCE7);
                              iconColor = const Color(0xFF22C55E);
                              iconData = Icons.check_circle_outline;
                              statusBg = const Color(0xFFDCFCE7);
                              statusColor = const Color(0xFF22C55E);
                            } else if (type == 'bill') {
                              iconBg = const Color(0xFFEEF4FF);
                              iconColor = const Color(0xFF1877F2);
                              iconData = Icons.description_outlined;
                              statusBg = status == 'UNPAID'
                                  ? const Color(0xFFFFE4E4)
                                  : const Color(0xFFDCFCE7);
                              statusColor = status == 'UNPAID'
                                  ? const Color(0xFFFF3B30)
                                  : const Color(0xFF22C55E);
                            } else {
                              iconBg = const Color(0xFFEEF4FF);
                              iconColor = const Color(0xFF1877F2);
                              iconData = Icons.cloud_upload_outlined;
                              statusBg = const Color(0xFFFFF3CD);
                              statusColor = const Color(0xFFF59E0B);
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
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item['subtitle'] as String,
                                              style: GoogleFonts.poppins(
                                                fontSize: 11,
                                                color: grey,
                                              ),
                                            ),
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
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 1),
    );
  }
}
