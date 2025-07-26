import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/apis/patients/order_api_handler.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/helper/colors.dart';
import 'package:mediora/models/order_history_model.dart';
import 'package:mediora/patients/views/my_order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _selectedStatus = 'all';
  final List<String> _statuses = ['all', 'pending', 'completed', 'cancelled'];

  Future<List<OrderHistoryModel>>? _ordersFuture;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = OrderService.getOrders(
        patientId: PatientController.patientModel!.id,
      );
    });
  }

  List<OrderHistoryModel> _filterOrders(List<OrderHistoryModel> orders) {
    if (_selectedStatus == 'all') return orders;
    return orders
        .where(
          (order) =>
              order.status.toLowerCase() == _selectedStatus.toLowerCase(),
        )
        .toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'My Orders',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          // Choice Chips Filter
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      showCheckmark: false,
                      label: Text(status.capitalize()),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedStatus = status);
                        }
                      },
                      backgroundColor: Colors.grey[100],
                      selectedColor: Colors.blue[100],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue[700] : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.blue[300]!
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadOrders(),
              child: FutureBuilder<List<OrderHistoryModel>>(
                future: _ordersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please try again later',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadOrders,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final orders = _filterOrders(snapshot.data ?? []);

                  if (orders.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No orders found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your order history will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(order);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderHistoryModel order) {
    return Card(
      color: colorPrimary.withAlpha(10),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to order details
          //
          var res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyOrderDetailsScreen(order: order),
            ),
          );
          if (res != null) {
            setState(() {});
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with order ID and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(order.status),
                          size: 14,
                          color: _getStatusColor(order.status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.status.capitalize(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              /* 

              // Doctor information
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue[50],
                    child: Text(
                      order.doctor.name[0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.doctor.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          order.doctor.specialization ?? 'General Physician',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12), */

              // Medicines count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.medication, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${order.medicines.length} Medicine${order.medicines.length != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Order date and action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          FontAwesome.stethoscope_solid,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          order.doctor.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 15,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(order.orderDate),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /* TextButton.icon(
                    onPressed: () {
                      // Navigate to order details
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ), */
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final inputDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(inputDate).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

extension StringCasing on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
