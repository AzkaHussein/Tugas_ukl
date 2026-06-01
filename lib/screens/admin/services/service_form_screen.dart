import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/service_model.dart';
import '../../../widgets/custom_button.dart';

class ServiceFormScreen extends StatefulWidget {
  final bool isEdit;
  final ServiceModel? service;

  const ServiceFormScreen({super.key, required this.isEdit, this.service});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minUsageController = TextEditingController();
  final _maxUsageController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.service != null) {
      _nameController.text = widget.service!.name;
      _minUsageController.text = widget.service!.minUsage.toString();
      _maxUsageController.text = widget.service!.maxUsage.toString();
      _priceController.text = widget.service!.price.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _minUsageController.dispose();
    _maxUsageController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_nameController.text.trim().isEmpty ||
        _minUsageController.text.trim().isEmpty ||
        _maxUsageController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response;
      if (widget.isEdit) {
        response = await ApiService.updateService(
          widget.service!.id,
          _nameController.text.trim(),
          _minUsageController.text.trim(),
          _maxUsageController.text.trim(),
          _priceController.text.trim(),
        );
      } else {
        response = await ApiService.createService(
          _nameController.text.trim(),
          _minUsageController.text.trim(),
          _maxUsageController.text.trim(),
          _priceController.text.trim(),
        );
      }

      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? 'Layanan berhasil diupdate' : 'Layanan berhasil ditambahkan')),
        );
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan layanan')),
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
          widget.isEdit ? 'Edit Layanan' : 'Tambah Layanan',
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
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Nama Layanan',
                      hintText: 'Masukkan nama layanan',
                      prefixIcon: Icons.water_drop,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _minUsageController,
                      labelText: 'Min Pemakaian (m³)',
                      hintText: 'Contoh: 0',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _maxUsageController,
                      labelText: 'Max Pemakaian (m³)',
                      hintText: 'Contoh: 100',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _priceController,
                      labelText: 'Harga (Rp)',
                      hintText: 'Contoh: 5000',
                      prefixIcon: Icons.attach_money,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
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