import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../../models/customer_model.dart';
import '../../../widgets/admin_bottom_navbar.dart';
import 'customer_form_screen.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  bool _isLoading = true;
  List<CustomerModel> _customers = [];
  String _searchQuery = '';
  int _totalCount = 0;
  int _activeCount = 0;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.getCustomers();
      final data = response['data'] as List? ?? [];
      setState(() {
        _customers = data.map((c) => CustomerModel.fromJson(c)).toList();
        _totalCount = response['count'] ?? _customers.length;
        _activeCount = _customers.length;
        _pendingCount = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _totalCount = _customers.length;
        _activeCount = _customers.length;
        _pendingCount = 0;
      });
    }
  }

  List<CustomerModel> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    return _customers.where((c) {
      final query = _searchQuery.toLowerCase();
      return c.name.toLowerCase().contains(query) ||
          c.customerNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _deleteCustomer(CustomerModel customer) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Customer'),
        content: Text('Apakah Anda yakin ingin menghapus customer ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (!mounted) return;
              try {
                await ApiService.deleteCustomer(customer.id);
                if (!mounted) return;
                _loadCustomers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Customer berhasil dihapus')),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 1),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // APPBAR
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 12,
              ),
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/water_drop.png',
                        width: 28,
                        height: 28,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'WATERCASH',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),

            // SECTION 1 - JUDUL + BUTTON
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Manage',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Text(
                          'Customers',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Akses admin ke register dan catatan pelanggan.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerFormScreen(isEdit: false),
                        ),
                      );
                      if (result == true) _loadCustomers();
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.person_add_outlined, color: Colors.white, size: 20),
                        Text(
                          'Add',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                        Text(
                          'Customer',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SECTION 2 - SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.search, color: AppColors.textGrey, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration.collapsed(
                          hintText: 'Search',
                        ),
                        style: const TextStyle(fontSize: 14),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // SECTION 3 - STATS CARDS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // CARD 1 - Total Customers
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Customers',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$_totalCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.people_alt_outlined,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CARD 2 - Active Connections
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Connections',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$_activeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.check_circle_outline,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // CARD 3 - Pending Installs
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Installs',
                              style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '$_pendingCount',
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.more_horiz,
                          color: AppColors.textGrey.withValues(alpha: 0.4),
                          size: 48,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SECTION 4 - LIST CUSTOMERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daftar Pelanggan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_filteredCustomers.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Belum ada customer'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredCustomers.length,
                      itemBuilder: (ctx, idx) {
                        final customer = _filteredCustomers[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: const Color(0xFFEEF4FF),
                                child: Text(
                                  customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textDark,
                                      ),
                                    ),
                                    Text(
                                      'No. ${customer.customerNumber}',
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      customer.address,
                                      style: TextStyle(
                                        color: AppColors.textGrey,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF4FF),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    child: Text(
                                      customer.service?.name ?? '-',
                                      style: const TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: AppColors.primaryBlue,
                                          size: 18,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => CustomerFormScreen(
                                                isEdit: true,
                                                customer: customer,
                                              ),
                                            ),
                                          );
                                          if (result == true) _loadCustomers();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: AppColors.error,
                                          size: 18,
                                        ),
                                        onPressed: () => _deleteCustomer(customer),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}