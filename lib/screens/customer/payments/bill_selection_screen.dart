import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/bill_model.dart';
import '../../../models/customer_model.dart';
import '../../../models/service_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import 'payment_detail_bill_screen.dart';

class BillSelectionScreen extends StatefulWidget {
  final List<BillModel>? initialBills;

  const BillSelectionScreen({super.key, this.initialBills});

  @override
  State<BillSelectionScreen> createState() => _BillSelectionScreenState();
}

class _BillSelectionScreenState extends State<BillSelectionScreen> {
  bool _isLoading = true;
  List<BillModel> _unpaidBills = [];
  BillModel? _selectedBill;

  @override
  void initState() {
    super.initState();
    _loadUnpaidBills();
  }

  List<BillModel> _getDummyBills() {
    // Create dummy bills for demo/testing purposes
    return [
      BillModel(
        id: 1,
        customerId: 1,
        adminId: 1,
        month: 6,
        year: 2026,
        measurementNumber: 'WM-001234',
        usageValue: 15,
        price: 75000,
        serviceId: 1,
        paid: false,
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
        service: ServiceModel(
          id: 1,
          name: 'Paket Rumah Tangga',
          minUsage: 0,
          maxUsage: 50,
          price: 4500,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
      BillModel(
        id: 2,
        customerId: 1,
        adminId: 1,
        month: 5,
        year: 2026,
        measurementNumber: 'WM-001234',
        usageValue: 12,
        price: 60000,
        serviceId: 1,
        paid: false,
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
        service: ServiceModel(
          id: 1,
          name: 'Paket Rumah Tangga',
          minUsage: 0,
          maxUsage: 50,
          price: 4500,
          ownerToken: 'dummy',
          createdAt: '',
          updatedAt: '',
        ),
      ),
    ];
  }

  Future<void> _loadUnpaidBills() async {
    setState(() => _isLoading = true);

    // Use initial bills from dashboard if available
    if (widget.initialBills != null && widget.initialBills!.isNotEmpty) {
      final filtered = widget.initialBills!.where((b) => !b.paid).toList();
      setState(() {
        _unpaidBills = filtered.isNotEmpty ? filtered : _getDummyBills();
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await ApiService.getBillsMe();
      if (!mounted) return;
      if (response['success'] == true) {
        final all = (response['data'] as List? ?? [])
            .map((b) => BillModel.fromJson(b))
            .toList();
        final filtered = all.where((b) => !b.paid).toList();
        setState(() {
          _unpaidBills = filtered.isNotEmpty ? filtered : _getDummyBills();
          _isLoading = false;
        });
      } else {
        setState(() {
          _unpaidBills = _getDummyBills();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _unpaidBills = _getDummyBills();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bayar Tagihan',
          style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1877F2),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F8FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _unpaidBills.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Color(0xFF22C55E),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Semua tagihan lunas!',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tidak ada tagihan yang perlu dibayar',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xFF8A8A9A),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Progress Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 28),
                              // Stepper 1 - Active
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF1877F2),
                                ),
                                child: const Center(
                                  child: Text(
                                    '1',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
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
                              // Stepper 2 - Inactive
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Color(0xFF8A8A9A),
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
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1877F2),
                                ),
                              ),
                              Text(
                                'Upload Bukti',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(0xFF8A8A9A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Body
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pilih tagihan yang ingin dibayar',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF8A8A9A),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _unpaidBills.length,
                              itemBuilder: (context, index) {
                                final bill = _unpaidBills[index];
                                final isSelected = _selectedBill?.id == bill.id;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedBill = bill),
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFFEEF4FF)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF1877F2)
                                            : const Color(0xFFE0E0E0),
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.04),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFF1877F2)
                                                  : const Color(0xFFE0E0E0),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected
                                              ? Container(
                                                  margin: const EdgeInsets.all(3),
                                                  decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF1877F2),
                                                  ),
                                                )
                                              : null,
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
                                                    '${FormatHelper.formatBulan(bill.month)} ${bill.year}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: const Color(0xFF1A1A2E),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFFE4E4),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      'Belum Bayar',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                        color: const Color(0xFFFF3B30),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Pemakaian',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10,
                                                          color: const Color(0xFF8A8A9A),
                                                        ),
                                                      ),
                                                      Text(
                                                        '${bill.usageValue} m³',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 13,
                                                          fontWeight: FontWeight.bold,
                                                          color: const Color(0xFF1A1A2E),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Tagihan',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 10,
                                                          color: const Color(0xFF8A8A9A),
                                                        ),
                                                      ),
                                                      Text(
                                                        'Rp ${FormatHelper.formatRupiah(bill.price)}',
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
                                              const SizedBox(height: 6),
                                              Text(
                                                'No. Meter: ${bill.measurementNumber}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11,
                                                  color: const Color(0xFF8A8A9A),
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
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                    // Continue Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: ElevatedButton(
                        onPressed: _selectedBill == null
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PaymentDetailBillScreen(bill: _selectedBill!),
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedBill != null
                              ? const Color(0xFF1877F2)
                              : const Color(0xFF8A8A9A),
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Lanjut → Upload Bukti',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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