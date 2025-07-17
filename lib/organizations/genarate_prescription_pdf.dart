import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> generatePrescriptionPdf({
  required BuildContext context,
  String? base64Signature,
  required BookingDetailsModel booking,
  required List<String> selectedMedicines,
  required String notesController,
  // String? doctorName,
  // String? doctorPhone,
  // String? doctorEmail,
  // String? clinicAddress,
  // String? qualifications,
  // String? registrationNumber,
}) async {
  try {
    final pdf = pw.Document();

    // Get signature image if available
    pw.Widget? signatureWidget;
    if (base64Signature != null && base64Signature.isNotEmpty) {
      try {
        final signatureBytes = base64Decode(base64Signature);
        final signatureImage = pw.MemoryImage(signatureBytes);
        signatureWidget = pw.Image(signatureImage, height: 50, width: 120);
      } catch (e) {
        print('Error loading signature: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Watermark - centered
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Transform.rotate(
                    angle: -0.3,
                    child: pw.Text(
                      'MEDIORA',
                      style: pw.TextStyle(
                        fontSize: 60,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey100,
                      ),
                    ),
                  ),
                ),
              ),

              // Main content with border
              pw.Container(
                width: double.infinity,
                height: double.infinity,
                // padding: const pw.EdgeInsets.all(5),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey500, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Doctor Header
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey400,
                          width: 0.5,
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            booking.doctor.name,
                            style: pw.TextStyle(
                              fontSize: 22,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            booking.doctor.qualifications.join(","),
                            style: pw.TextStyle(fontSize: 13),
                          ),
                          /*   if ( booking.doctor.l != null &&
                              registrationNumber.isNotEmpty) ...[
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Reg. No: $registrationNumber',
                              style: pw.TextStyle(fontSize: 11),
                            ), 
                          ], */
                          pw.SizedBox(height: 8),
                          pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.center,
                            children: [
                              pw.Text(
                                'Phone: ${booking.doctor.contactNumber}',
                                style: pw.TextStyle(fontSize: 11),
                              ),
                              pw.SizedBox(width: 10),
                              pw.Text(
                                'Email: ${booking.doctor.email}',
                                style: pw.TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            booking.doctor.locationName,
                            style: pw.TextStyle(fontSize: 11),
                            textAlign: pw.TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 15),

                    // Prescription Title
                    pw.Center(
                      child: pw.Text(
                        'PRESCRIPTION',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          decoration: pw.TextDecoration.underline,
                        ),
                      ),
                    ),

                    pw.SizedBox(height: 15),

                    // Patient and Booking Information
                    pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(
                          color: PdfColors.grey400,
                          width: 0.5,
                        ),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment:
                                      pw.CrossAxisAlignment.start,
                                  children: [
                                    pw.Text(
                                      'Patient Name: ${booking.patientName}',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text('Age: ${booking.patientAge}'),
                                    pw.SizedBox(height: 4),
                                    pw.Text('Gender: ${booking.patientGender}'),
                                  ],
                                ),
                              ),
                              pw.Expanded(
                                child: pw.Column(
                                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                                  children: [
                                    pw.Text(
                                      'Booking ID: ${booking.id.split("-")[0]}',
                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      'OP Date: ${DateFormat("dd-MM-yyyy").format(DateTime.now())}',
                                    ),
                                    pw.SizedBox(height: 4),
                                    pw.Text(
                                      'OP Time: ${DateFormat("hh:mm a").format(DateTime.now())}',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    pw.SizedBox(height: 20),

                    // Medicines Section
                    if (selectedMedicines.isNotEmpty) ...[
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 10),
                        child: pw.Text(
                          'Medicines',
                          style: pw.TextStyle(
                            fontSize: 14,
                            // fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.grey500,
                            width: 1,
                          ),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: selectedMedicines.asMap().entries.map((
                            entry,
                          ) {
                            int index = entry.key;
                            String medicine = entry.value;
                            return pw.Padding(
                              padding: const pw.EdgeInsets.only(bottom: 8),
                              child: pw.Row(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    '${index + 1}. ',
                                    style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                    ),
                                  ),
                                  pw.Expanded(
                                    child: pw.Text(
                                      medicine,

                                      style: pw.TextStyle(
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      pw.SizedBox(height: 20),
                    ],

                    // Additional Notes
                    if (notesController.isNotEmpty) ...[
                      pw.Padding(
                        padding: pw.EdgeInsets.symmetric(horizontal: 10),
                        child: pw.Text(
                          'Notes',
                          style: pw.TextStyle(
                            fontSize: 14,
                            // fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Container(
                        width: double.infinity,
                        padding: const pw.EdgeInsets.all(12),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(
                            color: PdfColors.green500,
                            width: 1,
                          ),
                        ),
                        child: pw.Text(notesController),
                      ),
                      pw.SizedBox(height: 20),
                    ],

                    // Signature Section
                    pw.Spacer(),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            if (signatureWidget != null) ...[
                              signatureWidget,
                              pw.SizedBox(height: 5),
                            ] else ...[
                              pw.SizedBox(height: 55),
                            ],
                            pw.Container(
                              width: 150,
                              height: 1,
                              color: PdfColors.black,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Doctor\'s Signature',
                              style: pw.TextStyle(fontSize: 12),
                            ),
                            pw.SizedBox(height: 3),
                            pw.Text(
                              'Date: ${DateTime.now().toString().split(' ')[0]}',
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),

                    pw.SizedBox(height: 10),

                    // Footer
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(
                          top: pw.BorderSide(color: PdfColors.black, width: 1),
                        ),
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'This is a digitally generated prescription. No physical signature required.',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey600,
                            fontStyle: pw.FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save PDF
    final output = await getApplicationDocumentsDirectory();
    final fileName =
        'prescription_${booking.patientName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open PDF
    await OpenFile.open(file.path);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Prescription PDF generated successfully!'),
        backgroundColor: Colors.black87,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error generating PDF: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
