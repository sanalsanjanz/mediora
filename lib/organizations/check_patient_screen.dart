import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mediora/apis/patients/organization/organization_api_links.dart';
import 'package:mediora/apis/patients/prescreption_api.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/organizations/doctors_landing_screen.dart';
import 'package:mediora/organizations/genarate_prescription_pdf.dart';
import 'package:signature/signature.dart';

import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class CheckUpPatientScreen extends StatefulWidget {
  final BookingDetailsModel booking;

  const CheckUpPatientScreen({super.key, required this.booking});

  @override
  State<CheckUpPatientScreen> createState() => _CheckUpPatientScreenState();
}

class _CheckUpPatientScreenState extends State<CheckUpPatientScreen> {
  final TextEditingController _medicineController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _medicineFocusNode = FocusNode();

  final List<String> _selectedMedicines = [];
  List<String> _suggestions = [];

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: const Color(0xFF1565C0), // Royal blue
    exportBackgroundColor: Colors.white,
  );

  String? _base64Signature;
  bool showExamineView = true;
  bool _isGeneratingPdf = false;

  // Royal blue color palette
  static const Color primaryRoyalBlue = Color(0xFF1565C0);
  static const Color lightRoyalBlue = Color(0xFF1976D2);
  static const Color darkRoyalBlue = Color(0xFF0D47A1);
  static const Color accentBlue = Color(0xFF42A5F5);

  Future<List<String>> fetchMedicineSuggestions(String query) async {
    final url = Uri.parse('$baseUrl/medicine/suggest?q=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List medicines = data['medicines'];
      return medicines.map((item) => item['name'] as String).toList();
    }
    return [];
  }

  void _onMedicineChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    final results = await fetchMedicineSuggestions(query);
    setState(() {
      _suggestions = results
          .where((item) => !_selectedMedicines.contains(item))
          .toList();
    });
  }

  void _addMedicine(String medicine) {
    if (!_selectedMedicines.contains(medicine)) {
      setState(() {
        _selectedMedicines.add(medicine);
        _suggestions = [];
        _medicineController.clear();
      });
    }
  }

  void _completeExamination() async {
    final Uint8List? signatureBytes = await _signatureController.toPngBytes();
    _base64Signature = signatureBytes != null
        ? base64Encode(signatureBytes)
        : null;

    print("✅ Examination Completed");
    print("Medicines: $_selectedMedicines");
    print("Notes: ${_notesController.text}");
    print(
      "Signature (base64): ${_base64Signature != null ? 'Captured' : 'Not captured'}",
    );

    final result = await PrescriptionAPI.addPrescription({
      'doctor_id': widget.booking.doctorId,
      'patient_id': widget.booking.patientId,
      'booking_id': widget.booking.id,
      'medicines': _selectedMedicines,
      'notes': _notesController.text,
      'diagnosis': widget.booking.reason,
      'signature_base64': _base64Signature ?? "",
    });

    if (result['success']) {
      await generatePrescriptionPdf(
        // ignore: use_build_context_synchronously
        context: context,
        booking: widget.booking,
        selectedMedicines: _selectedMedicines,
        notesController: _notesController.text,
        base64Signature: _base64Signature,
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => DoctorsLandingScreen()),
        (S) => false,
      );
    } else {
      print('Error: ${result['error']}');
    }

    // Generate PDF
  }

  @override
  void dispose() {
    _medicineController.dispose();
    _notesController.dispose();
    _signatureController.dispose();
    _medicineFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!showExamineView) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryRoyalBlue, lightRoyalBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.white),
                SizedBox(height: 20),
                Text(
                  "Examination Complete!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Prescription PDF has been generated",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Patient Check-up',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryRoyalBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPatientHeader(),
            const SizedBox(height: 20),
            _buildPrescriptionInput(),
            const SizedBox(height: 20),
            _buildNotesInput(),
            const SizedBox(height: 20),
            _buildSignaturePad(),
            const SizedBox(height: 20),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryRoyalBlue, lightRoyalBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryRoyalBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.medical_services,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Examination',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.booking.patientName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${widget.booking.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      /* decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryRoyalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.medication,
                  color: primaryRoyalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Add Medicines",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryRoyalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _medicineController,
            focusNode: _medicineFocusNode,
            onChanged: _onMedicineChanged,
            decoration: InputDecoration(
              hintText: 'Type medicine name...',
              suffixIcon: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: primaryRoyalBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    if (_medicineController.text.trim().isNotEmpty) {
                      _addMedicine(_medicineController.text.trim());
                    }
                  },
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryRoyalBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_suggestions.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: _suggestions.map((suggestion) {
                return InputChip(
                  label: Text(suggestion),
                  onPressed: () => _addMedicine(suggestion),
                  avatar: const Icon(Icons.add_circle_outline, size: 18),
                  backgroundColor: accentBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(color: primaryRoyalBlue),
                );
              }).toList(),
            )
          else if (_medicineController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: InputChip(
                label: Text('Add "${_medicineController.text}"'),
                onPressed: () => _addMedicine(_medicineController.text.trim()),
                avatar: const Icon(Icons.add),
                backgroundColor: primaryRoyalBlue.withOpacity(0.1),
                labelStyle: const TextStyle(color: primaryRoyalBlue),
              ),
            ),
          const SizedBox(height: 16),
          if (_selectedMedicines.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedMedicines.map((medicine) {
                return Chip(
                  label: Text(medicine),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() => _selectedMedicines.remove(medicine));
                  },
                  backgroundColor: primaryRoyalBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(color: primaryRoyalBlue),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      /* decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryRoyalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.note_add,
                  color: primaryRoyalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Additional Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryRoyalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'Enter additional notes, observations, or instructions...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: primaryRoyalBlue, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignaturePad() {
    return Container(
      padding: const EdgeInsets.all(10),
      /* decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ), */
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryRoyalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.draw,
                  color: primaryRoyalBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Doctor Signature',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primaryRoyalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: primaryRoyalBlue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.grey[50]!,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text("Clear"),
                  onPressed: () => _signatureController.clear(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryRoyalBlue,
                    side: const BorderSide(color: primaryRoyalBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                  onPressed: () async {
                    final image = await _signatureController.toPngBytes();
                    if (image != null) {
                      _base64Signature = base64Encode(image);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Signature saved"),
                          backgroundColor: primaryRoyalBlue,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRoyalBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      /* decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ), */
      child: ElevatedButton(
        onPressed: _isGeneratingPdf ? null : _completeExamination,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRoyalBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isGeneratingPdf
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Generating PDF...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'Complete Examination & Generate PDF',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
