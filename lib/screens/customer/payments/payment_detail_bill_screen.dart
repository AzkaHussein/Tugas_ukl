import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import 'payment_upload_screen.dart';

class PaymentDetailBillScreen extends StatefulWidget {
  final BillModel bill;

  const PaymentDetailBillScreen({super.key, required this.bill});

  @override
  State<PaymentDetailBillScreen> createState() => _PaymentDetailBillScreenState();
}

class _PaymentDetailBillScreenState extends State<PaymentDetailBillScreen> {
  String? _selectedMethod;

  Widget _biayaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
          ),
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priceAir = (widget.bill.service?.price ?? 4500) * widget.bill.usageValue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Text(
              'Detail Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const Spacer(),
            Container(
              height: 24,
              child: Image.asset(
                'assets/images/water_drop.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Card 1 - ID Pelanggan
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFF0F0F0)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ID PELANGGAN',
                              style: GoogleFonts.inter(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textGrey,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'AF-${widget.bill.customer?.customerNumber ?? widget.bill.customerId}',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.description_outlined,
                          color: AppColors.primaryBlue,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card 2 - Bulan & Pemakaian
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BULAN TAGIHAN',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${FormatHelper.formatBulan(widget.bill.month)} ${widget.bill.year}',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PEMAKAIAN',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.bill.usageValue} m³',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card 3 - Rincian Biaya
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rincian Biaya',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _biayaRow(
                    'Biaya Air (Pr ${widget.bill.service?.price ?? 4500} x ${widget.bill.usageValue})',
                    'Rp ${FormatHelper.formatRupiah(priceAir)}',
                  ),
                  _biayaRow('Biaya Administrasi', 'Rp 5.000'),
                  _biayaRow('Biaya Pemeliharaan', 'Rp 2.500'),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Tagihan',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Rp ${FormatHelper.formatRupiah(widget.bill.price)}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Card 4 - Metode Pembayaran
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Metode Pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'bank'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 'bank'
                              ? AppColors.primaryBlue
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        color: _selectedMethod == 'bank'
                            ? const Color(0xFFEEF4FF)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFEEF4FF),
                            ),
                            child: const Icon(
                              Icons.account_balance_outlined,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Transfer Bank (VA)',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'BCA, Mandiri, BNI',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Radio(
                            value: 'bank',
                            groupValue: _selectedMethod,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) => setState(() => _selectedMethod = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedMethod = 'ewallet'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == 'ewallet'
                              ? AppColors.primaryBlue
                              : const Color(0xFFE0E0E0),
                          width: 1.5,
                        ),
                        color: _selectedMethod == 'ewallet'
                            ? const Color(0xFFEEF4FF)
                            : Colors.white,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color(0xFFEEF4FF),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              color: AppColors.primaryBlue,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'E-Wallet',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                'DANA, OVO, GoPay',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Radio(
                            value: 'ewallet',
                            groupValue: _selectedMethod,
                            activeColor: AppColors.primaryBlue,
                            onChanged: (value) => setState(() => _selectedMethod = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              if (_selectedMethod == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilih metode pembayaran'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentUploadScreen(
                      bill: widget.bill,
                      method: _selectedMethod!,
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Lanjut Pembayaran',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
