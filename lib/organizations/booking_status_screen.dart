// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/organizations/check_patient_screen.dart';
import 'package:mediora/organizations/doctors_landing_screen.dart';
import 'package:mediora/widgets/show_loading.dart';

class BookingStatusScreen extends StatefulWidget {
  final BookingDetailsModel booking;

  const BookingStatusScreen({Key? key, required this.booking})
    : super(key: key);

  @override
  State<BookingStatusScreen> createState() => _BookingStatusScreenState();
}

class _BookingStatusScreenState extends State<BookingStatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String currentStatus = '';
  bool showExamineView = false;
  bool isUpdating = false;

  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _rejectionReasonController =
      TextEditingController();

  final List<String> rejectionReasons = [
    'Patient not available',
    'Doctor emergency',
    'Clinic closed',
    'Rescheduling required',
    'Patient cancelled',
    'Technical issues',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    currentStatus = widget.booking.status;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _prescriptionController.dispose();
    _notesController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.amber.shade600;
      case 'confirmed':
        return Colors.green.shade600;
      case 'cancelled':
        return Colors.red.shade600;
      case 'completed':
        return Colors.blue.shade600;
      case 'rejected':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.task_alt;
      case 'rejected':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  List<String> _getAvailableStatuses() {
    List<String> statuses = [];

    switch (currentStatus.toLowerCase()) {
      case 'pending':
        statuses = ['confirmed', 'rejected', 'cancelled'];
        break;
      case 'confirmed':
        statuses = ['completed', 'cancelled'];
        break;
      case 'cancelled':
      case 'completed':
      case 'rejected':
        // No further status changes allowed
        break;
    }

    return statuses;
  }

  void _updateStatus(String newStatus) {
    if (newStatus == 'rejected') {
      _showRejectionDialog();
    } else if (newStatus == 'confirmed') {
      _showConfirmationDialog();
    } else if (newStatus == 'completed') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CheckUpPatientScreen(booking: widget.booking),
        ),
      );
      /*   setState(() {
        showExamineView = true;
      }); */
    } else {
      _performStatusUpdate(newStatus);
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please select a reason for rejection:'),
            const SizedBox(height: 16),
            ...rejectionReasons.map(
              (reason) => ListTile(
                title: Text(reason),
                onTap: () {
                  Navigator.pop(context);
                  _rejectionReasonController.text = reason;
                  if (reason == 'Other') {
                    _showCustomReasonDialog();
                  } else {
                    _performStatusUpdate('rejected', reason: reason);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCustomReasonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Custom Rejection Reason'),
        content: TextField(
          controller: _rejectionReasonController,
          decoration: const InputDecoration(
            hintText: 'Enter custom reason...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performStatusUpdate(
                'rejected',
                reason: _rejectionReasonController.text,
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Booking'),
        content: const Text('Are you sure you want to confirm this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performStatusUpdate('confirmed');
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _performStatusUpdate(String newStatus, {String? reason}) async {
    MedioraLoadingScreen.show(message: "Updating", context);
    (String, bool) res = await BookingApi.updateStatus(
      status: newStatus,
      id: widget.booking.id,
    );
    if (res.$2) {
      MedioraLoadingScreen.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${newStatus.toLowerCase()} successfully'),
          backgroundColor: _getStatusColor(newStatus),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DoctorsLandingScreen()),
        (d) => false,
      );
    } else {
      MedioraLoadingScreen.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update'),
          backgroundColor: _getStatusColor(newStatus),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.of(context).pop();
    }
    // Simulate API call
    /* Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        currentStatus = newStatus;
        isUpdating = false;
      });

      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${newStatus.toLowerCase()} successfully'),
          backgroundColor: _getStatusColor(newStatus),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (newStatus == 'confirmed') {
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            showExamineView = true;
          });
        });
      }
    }); */
  }

  void _completeExamination() {
    if (_prescriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add prescription before completing'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _performStatusUpdate('completed');
    setState(() {
      showExamineView = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Booking Status'),
        backgroundColor: Colors.grey.shade50,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: /* showExamineView ? _buildExaminationView() : */
              _buildStatusView(),
        ),
      ),
    );
  }

  Widget _buildStatusView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 20),
          _buildPatientCard(),
          const SizedBox(height: 20),
          _buildBookingDetailsCard(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getStatusColor(currentStatus),
            _getStatusColor(currentStatus).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getStatusColor(currentStatus).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(_getStatusIcon(currentStatus), size: 40, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            currentStatus.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current Status',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  widget.booking.patientGender.toLowerCase() == 'male'
                      ? Icons.man
                      : Icons.woman,
                  color: Colors.blue.shade600,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.booking.patientName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.cake, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.booking.patientAge} years',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          widget.booking.patientGender.toLowerCase() == 'male'
                              ? Icons.male
                              : Icons.female,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.booking.patientGender,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.phone, color: Colors.grey.shade600, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.booking.patientContact,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.calendar_today,
            'Preferred Date',
            '${widget.booking.preferredDate.day}/${widget.booking.preferredDate.month}/${widget.booking.preferredDate.year}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.access_time,
            'Created',
            '${widget.booking.createdAt.day}/${widget.booking.createdAt.month}/${widget.booking.createdAt.year}',
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.medical_services,
            'Reason',
            widget.booking.reason,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.local_hospital,
            'Doctor',
            widget.booking.doctor.name,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final availableStatuses = _getAvailableStatuses();

    if (availableStatuses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              'No further actions available',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Booking Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...availableStatuses.map((status) {
          return status.toLowerCase() == "cancelled"
              ? SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isUpdating
                          ? null
                          : () => _updateStatus(status),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getStatusColor(status),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isUpdating
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_getStatusIcon(status), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  status.toLowerCase() == "completed"
                                      ? "Check Patient"
                                      : status.toLowerCase() == "rejected"
                                      ? "Reject Booking"
                                      : status.toLowerCase() == "confirmed"
                                      ? "Accept Booking"
                                      : status.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
        }),
      ],
    );
  }
}
