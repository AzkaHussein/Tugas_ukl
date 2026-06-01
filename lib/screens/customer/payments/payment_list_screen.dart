import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/payment_model.dart';
import '../../../widgets/customer_bottom_navbar.dart';
import 'payment_detail_screen.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  bool _isLoading = true;
  List<PaymentModel> _payments = [];
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getPaymentsMe();
      if (!mounted) return;
      if (response['success'] == true) {
        setState(() {
          _payments = (response['data'] as List? ?? [])
              .map((p) => PaymentModel.fromJson(p))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  num get _totalPaid => _payments
      .where((p) => p.verified)
      .fold(0, (sum, p) => sum + p.totalAmount);

  int get _verifiedCount => _payments.where((p) => p.verified).length;
  int get _pendingCount => _payments.where((p) => !p.verified).length;

  List<PaymentModel> get _filteredPayments {
    if (_selectedFilter == 'Terverifikasi') return _payments.where((p) => p.verified).toList();
    if (_selectedFilter == 'Menunggu') return _payments.where((p) => !p.verified).toList();
    return _payments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(20),
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 12,
            bottom: 12,
          ),
          child: Row(
            children: [
              const SizedBox(width: 20),
              Row(
                children: [
                  Image.asset(
                    'assets/images/water_drop.png',
                    width: 28,
                    height: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'WATERCASH',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1877F2),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF1877F2),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // SECTION 1 - SUMMARY CARD
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Pembayaran',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${FormatHelper.formatRupiah(_totalPaid)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Text(
                                '$_verifiedCount Terverifikasi',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Text(
                                '$_pendingCount Menunggu',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 56,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // SECTION 2 - FILTER TAB
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final label in ['Semua', 'Terverifikasi', 'Menunggu'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = label),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedFilter == label
                                ? const Color(0xFF1877F2)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: _selectedFilter == label
                                ? null
                                : Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _selectedFilter == label
                                  ? Colors.white
                                  : const Color(0xFF8A8A9A),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // SECTION 3 - LIST PEMBAYARAN
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_filteredPayments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: const Color(0xFF8A8A9A).withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Belum ada riwayat pembayaran',
                              style: TextStyle(
                                color: Color(0xFF8A8A9A),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredPayments.length,
                      itemBuilder: (ctx, idx) {
                        final payment = _filteredPayments[idx];
                        return GestureDetector(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentDetailScreen(payment: payment),
                              ),
                            );
                            if (result == true) _loadPayments();
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: payment.verified
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    payment.verified
                                        ? Icons.check_circle_outline
                                        : Icons.pending_outlined,
                                    color: payment.verified
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFF59E0B),
                                    size: 26,
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
                                          Text(
                                            'Tagihan ${payment.bill != null ? '${FormatHelper.formatBulan(payment.bill!.month)} ${payment.bill!.year}' : '#${payment.billId}'}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF1A1A2E),
                                            ),
                                          ),
                                          Text(
                                            'Rp ${FormatHelper.formatRupiah(payment.totalAmount)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF1877F2),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Pemakaian: ${payment.bill?.usageValue ?? '-'} m³',
                                            style: const TextStyle(
                                              color: Color(0xFF8A8A9A),
                                              fontSize: 12,
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              color: payment.verified
                                                  ? const Color(0xFFDCFCE7)
                                                  : const Color(0xFFFFF3CD),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            child: Text(
                                              payment.verified ? 'Terverifikasi' : 'Menunggu',
                                              style: TextStyle(
                                                color: payment.verified
                                                    ? const Color(0xFF22C55E)
                                                    : const Color(0xFFF59E0B),
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        FormatHelper.formatTanggal(payment.paymentDate),
                                        style: const TextStyle(
                                          color: Color(0xFF8A8A9A),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNavbar(currentIndex: 1),
    );
  }
}
