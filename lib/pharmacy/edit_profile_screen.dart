import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mediora/apis/patients/pharmacies/pharmacy_api.dart';
import 'package:mediora/models/pharmacy/pharmacy_model.dart';
import 'package:mediora/models/working_hours_model.dart';
import 'package:mediora/pharmacy/working_hours_picker.dart';
import 'package:mediora/widgets/location_picker.dart';

class AddUpdatePharmacyPage extends StatefulWidget {
  final PharmacyAuthModel? pharmacy;

  const AddUpdatePharmacyPage({super.key, this.pharmacy});

  @override
  State<AddUpdatePharmacyPage> createState() => _AddUpdatePharmacyPageState();
}

class _AddUpdatePharmacyPageState extends State<AddUpdatePharmacyPage> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  Uint8List? webImage;

  // Priority 1: Essential Information
  final TextEditingController pharmacyNameCtrl = TextEditingController();
  final TextEditingController pharmacistCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController licenseCtrl = TextEditingController();
  List<WorkingHourModel> workingHoursCtrl = [];
  // Priority 2: Operational Details
  final TextEditingController latCtrl = TextEditingController();
  final TextEditingController lonCtrl = TextEditingController();
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // Priority 3: Additional Information
  final TextEditingController experienceCtrl = TextEditingController();
  final TextEditingController aboutCtrl = TextEditingController();
  final TextEditingController servicesCtrl = TextEditingController();
  final TextEditingController paymentMethodsCtrl = TextEditingController();

  // New fields
  bool isActive = true;
  // String workingHours = '24x7';
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  void initState() {
    super.initState();
    if (widget.pharmacy != null) {
      final p = widget.pharmacy!;
      pharmacyNameCtrl.text = p.pharmacyName;
      pharmacistCtrl.text = p.pharmacistName;
      contactCtrl.text = p.contactNumber;
      emailCtrl.text = p.email;
      locationCtrl.text = p.locationName;
      licenseCtrl.text = p.licenseNumber;
      latCtrl.text = p.lat.toString();
      lonCtrl.text = p.lon.toString();
      usernameCtrl.text = p.username;
      passwordCtrl.text = p.password;
      experienceCtrl.text = p.experience.toString();
      aboutCtrl.text = p.about;
      servicesCtrl.text = p.services.join(', ');
      paymentMethodsCtrl.text = p.paymentMethods.join(', ');
      workingHoursCtrl = p.workingHours;
      isActive = p.status; // Uncomment when model is updated
    }
  }

  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            webImage = bytes;
            selectedImage = null;
          });
        } else {
          setState(() {
            selectedImage = File(pickedFile.path);
            webImage = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> pickLocationFromMap() async {
    LocationResult location = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => LocationPicker()));

    latCtrl.text = location.latitude.toString();
    lonCtrl.text = location.longitude.toString();
    locationCtrl.text = location.locationName.toString();

    // TODO: Implement map picker
    // For now, show a dialog to manually enter coordinates
    /* showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latCtrl,
              decoration: InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 10.5276',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 16),
            TextField(
              controller: lonCtrl,
              decoration: InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 76.2144',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Save'),
          ),
        ],
      ),
    ); */
  }

  /* Future<void> selectTime(bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          startTime = picked;
        } else {
          endTime = picked;
        }
        if (startTime != null && endTime != null) {
          workingHoursCtrl =
              '${startTime!.format(context)} - ${endTime!.format(context)}';
        }
      });
    }
  } */

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> fields = {
      if (widget.pharmacy != null) "id": widget.pharmacy?.id ?? 0,
      'pharmacy_name': pharmacyNameCtrl.text,
      'pharmacist_name': pharmacistCtrl.text,
      'contact_number': contactCtrl.text,
      'email': emailCtrl.text,
      'location_name': locationCtrl.text,
      'license_number': licenseCtrl.text,
      'lat': latCtrl.text,
      'lon': lonCtrl.text,
      'username': usernameCtrl.text,
      'password': passwordCtrl.text,
      'experience': experienceCtrl.text,
      'about': aboutCtrl.text,
      'working_hours': workingHoursCtrl,
      'services': servicesCtrl.text.split(",").map((e) => e.trim()).toList(),
      'payment_methods': paymentMethodsCtrl.text
          .split(",")
          .map((e) => e.trim())
          .toList(),
      'status': isActive,
    };

    try {
      final imageFile = kIsWeb ? null : selectedImage;

      if (widget.pharmacy == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await ApiService.updatePharmacy(fields, imageFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Pharmacy updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    Widget? suffixIcon,
    bool required = true,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        readOnly: readOnly,
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'This field is required'
                  : null
            : null,
      ),
    );
  }

  Widget buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildResponsiveLayout(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 1200) {
          // Large screens - 3 columns
          return GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: children,
          );
        } else if (constraints.maxWidth > 600) {
          // Tablets - 2 columns
          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 0,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: children,
          );
        } else {
          // Mobile - 1 column
          return Column(children: children);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.pharmacy != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(isUpdate ? 'Update Pharmacy' : 'Add Pharmacy'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Priority 1: Essential Information
                buildSectionHeader('Essential Information', Icons.info_outline),
                buildResponsiveLayout([
                  buildTextField(
                    'Pharmacy Name *',
                    pharmacyNameCtrl,
                    hintText: 'Enter pharmacy name',
                  ),
                  buildTextField(
                    'Pharmacist Name *',
                    pharmacistCtrl,
                    hintText: 'Enter pharmacist name',
                  ),
                  buildTextField(
                    'Contact Number *',
                    contactCtrl,
                    keyboardType: TextInputType.phone,
                    hintText: '+91 XXXXXXXXXX',
                  ),
                  buildTextField(
                    'Email *',
                    emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'pharmacy@example.com',
                  ),
                  buildTextField(
                    'License Number *',
                    licenseCtrl,
                    hintText: 'Enter license number',
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildTextField(
                          required: true,
                          readOnly: true,
                          'Location Address *',
                          locationCtrl,
                          hintText: 'Enter full address',
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          LocationResult location = await Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) => LocationPicker(),
                                ),
                              );

                          latCtrl.text = location.latitude.toString();
                          lonCtrl.text = location.latitude.toString();
                          locationCtrl.text = location.locationName.toString();
                        },
                        icon: Icon(Icons.location_history),
                      ),
                    ],
                  ),
                ]),

                // Status Toggle
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 0,
                    color: Colors.grey.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      title: Text('Pharmacy Status'),
                      subtitle: Text(isActive ? 'Active' : 'Inactive'),
                      value: isActive,
                      onChanged: (value) => setState(() => isActive = value),
                      activeColor: Colors.green,
                    ),
                  ),
                ),

                // Priority 2: Location & Working Details
                buildSectionHeader(
                  'Location & Working Hours',
                  Icons.location_on_outlined,
                ),

                // Coordinates with Map Button
                /* Row(
                  children: [
                    Expanded(
                      child: buildTextField(
                        'Latitude',
                        latCtrl,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        hintText: 'e.g., 10.5276',
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: buildTextField(
                        'Longitude',
                        lonCtrl,
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        hintText: 'e.g., 76.2144',
                      ),
                    ),
                  ],
                ), */
                /* Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: pickLocationFromMap,
                    icon: Icon(Icons.map),
                    label: Text('Pick from Map'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ), */

                // Working Hours Selection
                /*   Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Working Hours *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: workingHours == '24x7' ? '24x7' : 'custom',
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: '24x7',
                            child: Text('24×7 (Always Open)'),
                          ),
                          DropdownMenuItem(
                            value: 'custom',
                            child: Text('Custom Hours'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == '24x7') {
                              workingHours = '24x7';
                              startTime = null;
                              endTime = null;
                            } else {
                              workingHours = 'custom';
                            }
                          });
                        },
                      ),
                      if (workingHours == 'custom') ...[
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => selectTime(true),
                                icon: Icon(Icons.access_time),
                                label: Text(
                                  startTime?.format(context) ?? 'Start Time',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('to'),
                            ),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => selectTime(false),
                                icon: Icon(Icons.access_time),
                                label: Text(
                                  endTime?.format(context) ?? 'End Time',
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ), */
                WorkingHoursPicker(
                  onChanged: (live) {
                    workingHoursCtrl = live;
                    // log(DateFormat.EEEE().format(DateTime.now()));
                  },
                  /*  workingHoursCtrl = live, */
                  // instant updates if needed
                  onSaved: (finalJson) {
                    /*    workingHoursCtrl.text = finalJson; */
                    // repo.writeHours(finalJson); // persist as clean JSON
                  },
                  hours: workingHoursFromString(jsonEncode(workingHoursCtrl)),
                ),
                SizedBox(height: 20),
                buildResponsiveLayout([
                  buildTextField(
                    'Username *',
                    usernameCtrl,
                    hintText: 'Login username',
                  ),
                  buildTextField(
                    'Password *',
                    passwordCtrl,
                    hintText: 'Login password',
                  ),
                ]),

                // Priority 3: Additional Information
                buildSectionHeader(
                  'Additional Information',
                  Icons.notes_outlined,
                ),
                buildResponsiveLayout([
                  buildTextField(
                    'Experience (Years)',
                    experienceCtrl,
                    keyboardType: TextInputType.number,
                    hintText: 'Years of experience',
                    required: false,
                  ),
                ]),

                buildTextField(
                  'About Pharmacy',
                  aboutCtrl,
                  maxLines: 3,
                  hintText: 'Brief description about the pharmacy',
                  required: false,
                ),

                buildResponsiveLayout([
                  buildTextField(
                    'Services',
                    servicesCtrl,
                    hintText:
                        'Medicine delivery, Consultation, etc. (comma separated)',
                    required: false,
                  ),
                  buildTextField(
                    'Payment Methods',
                    paymentMethodsCtrl,
                    hintText: 'Cash, Card, UPI, etc. (comma separated)',
                    required: false,
                  ),
                ]),

                // Image Section
                buildSectionHeader('Pharmacy Image', Icons.image_outlined),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      if (selectedImage != null || webImage != null)
                        Container(
                          height: 200,
                          width: double.infinity,
                          margin: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: kIsWeb && webImage != null
                                  ? MemoryImage(webImage!)
                                  : FileImage(selectedImage!) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ElevatedButton.icon(
                          onPressed: pickImage,
                          icon: Icon(Icons.image),
                          label: Text(
                            selectedImage != null || webImage != null
                                ? 'Change Image'
                                : 'Pick Image',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      isUpdate ? 'Update Pharmacy' : 'Add Pharmacy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
