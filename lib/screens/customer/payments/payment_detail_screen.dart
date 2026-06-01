import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/payment_model.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/constants/app_colors.dart';

class PaymentDetailScreen extends StatelessWidget {
  final PaymentModel payment;
  const PaymentDetailScreen({super.key, required this.payment});

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Color(0xFF8A8A9A), fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Color(0xFF1A1A2E),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pembayaran',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1877F2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F8FF),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // CARD 1 - STATUS PEMBAYARAN
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: payment.verified ? Color(0xFFDCFCE7) : Color(0xFFFFF3CD),
                      ),
                      child: Icon(
                        payment.verified ? Icons.check_circle : Icons.pending,
                        size: 36,
                        color: payment.verified ? Color(0xFF22C55E) : Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      payment.verified ? 'Pembayaran Terverifikasi' : 'Menunggu Verifikasi',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: payment.verified ? Color(0xFF22C55E) : Color(0xFFF59E0B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tanggal: ${FormatHelper.formatTanggal(payment.paymentDate)}',
                      style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ),
            ),

            // CARD 2 - INFO PEMBAYARAN
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                  Divider(),
                  _infoRow("ID Pembayaran", "#${payment.id}"),
                  _infoRow("Total Bayar", FormatHelper.formatRupiah(payment.totalAmount)),
                  _infoRow("Tanggal", FormatHelper.formatTanggal(payment.paymentDate)),
                  _infoRow("Status", payment.verified ? "Terverifikasi" : "Menunggu Verifikasi"),
                ],
              ),
            ),

            // CARD 3 - INFO TAGIHAN
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info Tagihan',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                  Divider(),
                  _infoRow(
                    "Periode",
                    payment.bill != null
                        ? "${FormatHelper.formatBulan(payment.bill!.month)} ${payment.bill!.year}"
                        : '-',
                  ),
                  _infoRow(
                    "Pemakaian",
                    payment.bill != null ? "${payment.bill!.usageValue} m³" : '-',
                  ),
                  _infoRow(
                    "Harga Tagihan",
                    payment.bill != null ? FormatHelper.formatRupiah(payment.bill!.price) : '-',
                  ),
                ],
              ),
            ),

            // CARD 4 - BUKTI PEMBAYARAN
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bukti Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1877F2),
                    ),
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      'https://learn.smktelkom-mlg.sch.id/pdam/payment-proof/${payment.paymentProof}',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 250,
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Gambar tidak tersedia', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ),
                      loadingBuilder: (_, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 250,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}