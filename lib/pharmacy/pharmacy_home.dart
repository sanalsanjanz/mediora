import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/pharmacies/order_api_handler.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/pharmacy/order_history_model.dart';
import 'package:mediora/models/pharmacy/pharmacy_model.dart';
import 'package:mediora/pharmacy/all_orders_screen.dart';
import 'package:mediora/pharmacy/update_order_history.dart';

import 'pharmacy_profile_screen.dart';

class PharmacyHome extends StatefulWidget {
  final PharmacyAuthModel pharmacy;

  const PharmacyHome({super.key, required this.pharmacy});

  @override
  State<PharmacyHome> createState() => _PharmacyHomeState();
}

class _PharmacyHomeState extends State<PharmacyHome> {
  List<OrderHistoryModel> _orders = [];
  bool _isLoading = true;

  int get pendingCount =>
      _orders.where((order) => order.status == 'Pending').length;

  int get completedCount =>
      _orders.where((order) => order.status == 'Completed').length;

  int get processingCount =>
      _orders.where((order) => order.status == 'Processing').length;

  List<OrderHistoryModel> get recentOrders => _orders.take(5).toList();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);

    try {
      final data = await OrderService.getOrders(
        pharmacyId: PatientController.pharmacyModel?.id ?? "",
      );

      if (mounted) {
        data.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        setState(() {
          _orders = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildOverviewSection(),
                    const SizedBox(height: 24),
                    _buildRecentOrdersSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: const Color(0xFF1E88E5),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Pharmacy Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(Icons.refresh, color: Colors.white),
        ),
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      PharmacyProfileScreen(pharmacy: widget.pharmacy),
                ),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E88E5), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E88E5).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(widget.pharmacy.image),
              radius: 35,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${widget.pharmacy.pharmacistName.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.pharmacy.pharmacyName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Color(0xFF718096),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.pharmacy.locationName,
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildStatusChip(
                      icon: Icons.work_outline,
                      label: '${widget.pharmacy.experience} years exp',
                      color: const Color(0xFF805AD5),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(
                      icon: widget.pharmacy.status
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                      label: widget.pharmacy.status ? 'Active' : 'Inactive',
                      color: widget.pharmacy.status
                          ? const Color(0xFF38A169)
                          : const Color(0xFFE53E3E),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(),
            ),
          )
        else
          _buildStatisticsCards(),
      ],
    );
  }

  Widget _buildStatisticsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pending',
                count: pendingCount.toString(),
                icon: Icons.schedule,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                ),
                onTap: () => _navigateToFilteredOrders('Pending'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Processing',
                count: processingCount.toString(),
                icon: Icons.hourglass_empty,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB946), Color(0xFFFF9500)],
                ),
                onTap: () => _navigateToFilteredOrders('Processing'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Completed',
                count: completedCount.toString(),
                icon: Icons.check_circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF51CF66), Color(0xFF40C057)],
                ),
                onTap: () => _navigateToFilteredOrders('Completed'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Total Orders',
                count: _orders.length.toString(),
                icon: Icons.receipt_long,
                gradient: const LinearGradient(
                  colors: [Color(0xFF339AF0), Color(0xFF1C7ED6)],
                ),
                onTap: () => _navigateToAllOrders(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            if (_orders.isNotEmpty)
              TextButton.icon(
                onPressed: _navigateToAllOrders,
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF1E88E5),
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildRecentOrdersList(),
      ],
    );
  }

  Widget _buildRecentOrdersList() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here when patients place them',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentOrders.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[200]),
        itemBuilder: (context, index) {
          final order = recentOrders[index];
          return _buildOrderTile(order);
        },
      ),
    );
  }

  Widget _buildOrderTile(OrderHistoryModel order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFFF6B6B);
        statusIcon = Icons.schedule;
        break;
      case 'processing':
        statusColor = const Color(0xFFFFB946);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'completed':
        statusColor = const Color(0xFF51CF66);
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = const Color(0xFF718096);
        statusIcon = Icons.help_outline;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF1E88E5).withOpacity(0.1),
        child: Text(
          order.patient.name[0].toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E88E5),
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        order.patient.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF2D3748),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                order.status,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate),
            style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF718096),
      ),
      onTap: () => _navigateToOrderDetails(order),
    );
  }

  void _navigateToOrderDetails(OrderHistoryModel order) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UpdateOrderStatusScreen(order: order)),
    );
  }

  void _navigateToAllOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AllOrdersScreen(pharmacy: widget.pharmacy),
      ),
    );
  }

  void _navigateToFilteredOrders(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AllOrdersScreen(pharmacy: widget.pharmacy, initialFilter: status),
      ),
    );
  }
}
