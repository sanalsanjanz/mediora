import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/pharmacies/order_api_handler.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/pharmacy/order_history_model.dart';
import 'package:mediora/models/pharmacy/pharmacy_model.dart';
import 'package:mediora/pharmacy/all_orders_screen.dart';
import 'package:mediora/pharmacy/update_order_history.dart';
import 'package:mediora/splash_screen.dart';

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
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF3B82F6),
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildWelcomeCard(),
                    const SizedBox(height: 24),
                    _buildOverviewSection(),
                    const SizedBox(height: 24),
                    _buildRecentOrdersSection(),
                    const SizedBox(height: 100), // Bottom padding
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
      expandedHeight: 100,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1F2937),
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh_rounded, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await PatientController.clearPreferences();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MedioraSplashScreen(),
                          ),
                          (_) => false,
                        );
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout, size: 18),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF1F5F9),
              foregroundColor: const Color(0xFF64748B),
            ),
          ),
        ),

        /*  Container(
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
              radius: 20,
              backgroundColor: const Color(0xFF3B82F6),
              backgroundImage: NetworkImage(widget.pharmacy.image),
            ),
          ),
        ), */
        SizedBox(width: 5),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF3B82F6), width: 2),
                ),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(widget.pharmacy.image),
                  radius: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${widget.pharmacy.pharmacistName.split(' ').first}!',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.pharmacy.pharmacyName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[500],
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.pharmacy.locationName,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatusChip(
                icon: Icons.work_outline_rounded,
                label: '${widget.pharmacy.experience}y exp',
                color: const Color(0xFF8B5CF6),
              ),
              const SizedBox(width: 8),
              _buildStatusChip(
                icon: widget.pharmacy.status
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                label: widget.pharmacy.status ? 'Active' : 'Inactive',
                color: widget.pharmacy.status
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
            ],
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
          'Orders Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading ? _buildShimmerStats() : _buildStatisticsCards(),
      ],
    );
  }

  Widget _buildShimmerStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
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
                icon: Icons.schedule_rounded,
                color: const Color(0xFFF59E0B),
                onTap: () => _navigateToFilteredOrders('Pending'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Processing',
                count: processingCount.toString(),
                icon: Icons.hourglass_empty_rounded,
                color: const Color(0xFF3B82F6),
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
                icon: Icons.check_circle_rounded,
                color: const Color(0xFF10B981),
                onTap: () => _navigateToFilteredOrders('Completed'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Total Orders',
                count: _orders.length.toString(),
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF8B5CF6),
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
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              count,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            if (_orders.isNotEmpty)
              TextButton.icon(
                onPressed: _navigateToAllOrders,
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF3B82F6),
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
      return _buildShimmerOrders();
    }

    if (_orders.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: Color(0xFF3B82F6),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Orders will appear here when patients place them',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recentOrders.length,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[100]),
        itemBuilder: (context, index) {
          final order = recentOrders[index];
          return _buildOrderTile(order);
        },
      ),
    );
  }

  Widget _buildShimmerOrders() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (context, index) =>
            Divider(height: 1, color: Colors.grey[100]),
        itemBuilder: (context, index) => _buildShimmerOrderTile(),
      ),
    );
  }

  Widget _buildShimmerOrderTile() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTile(OrderHistoryModel order) {
    Color statusColor;
    IconData statusIcon;

    switch (order.status.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        statusIcon = Icons.schedule_rounded;
        break;
      case 'processing':
        statusColor = const Color(0xFF3B82F6);
        statusIcon = Icons.hourglass_empty_rounded;
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        statusIcon = Icons.check_circle_rounded;
        break;
      default:
        statusColor = const Color(0xFF6B7280);
        statusIcon = Icons.help_outline_rounded;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
        child: Text(
          order.patient.name[0].toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6),
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        order.patient.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      order.status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            DateFormat('MMM dd, yyyy • hh:mm a').format(order.orderDate),
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Color(0xFF9CA3AF),
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
