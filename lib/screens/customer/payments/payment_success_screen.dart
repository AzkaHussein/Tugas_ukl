import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import '../dashboard/customer_dashboard_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final BillModel bill;
  final String method;
  final int paymentId;

  const PaymentSuccessScreen({
    super.key,
    required this.bill,
    required this.method,
    required this.paymentId,
  });

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF0F0F0)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),

              // Success Animation
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Bukti Pembayaran',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                'Terkirim',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Terima kasih! Bukti pembayaran Anda telah kami terima dan sedang dalam proses verifikasi oleh tim admin kami',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textGrey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Info Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F8FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _infoRow(
                      'NO. TRANSAKSI',
                      'AF-${paymentId.toString().padLeft(8, '0')}',
                    ),
                    _infoRow(
                      'Waktu Pengiriman',
                      FormatHelper.formatTanggal(DateTime.now().toString()),
                    ),
                    _infoRow(
                      'Metode Pembayaran',
                      method == 'bank' ? 'Transfer Bank BCA' : 'E-Wallet DANA',
                    ),
                    _infoRow(
                      'Status',
                      'SUCCESS',
                      valueColor: const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Back to Home Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SafeArea(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Kembali Ke Beranda',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
