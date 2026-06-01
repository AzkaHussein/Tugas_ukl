import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/api_service.dart';

import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import '../../../widgets/admin_bottom_navbar.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  bool _isLoading = true;
  final List<BillModel> _bills = [];

  int? _selectedMonth;
  String _selectedStatus = 'All';

  int get _pendingCount {
    if (_bills.isEmpty) return 2;
    return _bills.where((b) => b.paid == true && b.verifiedPayment == false).length;
  }

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getBills();
      final data = response['data'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _bills
          ..clear()
          ..addAll(data.map((b) => BillModel.fromJson(b)).toList());
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _displayItems {
    if (_bills.isNotEmpty) {
      return _bills.map((b) => {
        'id': b.id,
        'customerName': b.customer?.name ?? 'Customer',
        'customerNumber': b.customer?.customerNumber ?? '99281',
        'serviceName': b.service?.name ?? 'Residential A',
        'price': b.price,
        'uploadedTime': b.payments?.isNotEmpty == true
          ? b.payments!.first.paymentDate : null,
        'hasPayment': b.payments?.isNotEmpty == true,
        'isVerified': b.verifiedPayment == true,
        'paymentId': b.payments?.isNotEmpty == true ? b.payments!.first.id : null,
        'bill': b,
      }).toList();
    }
    return [
      {
        'id': 1,
        'customerName': 'Ihsan Ufiq',
        'customerNumber': '99281',
        'serviceName': 'Residential A',
        'price': 120000,
        'uploadedTime': null,
        'hasPayment': true,
        'isVerified': false,
        'paymentId': 1,
        'bill': null,
      },
      {
        'id': 2,
        'customerName': 'User Saya',
        'customerNumber': '99282',
        'serviceName': 'Residential B',
        'price': 85000,
        'uploadedTime': null,
        'hasPayment': true,
        'isVerified': false,
        'paymentId': 2,
        'bill': null,
      },
    ];
  }

  List<Map<String, dynamic>> get _filteredItems {
    return _displayItems.where((item) {
      final statusOk = _selectedStatus == 'All' ||
          (_selectedStatus == 'Pending' && item['isVerified'] == false && item['hasPayment'] == true) ||
          (_selectedStatus == 'Verified' && item['isVerified'] == true) ||
          (_selectedStatus == 'Rejected' && item['hasPayment'] == false);
      return statusOk;
    }).toList();
  }

  Future<void> _acceptItem(Map<String, dynamic> item) async {
    final paymentId = item['paymentId'] as int?;
    if (paymentId == null) {
      _showSuccessSheet();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.verifyPaymentAccepted(paymentId);
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (response['success'] == true) {
        _showSuccessSheet();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi gagal'), backgroundColor: Colors.red));
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF22C55E)),
              child: Icon(Icons.check, color: Colors.white, size: 36),
            ),
            SizedBox(height: 16),
            Text('Pembayaran Diterima!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF1A1A2E))),
            SizedBox(height: 8),
            Text(
              'Pembayaran telah berhasil diverifikasi dan status tagihan pelanggan telah diperbarui.',
              style: GoogleFonts.poppins(fontSize: 13, color: Color(0xFF8A8A9A)),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _loadBills();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF22C55E),
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Tutup',
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _rejectItem(Map<String, dynamic> item) async {
    final paymentId = item['paymentId'] as int?;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Pembayaran'),
        content: Text('Yakin ingin menolak pembayaran ini? Pelanggan perlu mengajukan ulang bukti.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    if (paymentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Colors.orange));
      return;
    }
    try {
      final response = await ApiService.verifyPaymentRejected(paymentId);
      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Colors.orange));
        _loadBills();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Koneksi gagal'), backgroundColor: Colors.red));
    }
  }

  String _timeAgo(String? dateStr) {
    if (dateStr == null) return '2 jam';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '2 jam';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit';
    if (diff.inHours < 24) return '${diff.inHours} jam';
    return '${diff.inDays} hari';
  }

  Future<void> _showMonthSheet() async {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulan Penagihan',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, idx) {
                    final month = idx + 1;
                    final label = months[idx];
                    final selected = _selectedMonth == month;
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedMonth = month);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF1877F2).withOpacity(0.1) : Colors.white,
                          border: Border.all(
                            color: selected ? const Color(0xFF1877F2) : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected ? const Color(0xFF1877F2) : const Color(0xFF8A8A9A),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selectedMonth = null);
                      Navigator.pop(ctx);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Semua Bulan',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1A2E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStatusSheet() async {
    const statuses = ['Semua', 'Pending', 'Verified', 'Rejected'];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 12),
                ...statuses.map((status) {
                  final selected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => _selectedStatus = status);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFF1877F2).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected ? const Color(0xFF1877F2) : const Color(0xFFE0E0E0),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                            color: selected ? const Color(0xFF1877F2) : const Color(0xFF8A8A9A),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  String _selectedMonthLabel() {
    if (_selectedMonth == null) return 'Semua';
    return FormatHelper.formatBulan(_selectedMonth!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
          child: Row(
            children: [
              Image.asset(
                'assets/images/water_drop.png',
                height: 28,
                width: 28,
              ),
              const SizedBox(width: 8),
              Text(
                'WATERCASH',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1877F2),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.notifications_outlined,
                size: 26,
                color: Color(0xFF1877F2),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SECTION 1 - JUDUL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kelola Tagihan',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tinjau penggunaan bulanan dan verifikasi pembayaran yang tertunda.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF8A8A9A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // SECTION 2 - FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showMonthSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bulan Penagihan',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: const Color(0xFF8A8A9A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _selectedMonthLabel(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                  color: Color(0xFF8A8A9A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _showStatusSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Status',
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: const Color(0xFF8A8A9A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      _selectedStatus,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF1A1A2E),
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                const Icon(
                                  Icons.filter_alt_outlined,
                                  size: 18,
                                  color: Color(0xFF8A8A9A),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loadBills,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.refresh, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'Bulan Penagihan',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // SECTION 3 - PENDING TASKS CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'TUGAS YANG TERTUNDA',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_pendingCount',
                      style: GoogleFonts.poppins(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bukti Pembayaran',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // SECTION 4 - PAYMENT VERIFICATION LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Verifikasi Pembayaran',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A2E),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Text(
                          'Prioritas Tinggi',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFFF3B30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _filteredItems.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (ctx, idx) {
                            final item = _filteredItems[idx];
                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 12, offset: Offset(0, 4))],
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(
                                          'ACC-${item['customerNumber']}',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1A1A2E)),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${item['customerName']} • ${item['serviceName']}',
                                          style: GoogleFonts.poppins(fontSize: 12, color: Color(0xFF8A8A9A)),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Diunggah ${_timeAgo(item['uploadedTime'] as String?)} yang lalu',
                                          style: GoogleFonts.poppins(fontSize: 11, color: Color(0xFF8A8A9A)),
                                        ),
                                      ]),
                                      Text(
                                        'Rp ${FormatHelper.formatRupiah(item['price'] as num)}',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1877F2)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12),
                                  Row(children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _rejectItem(item),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: Color(0xFFFF3B30)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: Text('Menolak',
                                          style: GoogleFonts.poppins(
                                            color: Color(0xFFFF3B30), fontWeight: FontWeight.w700, fontSize: 14)),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _acceptItem(item),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF22C55E),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        child: Text('Menerima',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
    );
  }
}