import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';

class BillDetailScreen extends StatefulWidget {
  final BillModel bill;
  const BillDetailScreen({super.key, required this.bill});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  bool _isLoading = false;

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyAccepted() async {
    final payment = widget.bill.payments?.isNotEmpty == true ? widget.bill.payments!.first : null;
    if (payment == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Terima Pembayaran'),
        content: Text('Konfirmasi penerimaan pembayaran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF22C55E)),
            child: const Text('Terima', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.verifyPaymentAccepted(payment.id);
      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran diterima'), backgroundColor: Color(0xFF22C55E)),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koneksi gagal'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyRejected() async {
    final payment = widget.bill.payments?.isNotEmpty == true ? widget.bill.payments!.first : null;
    if (payment == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Tolak Pembayaran'),
        content: Text('Yakin ingin menolak pembayaran ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.verifyPaymentRejected(payment.id);
      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran ditolak'), backgroundColor: Colors.orange),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Koneksi gagal'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final payment = widget.bill.payments?.isNotEmpty == true ? widget.bill.payments!.first : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Tagihan', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD 1 - INFO TAGIHAN
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Tagihan',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const Divider(),
                  _infoRow("No. Meter", widget.bill.measurementNumber),
                  _infoRow("Periode", '${FormatHelper.formatBulan(widget.bill.month)} ${widget.bill.year}'),
                  _infoRow("Pemakaian", '${widget.bill.usageValue} m³'),
                  _infoRow("Harga", FormatHelper.formatRupiah(widget.bill.price)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(
                            'Status',
                            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.bill.paid ? const Color(0xFFDCFCE7) : const Color(0xFFFFE4E4),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  widget.bill.paid ? 'LUNAS' : 'BELUM BAYAR',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: widget.bill.paid ? const Color(0xFF22C55E) : const Color(0xFFFF3B30),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // CARD 2 - INFO CUSTOMER
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Customer',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  const Divider(),
                  _infoRow("Nama", widget.bill.customer?.name ?? '-'),
                  _infoRow("No. Pelanggan", widget.bill.customer?.customerNumber ?? '-'),
                  _infoRow("Alamat", widget.bill.customer?.address ?? '-'),
                  _infoRow("Layanan", widget.bill.service?.name ?? '-'),
                ],
              ),
            ),

            // CARD 3 - INFO PEMBAYARAN (hanya jika ada payment)
            if (payment != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Info Pembayaran',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                    ),
                    const Divider(),
                    _infoRow("Tanggal Bayar", FormatHelper.formatTanggal(payment.paymentDate)),
                    _infoRow("Total Bayar", FormatHelper.formatRupiah(payment.totalAmount)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(
                              'Status Verifikasi',
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: payment.verified ? const Color(0xFFDCFCE7) : const Color(0xFFFFF3CD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    payment.verified ? 'Terverifikasi' : 'Menunggu',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: payment.verified ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Bukti Pembayaran',
                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://learn.smktelkom-mlg.sch.id/pdam/payment-proof/${payment.paymentProof}',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: const Color(0xFFF5F5F5),
                          child: const Center(child: Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey)),
                        ),
                        loadingBuilder: (_, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // TOMBOL VERIFIKASI (hanya jika ada payment dan belum verified)
            if (payment != null && !payment.verified) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyAccepted,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22C55E),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      'Terima Pembayaran',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isLoading ? null : _verifyRejected,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: Color(0xFFFF3B30)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel_outlined, color: Color(0xFFFF3B30)),
                    const SizedBox(height: 8),
                    Text(
                      'Tolak Pembayaran',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFFF3B30)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}