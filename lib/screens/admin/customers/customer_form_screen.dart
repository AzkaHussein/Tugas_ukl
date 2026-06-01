import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/customer_model.dart';
import '../../../models/service_model.dart';
import '../../../widgets/custom_button.dart';

class CustomerFormScreen extends StatefulWidget {
  final bool isEdit;
  final CustomerModel? customer;

  const CustomerFormScreen({super.key, required this.isEdit, this.customer});

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  List<ServiceModel> _services = [];
  int? _selectedServiceId;

  @override
  void initState() {
    super.initState();
    _loadServices();
    if (!mounted) return;
    if (widget.isEdit && widget.customer != null) {
      _customerNumberController.text = widget.customer!.customerNumber;
      _nameController.text = widget.customer!.name;
      _phoneController.text = widget.customer!.phone;
      _addressController.text = widget.customer!.address;
      _selectedServiceId = widget.customer!.serviceId;
    }
  }

  Future<void> _loadServices() async {
    try {
      final response = await ApiService.getServices();
      if (!mounted) return;
      final data = response['data'] as List? ?? [];
      setState(() {
        _services = data.map((s) => ServiceModel.fromJson(s)).toList();
        if (widget.isEdit && widget.customer != null) {
          _selectedServiceId = widget.customer!.serviceId;
        } else if (_services.isNotEmpty) {
          _selectedServiceId = _services[0].id;
        }
      });
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _customerNumberController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_customerNumberController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (!widget.isEdit) {
      if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username dan password wajib diisi untuk customer baru')),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> response;
      if (widget.isEdit) {
        response = await ApiService.updateCustomer(
          widget.customer!.id,
          customerNumber: _customerNumberController.text,
          address: _addressController.text,
          serviceId: _selectedServiceId!,
          name: _nameController.text,
          phone: _phoneController.text,
        );
      } else {
        response = await ApiService.createCustomer(
          username: _usernameController.text,
          password: _passwordController.text,
          customerNumber: _customerNumberController.text,
          address: _addressController.text,
          serviceId: _selectedServiceId!,
          name: _nameController.text,
          phone: _phoneController.text,
        );
      }

      if (response['success'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.isEdit ? 'Customer berhasil diupdate' : 'Customer berhasil ditambahkan')),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Gagal menyimpan customer')),
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
          widget.isEdit ? 'Edit Customer' : 'Tambah Customer',
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
                    if (!widget.isEdit) ...[
                      _buildTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        hintText: 'Masukkan username',
                        prefixIcon: Icons.account_circle,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Masukkan password',
                        prefixIcon: Icons.lock,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppColors.primaryBlue,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _buildTextField(
                      controller: _customerNumberController,
                      labelText: 'No. Pelanggan',
                      hintText: 'Masukkan nomor pelanggan',
                      prefixIcon: Icons.numbers,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _nameController,
                      labelText: 'Nama Lengkap',
                      hintText: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'No. Telepon',
                      hintText: 'Masukkan nomor telepon',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      labelText: 'Alamat',
                      hintText: 'Masukkan alamat',
                      prefixIcon: Icons.home,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 8),
                          child: Text(
                            'Layanan',
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
                            value: _selectedServiceId,
                            hint: const Text('Pilih layanan', style: TextStyle(color: AppColors.textGrey)),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.water_drop, color: AppColors.primaryBlue),
                            ),
                            items: _services.map((s) {
                              return DropdownMenuItem<int>(
                                value: s.id,
                                child: Text(s.name),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedServiceId = value),
                          ),
                        ),
                      ],
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
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: AppColors.textGrey.withValues(alpha: 0.7)),
            prefixIcon: Icon(prefixIcon, color: AppColors.primaryBlue),
            suffixIcon: suffixIcon,
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