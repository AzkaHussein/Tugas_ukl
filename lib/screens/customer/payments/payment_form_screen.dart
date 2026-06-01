import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/bill_model.dart';
import '../../../core/utils/format_helper.dart';
import '../../../core/constants/app_colors.dart';

class PaymentFormScreen extends StatefulWidget {
  final BillModel bill;
  const PaymentFormScreen({super.key, required this.bill});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  XFile? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _selectedImage = picked);
    }
  }

  Future<void> _submitPayment() async {
    if (_selectedImage == null) return;
    setState(() => _isLoading = true);

    // Demo mode - simulate payment success without API
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo Mode - Pembayaran berhasil disimulasikan!'),
        backgroundColor: Color(0xFF22C55E),
        duration: const Duration(seconds: 2),
      ));
    Navigator.pop(context, true);
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
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
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
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
          'Bayar Tagihan',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color(0xFF1877F2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Color(0xFFF5F8FF),
      body: Column(
        children: [
          // Progress Indicator Step 2
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 28),
                    // Stepper 1 - Completed
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color(0xFF22C55E),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 16,
                        color: Color(0xFF22C55E),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Line
                    Expanded(
                      child: Container(
                        height: 2,
                        color: const Color(0xFF1877F2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stepper 2 - Active
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1877F2),
                      ),
                      child: const Center(
                        child: Text(
                          '2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Tagihan',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                    Text(
                      'Upload Bukti',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1877F2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // CARD 1 - INFO TAGIHAN
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Tagihan',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1877F2),
                          ),
                        ),
                        Divider(),
                        _infoRow("Periode", "${FormatHelper.formatBulan(widget.bill.month)} ${widget.bill.year}"),
                        _infoRow("Pemakaian", "${widget.bill.usageValue} m³"),
                        _infoRow("Total Tagihan", FormatHelper.formatRupiah(widget.bill.price)),
                        _infoRow("Customer", widget.bill.customer?.name ?? '-'),
                      ],
                    ),
                  ),

                  // CARD 2 - UPLOAD BUKTI
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(bottom: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upload Bukti Pembayaran',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1877F2),
                          ),
                        ),
                        Divider(),
                        SizedBox(height: 12),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: _selectedImage == null
                                  ? Border.all(
                                      color: Color(0xFF1877F2),
                                      width: 1.5,
                                      style: BorderStyle.solid,
                                    )
                                  : null,
                              color: _selectedImage == null ? Color(0xFFF0F4FF) : null,
                            ),
                            child: _selectedImage == null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_outlined,
                                        size: 48,
                                        color: Color(0xFF1877F2),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Tap untuk upload bukti',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1877F2),
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Format: JPG, PNG, JPEG, PDF',
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textGrey,
                                        ),
                                      ),
                                    ],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        FutureBuilder<List<int>>(
                                          future: _selectedImage!.readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                Uint8List.fromList(snapshot.data!),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 200,
                                              );
                                            }
                                            return Container(
                                              width: double.infinity,
                                              height: 200,
                                              color: Colors.grey[200],
                                              child: const Center(child: CircularProgressIndicator()),
                                            );
                                          },
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () => setState(() => _selectedImage = null),
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _selectedImage == null || _isLoading ? null : _submitPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedImage == null || _isLoading
                                ? Colors.grey
                                : Color(0xFF1877F2),
                            minimumSize: Size(double.infinity, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Kirim Pembayaran',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}