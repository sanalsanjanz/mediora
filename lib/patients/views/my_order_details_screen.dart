import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/order_api_handler.dart';
import 'package:mediora/models/order_history_model.dart';

class MyOrderDetailsScreen extends StatefulWidget {
  final OrderHistoryModel order;

  const MyOrderDetailsScreen({super.key, required this.order});

  @override
  State<MyOrderDetailsScreen> createState() => _MyOrderDetailsScreenState();
}

class _MyOrderDetailsScreenState extends State<MyOrderDetailsScreen> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Order Details',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2E7D87),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Delete Button in App Bar
          if (widget.order.status.toLowerCase() == "pending")
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _isDeleting ? null : _showDeleteConfirmationDialog,
                icon: _isDeleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                tooltip: 'Delete Order',
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            _buildStatusCard(),
            const SizedBox(height: 16),

            // Doctor Information Card
            _buildDoctorCard(),
            const SizedBox(height: 16),

            // Patient Information Card
            _buildPatientCard(),
            const SizedBox(height: 16),

            // Order Information Card
            _buildOrderInfoCard(),
            const SizedBox(height: 16),

            // Medicines Card
            _buildMedicinesCard(),
            const SizedBox(height: 24),

            // Delete Button at Bottom
            if (widget.order.status.toLowerCase() == "pending")
              _buildDeleteButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    IconData statusIcon;

    switch (widget.order.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.access_time;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 48, color: statusColor),
          const SizedBox(height: 12),
          Text(
            widget.order.status.toUpperCase(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
          if (widget.order.message != null &&
              widget.order.message.toString().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.order.message.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: statusColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDoctorCard() {
    return _buildInfoCard(
      title: 'Doctor Information',
      icon: Icons.local_hospital,
      iconColor: const Color(0xFF2E7D87),
      children: [
        _buildInfoRow(
          icon: Icons.person,
          label: 'Name',
          value: widget.order.doctor.name,
        ),
        _buildInfoRow(
          icon: Icons.medical_services,
          label: 'Specialization',
          value: widget.order.doctor.specialization,
        ),
        _buildInfoRow(
          icon: Icons.work,
          label: 'Experience',
          value: widget.order.doctor.experience,
        ),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'Contact',
          value: widget.order.doctor.contactNumber,
        ),
        _buildInfoRow(
          icon: Icons.location_on,
          label: 'Clinic',
          value: widget.order.doctor.clinicName,
        ),
      ],
    );
  }

  Widget _buildPatientCard() {
    return _buildInfoCard(
      title: 'Patient Information',
      icon: Icons.person_outline,
      iconColor: const Color(0xFF6B73FF),
      children: [
        _buildInfoRow(
          icon: Icons.account_circle,
          label: 'Name',
          value: widget.order.patient.name,
        ),
        _buildInfoRow(
          icon: Icons.cake,
          label: 'Age',
          value: '${widget.order.patient.age} years',
        ),
        _buildInfoRow(
          icon: Icons.wc,
          label: 'Gender',
          value: widget.order.patient.gender,
        ),
        _buildInfoRow(
          icon: Icons.phone,
          label: 'Mobile',
          value: widget.order.patient.mobile,
        ),
        _buildInfoRow(
          icon: Icons.place,
          label: 'Location',
          value: widget.order.patient.location,
        ),
      ],
    );
  }

  Widget _buildOrderInfoCard() {
    return _buildInfoCard(
      title: 'Order Information',
      icon: Icons.receipt_long,
      iconColor: const Color(0xFFFF6B6B),
      children: [
        _buildInfoRow(
          icon: Icons.tag,
          label: 'Order ID',
          value: widget.order.id,
        ),
        _buildInfoRow(
          icon: Icons.description,
          label: 'Prescription ID',
          value: widget.order.prescriptionId,
        ),
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'Order Date',
          value: _formatDate(widget.order.orderDate),
        ),
        _buildInfoRow(
          icon: Icons.local_pharmacy,
          label: 'Pharmacy ID',
          value: widget.order.pharmacyId,
        ),
      ],
    );
  }

  Widget _buildMedicinesCard() {
    return _buildInfoCard(
      title: 'Medicines (${widget.order.medicines.length})',
      icon: Icons.medication,
      iconColor: const Color(0xFF4ECDC4),
      children: [
        ...widget.order.medicines.asMap().entries.map((entry) {
          int index = entry.key;
          String medicine = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF4ECDC4).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF4ECDC4).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ECDC4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    medicine,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                ),
                const Icon(
                  Icons.medication,
                  color: Color(0xFF4ECDC4),
                  size: 20,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  Widget _buildDeleteButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _isDeleting ? null : _showDeleteConfirmationDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isDeleting) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Deleting...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ] else ...[
                  const Icon(
                    Icons.delete_forever,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Delete Order',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Warning Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(color: Colors.red.shade200, width: 2),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 40,
                    color: Colors.red.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Delete Order?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  'Are you sure you want to delete this order? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),

                // Order ID
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Order ID: ${widget.order.id}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.of(context).pop(),
                            child: Center(
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Delete Button
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.red.shade500, Colors.red.shade600],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.of(context).pop();
                              _deleteOrder();
                            },
                            child: const Center(
                              child: Text(
                                'Delete',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteOrder() async {
    setState(() {
      _isDeleting = true;
    });

    try {
      // Replace with your actual API endpoint
      var response = await OrderService.deleteOrder(widget.order.id);

      if (response) {
        // Success - show success message and navigate back
        if (mounted) {
          _showSuccessDialog();
        }
      } else {
        // Error - show error message
        if (mounted) {
          _showErrorDialog('Failed to delete order. Please try again.');
        }
      }
    } catch (error) {
      // Network error or other exception
      if (mounted) {
        _showErrorDialog(
          'Network error. Please check your connection and try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 40,
                    color: Colors.green.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order Deleted!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'The order has been successfully deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Close dialog
                      Navigator.of(
                        context,
                      ).pop(true); // Go back to previous screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade600, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: TextStyle(
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
