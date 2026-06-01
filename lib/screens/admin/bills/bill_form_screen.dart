import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../core/utils/format_helper.dart';
import '../../../models/bill_model.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/custom_button.dart';

class BillFormScreen extends StatefulWidget {
  final bool isEdit;
  final BillModel? bill;

  const BillFormScreen({super.key, required this.isEdit, this.bill});

  @override
  State<BillFormScreen> createState() => _BillFormScreenState();
}

class _BillFormScreenState extends State<BillFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _measurementController = TextEditingController();
  final _usageController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isLoading = false;
  List<CustomerModel> _customers = [];
  int? _selectedCustomerId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    if (widget.isEdit && widget.bill != null) {
      _measurementController.text = widget.bill!.measurementNumber;
      _usageController.text = widget.bill!.usageValue.toString();
      _yearController.text = widget.bill!.year.toString();
      _selectedCustomerId = widget.bill!.customerId;
      _selectedMonth = widget.bill!.month;
      _selectedYear = widget.bill!.year;
    } else {
      _yearController.text = DateTime.now().year.toString();
    }
  }

  Future<void> _loadCustomers() async {
    try {
      final response = await ApiService.getCustomers();
      final data = response['data'] as List? ?? [];
      if (!mounted) return;
      setState(() {
        _customers = data.map((c) => CustomerModel.fromJson(c)).toList();
      });
    } catch (e) {
      if (!mounted) return;
    }
  }

  @override
  void dispose() {
    _measurementController.dispose();
    _usageController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedCustomerId == null ||
        _measurementController.text.isEmpty ||
        _usageController.text.isEmpty ||
        _yearController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response;
      if (widget.isEdit) {
        response = await ApiService.updateBill(
          widget.bill!.id,
          month: _selectedMonth,
          year: int.parse(_yearController.text),
          measurementNumber: _measurementController.text.trim(),
          usageValue: num.parse(_usageController.text),
        );
      } else {
        response = await ApiService.createBill(
          customerId: _selectedCustomerId!,
          month: _selectedMonth,
          year: int.parse(_yearController.text),
          measurementNumber: _measurementController.text.trim(),
          usageValue: num.parse(_usageController.text),
        );
      }

      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? 'Tagihan berhasil diupdate' : 'Tagihan berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan tagihan')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: Text(
          widget.isEdit ? 'Edit Tagihan' : 'Tambah Tagihan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Customer dropdown - hidden if edit, disabled if edit
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Customer',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedCustomerId,
                            hint: const Text('Pilih customer', style: TextStyle(color: AppColors.textGrey)),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.person, color: AppColors.primaryBlue),
                            ),
                            items: _customers.map((c) {
                              return DropdownMenuItem<int>(
                                value: c.id,
                                child: Text(c.name),
                              );
                            }).toList(),
                            onChanged: widget.isEdit
                                ? null
                                : (value) => setState(() => _selectedCustomerId = value),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),

                    // Bulan dropdown
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Bulan',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<int>(
                            value: _selectedMonth,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.calendar_month, color: AppColors.primaryBlue),
                            ),
                            items: List.generate(12, (i) {
                              return DropdownMenuItem<int>(
                                value: i + 1,
                                child: Text(FormatHelper.formatBulan(i + 1)),
                              );
                            }),
                            onChanged: (value) => setState(() => _selectedMonth = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tahun text field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Tahun',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        TextFormField(
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.textDark),
                          decoration: InputDecoration(
                            hintText: 'Contoh: 2024',
                            hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.7)),
                            prefixIcon: const Icon(Icons.event, color: AppColors.primaryBlue),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) {
                            final year = int.tryParse(value);
                            if (year != null) {
                              setState(() => _selectedYear = year);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // No. Meter field
                    _buildTextField(
                      controller: _measurementController,
                      labelText: 'No. Meter',
                      hintText: 'Masukkan nomor meter',
                      prefixIcon: Icons.speed,
                    ),
                    const SizedBox(height: 16),

                    // Nilai Pemakaian field
                    _buildTextField(
                      controller: _usageController,
                      labelText: 'Nilai Pemakaian (m³)',
                      hintText: 'Contoh: 50',
                      prefixIcon: Icons.water_drop,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      text: 'Simpan',
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            labelText,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.7)),
            prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}