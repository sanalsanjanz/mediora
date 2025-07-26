import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/order_api_handler.dart';
import 'package:mediora/models/pharmacy_model.dart';
import 'package:mediora/models/prescription_details_model.dart';
import 'package:mediora/patients/views/patient_landing_screen.dart';
import 'package:mediora/widgets/new_loading_screen.dart';

class BookMedicineScreen extends StatefulWidget {
  final PharmacyModel items;
  final PrescriptionDetailsModel prescription;

  const BookMedicineScreen({
    super.key,
    required this.items,
    required this.prescription,
  });

  @override
  State<BookMedicineScreen> createState() => _BookMedicineScreenState();
}

class _BookMedicineScreenState extends State<BookMedicineScreen> {
  late List<String> selectedMedicines;

  @override
  void initState() {
    super.initState();
    selectedMedicines = widget.prescription.prescriptions
        .expand((p) => p.medicines)
        .toList();
  }

  void _removeMedicine(int index) {
    setState(() {
      selectedMedicines.removeAt(index);
    });
  }

  Future<void> _placeOrder() async {
    if (selectedMedicines.isEmpty) return;

    // Show loading indicator
    MedicalLoadingOverlay.show(context);
    try {
      // Prepare order data
      final orderData = {
        'prescription_id': widget.prescription.prescriptions.first.id,
        'doctor_id': widget.prescription.prescriptions.first.doctorId,
        'patient_id': widget.prescription.prescriptions.first.patientId,
        'pharmacy_id': widget.items.id,
        'medicines': selectedMedicines,
        'order_date': DateTime.now().toIso8601String(),
        "status": "Pending",
      };

      var result = await OrderService.addOrder(orderData);
      if (result != null && result["success"]) {
        MedicalLoadingOverlay.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Order placed successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PatientLandingScreen()),
          (predicate) => false,
        );
      } else {
        MedicalLoadingOverlay.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Text('Failed to place order'),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      MedicalLoadingOverlay.hide();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Text('Failed to place order: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Book Medicines',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
        surfaceTintColor: Colors.transparent,
        actions: [
          if (selectedMedicines.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${selectedMedicines.length} selected',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pharmacy Info Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(
                                  widget.items.image,
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.items.pharmacyName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Pharmacist: ${widget.items.pharmacistName}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: Colors.blue[600],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Medicine List Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.medical_services,
                          color: Colors.green[600],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Medicines to Order',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${selectedMedicines.length} items',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Medicine List
                  selectedMedicines.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No medicines selected",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: selectedMedicines.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final medicine = entry.value;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.06),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue[400]!,
                                        Colors.blue[600]!,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  medicine,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () => _removeMedicine(index),
                                  icon: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.red[600],
                                      size: 18,
                                    ),
                                  ),
                                  tooltip: 'Remove medicine',
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Order Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedMedicines.isEmpty ? null : _placeOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedMedicines.isEmpty
                        ? Colors.grey[300]
                        : Colors.blue[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_pharmacy,
                        size: 20,
                        color: selectedMedicines.isEmpty
                            ? Colors.grey[500]
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Place Order',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selectedMedicines.isEmpty
                              ? Colors.grey[500]
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
