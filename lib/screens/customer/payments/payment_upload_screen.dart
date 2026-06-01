import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import 'payment_success_screen.dart';

class PaymentUploadScreen extends StatefulWidget {
  final BillModel bill;
  final String method;

  const PaymentUploadScreen({
    super.key,
    required this.bill,
    required this.method,
  });

  @override
  State<PaymentUploadScreen> createState() => _PaymentUploadScreenState();
}

class _PaymentUploadScreenState extends State<PaymentUploadScreen> {
  XFile? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) return;

    setState(() => _isLoading = true);

    // Demo mode - simulate payment without API
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Generate a simulated payment ID
    final simulatedPaymentId = DateTime.now().millisecondsSinceEpoch % 100000;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo Mode - Pembayaran berhasil disimulasikan!'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          bill: widget.bill,
          method: widget.method,
          paymentId: simulatedPaymentId,
        ),
      ),
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            SizedBox(
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
            const SizedBox(height: 32),
            // Section 1 - Total Tagihan
            Center(
              child: Column(
                children: [
                  Text(
                    'TOTAL TAGIHAN',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textGrey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rp ${FormatHelper.formatRupiah(widget.bill.price)}',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Section 2 - Upload Bukti
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unggah bukti pembayaran',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Mohon unggah foto atau tangkapan layar bukti transfer bank Anda yang jelas untuk mempercepat verifikasi.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Upload Area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                  color: const Color(0xFFF0F4FF),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBlue,
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ketuk untuk mengambil gambar',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'atau memilih file',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'JPG, PNG atau PDF (Max 5MB)',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textGrey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: Text(
                              'Pilih File',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FutureBuilder<List<int>>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    Uint8List.fromList(snapshot.data!),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return Container(
                                  width: double.infinity,
                                  height: 180,
                                  color: Colors.grey[200],
                                  child: const Center(child: CircularProgressIndicator()),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImage = null),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.error,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.white,
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_selectedImage == null) return;
                    _submitPayment();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _selectedImage != null
                  ? AppColors.primaryBlue
                  : AppColors.textGrey,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Konfirmasi Pembayaran',
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
