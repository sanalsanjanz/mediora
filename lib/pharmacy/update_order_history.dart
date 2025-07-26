import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/pharmacies/order_api_handler.dart';
import 'package:mediora/models/pharmacy/order_history_model.dart';

class UpdateOrderStatusScreen extends StatefulWidget {
  final OrderHistoryModel order;

  const UpdateOrderStatusScreen({super.key, required this.order});

  @override
  State<UpdateOrderStatusScreen> createState() =>
      _UpdateOrderStatusScreenState();
}

class _UpdateOrderStatusScreenState extends State<UpdateOrderStatusScreen>
    with TickerProviderStateMixin {
  String status = 'Pending';
  final TextEditingController messageCtrl = TextEditingController();
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Map<String, dynamic>> statusOptions = [
    {'value': 'Pending', 'color': Colors.orange, 'icon': Icons.schedule},
    {'value': 'Accepted', 'color': Colors.green, 'icon': Icons.check_circle},
    {'value': 'Rejected', 'color': Colors.red, 'icon': Icons.cancel},
  ];

  @override
  void initState() {
    super.initState();
    status = widget.order.status ?? 'Pending';
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> updateOrderStatus() async {
    if (status == 'Rejected' && messageCtrl.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter a reason for rejection');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final payload = {
        'id': widget.order.id,
        'prescription_id': widget.order.prescriptionId,
        'doctor_id': widget.order.doctorId,
        'patient_id': widget.order.patientId,
        'pharmacy_id': widget.order.pharmacyId,
        'medicines': widget.order.medicines,
        'order_date': DateTime.now().toIso8601String(),
        'status': status,
        'message': status == 'Rejected' ? messageCtrl.text.trim() : null,
      };

      // Replace with your actual API endpoint
      /*  final response = await http.post(
        Uri.parse('https://your-api-endpoint.com/orders/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN_HERE', // Add your auth token
        },
        body: jsonEncode(payload),
      ); */
      var response = await OrderService.updateOrder(payload);

      if (response != null && response["success"] == true) {
        _showSuccessDialog();
      } else {
        _showErrorSnackBar('Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Network error. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: Colors.green, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Order status updated successfully',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Close dialog
              Navigator.of(context).pop(true); // Return to previous screen
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Color _getStatusColor(String statusValue) {
    return statusOptions.firstWhere(
      (option) => option['value'] == statusValue,
    )['color'];
  }

  IconData _getStatusIcon(String statusValue) {
    return statusOptions.firstWhere(
      (option) => option['value'] == statusValue,
    )['icon'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Update Order Status',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        /*  bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: Colors.grey.shade200),
        ), */
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Row(
                      children: [
                        Icon(Icons.receipt_long, color: Colors.blue, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Order Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      'Order ID',
                      widget.order.prescriptionId ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Patient ID',
                      widget.order.patientId ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Current Status',
                      widget.order.status ?? 'Pending',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Status Selection Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                    Text(
                      'Update Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: statusOptions.map((option) {
                        final isSelected = status == option['value'];
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: ChoiceChip(
                            showCheckmark: false,
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  option['icon'],
                                  color: isSelected
                                      ? Colors.white
                                      : option['color'],
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  option['value'],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : option['color'],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            selectedColor: option['color'],
                            backgroundColor: (option['color'] as Color)
                                .withOpacity(0.1),
                            side: BorderSide(
                              color: isSelected
                                  ? option['color']
                                  : (option['color'] as Color).withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            onSelected: isLoading
                                ? null
                                : (selected) {
                                    if (selected) {
                                      setState(() {
                                        status = option['value'];
                                        if (status != 'Rejected') {
                                          messageCtrl.clear();
                                        }
                                      });
                                    }
                                  },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              // Rejection Reason Card (conditional)
              if (status == 'Rejected') ...[
                const SizedBox(height: 24),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Rejection Reason',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: messageCtrl,
                        maxLines: 4,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText:
                              'Please provide a detailed reason for rejection...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.red.shade500,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : updateOrderStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getStatusColor(status),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Updating...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(_getStatusIcon(status), color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              'Update to $status',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
