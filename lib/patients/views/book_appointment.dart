import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:mediora/apis/patients/booking_apis.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/helper/syntoms_model.dart';
import 'package:mediora/models/booking_model.dart';
import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/patients/views/patient_landing_screen.dart';
import 'package:mediora/widgets/new_loading_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, this.booking, required this.doctorsModel});

  final BookingModel? booking;
  final DoctorsModel doctorsModel;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _mobileCtrl;
  late final TextEditingController _symptomCtrl;
  late final TextEditingController _doctorIdCtrl;
  late final TextEditingController _clinicIdCtrl;
  DateTime? _preferredDate;
  String _gender = 'Male';
  String _status = 'pending';
  String message = "";
  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _nameCtrl = TextEditingController(
      text: b?.fullName ?? PatientController.patientModel?.name ?? "",
    );
    _ageCtrl = TextEditingController(
      text:
          b?.age.toString() ??
          PatientController.patientModel?.age.toString() ??
          "",
    );
    _mobileCtrl = TextEditingController(
      text: b?.mobile ?? PatientController.patientModel?.mobile ?? "",
    );
    _symptomCtrl = TextEditingController(text: b?.symptoms ?? '');
    _doctorIdCtrl = TextEditingController(
      text: b?.doctorId ?? widget.doctorsModel.id,
    );
    _clinicIdCtrl = TextEditingController(
      text: b?.clinicId ?? widget.doctorsModel.clinicId ?? "",
    );
    _preferredDate = b?.preferredDate;
    _gender = b?.gender ?? PatientController.patientModel?.gender ?? 'Male';
    _status = b?.status ?? 'pending';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _mobileCtrl.dispose();
    _symptomCtrl.dispose();
    _doctorIdCtrl.dispose();
    _clinicIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final initialDate = _preferredDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2E8B57),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF333333),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      log(DateFormat("EEEE").format(picked));
      String currentWeek = DateFormat("EEEE").format(picked);

      for (var e in widget.doctorsModel.workingHours) {
        if (e.day.toLowerCase() == currentWeek.toLowerCase()) {
          if (e.open != null) {
            message = "${e.day} : ${e.open!} - ${e.close!}";
            setState(() => _preferredDate = picked);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Selected date is a holiday. Please choose another date.',
                ),
              ),
            );
          }
        }
      }
    }
  }

  Future _save() async {
    if (!_formKey.currentState!.validate()) return;

    MedicalLoadingOverlay.show(context, title: "Requesting...");
    final booking = BookingModel(
      patientId: PatientController.patientModel?.id ?? "",
      id: widget.booking?.id,
      fullName: _nameCtrl.text.trim(),
      gender: _gender,
      age: int.parse(_ageCtrl.text.trim()),
      mobile: _mobileCtrl.text.trim(),
      symptoms: _symptomCtrl.text.trim(),
      preferredDate: _preferredDate!,
      doctorId: _doctorIdCtrl.text.trim().isEmpty
          ? null
          : _doctorIdCtrl.text.trim(),
      clinicId: _clinicIdCtrl.text.trim().isEmpty
          ? null
          : _clinicIdCtrl.text.trim(),
      status: "pending",
    );

    if (booking.id != null) {
      // MedicalLoadingOverlay.hide();
      ApiResult added = await BookingApi.updateBooking(booking);

      if (added.isOk) {
        MedicalLoadingOverlay.hide();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PatientLandingScreen()),
          (r) => false,
        );
      } else {
        MedicalLoadingOverlay.hide();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(added.message)));
      }
    } else {
      ApiResult added = await BookingApi.addBooking(booking);
      /*   Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => PatientLandingScreen()),
        (r) => false,
      ); */

      if (added.isOk) {
        MedicalLoadingOverlay.hide();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => PatientLandingScreen()),
          (r) => false,
        );
      } else {
        MedicalLoadingOverlay.hide();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(added.message)));
      }
    }
  }

  Widget _buildFormField({
    required Widget child,
    required String label,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: const Color(0xFF2E8B57)),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: child,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final maxWidth = isTablet ? 600.0 : double.infinity;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        title: Text(
          widget.booking == null ? 'Add Booking' : 'Edit Booking',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2E8B57), Color(0xFF3CB371)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.medical_services_outlined,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.booking == null
                              ? 'New Appointment'
                              : 'Update Appointment',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.booking == null
                              ? 'Fill in the patient details below to book your appointment'
                              : 'Modify the appointment details as needed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Form Fields
                  _buildFormField(
                    label: 'Patient Name',
                    icon: Icons.person_outline,
                    child: TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter your full name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                  ),

                  // Gender & Age Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Gender',
                          icon: Icons.wc_outlined,
                          child: DropdownButtonFormField<String>(
                            value: _gender,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Text('Female'),
                              ),
                              DropdownMenuItem(
                                value: 'Other',
                                child: Text('Other'),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _gender = v ?? 'Male'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Age',
                          icon: Icons.cake_outlined,
                          child: TextFormField(
                            controller: _ageCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter age',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Age is required';
                              }

                              final n = int.tryParse(v);
                              if (n == null || n <= 0) return 'Enter valid age';
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  _buildFormField(
                    label: 'Mobile Number',
                    icon: Icons.phone_outlined,
                    child: TextFormField(
                      controller: _mobileCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter mobile number',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      validator: (v) => v == null || v.trim().length < 10
                          ? 'Enter valid mobile number'
                          : null,
                    ),
                  ),

                  _buildFormField(
                    label: 'Preferred Date',
                    icon: Icons.calendar_month_outlined,
                    child: InkWell(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _preferredDate == null
                                  ? 'Select preferred date'
                                  : '${_preferredDate!.day}/${_preferredDate!.month}/${_preferredDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _preferredDate == null
                                    ? Colors.grey.shade600
                                    : const Color(0xFF333333),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: Color(0xFF2E8B57),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildFormField(
                    label: 'Symptoms / Reason',
                    icon: Icons.medical_information_outlined,
                    child: TypeAheadField<String>(
                      controller: _symptomCtrl,
                      suggestionsCallback: (pattern) async {
                        return commonSymptoms
                            .where(
                              (item) => item.toLowerCase().contains(
                                pattern.toLowerCase(),
                              ),
                            )
                            .toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          child: Text(suggestion),
                        );
                      },
                      onSelected: (suggestion) {
                        _symptomCtrl.text = suggestion;
                      },
                      decorationBuilder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      builder: (context, controller, focusNode) {
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: const InputDecoration(
                            hintText: 'Describe your symptoms',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                          maxLines: 3,
                        );
                      },
                    ),
                  ),

                  if (_preferredDate != null)
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  SizedBox(height: 10),

                  // Doctor & Clinic Row
                  /* Row(
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Doctor ID (Optional)',
                          icon: Icons.local_hospital_outlined,
                          child: TextFormField(
                            controller: _doctorIdCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter doctor ID',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFormField(
                          label: 'Clinic ID (Optional)',
                          icon: Icons.business_outlined,
                          child: TextFormField(
                            controller: _clinicIdCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter clinic ID',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ), */
                  /*  if (widget.booking != null)
                    _buildFormField(
                      label: 'Status',
                      icon: Icons.update_outlined,
                      child: DropdownButtonFormField<String>(
                        value: _status,
                        onChanged: (v) =>
                            setState(() => _status = v ?? 'pending'),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'pending',
                            child: Text('Pending'),
                          ),
                          DropdownMenuItem(
                            value: 'confirmed',
                            child: Text('Confirmed'),
                          ),
                          DropdownMenuItem(
                            value: 'completed',
                            child: Text('Completed'),
                          ),
                          DropdownMenuItem(
                            value: 'cancelled',
                            child: Text('Cancelled'),
                          ),
                        ],
                      ),
                    ), */
                  const SizedBox(height: 16),

                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _preferredDate != null
                            ? [Color(0xFF2E8B57), Color(0xFF3CB371)]
                            : [
                                Color.fromARGB(255, 78, 78, 78),
                                Color.fromARGB(255, 85, 88, 86),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2E8B57).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_doctorIdCtrl.text.trim().isEmpty &&
                            _clinicIdCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please provide Doctor ID or Clinic ID',
                              ),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }
                        if (_preferredDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Please select a preferred date',
                              ),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                          return;
                        }
                        _save();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.booking != null
                            ? "Update Appointment"
                            : 'Save Appointment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
