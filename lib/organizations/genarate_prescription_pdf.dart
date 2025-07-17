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
}) async {
  try {
    final pdf = pw.Document();

    // Get signature image if available
    pw.Widget? signatureWidget;
    if (base64Signature != null && base64Signature.isNotEmpty) {
      try {
        final signatureBytes = base64Decode(base64Signature);
        final signatureImage = pw.MemoryImage(signatureBytes);
        signatureWidget = pw.Image(signatureImage, height: 40, width: 100);
      } catch (e) {
        print('Error loading signature: $e');
      }
    }

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(0),
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

              // Main content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header with doctor info and stethoscope icon area
                  pw.Container(
                    width: double.infinity,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [
                          PdfColor.fromHex('#4ECDC4'), // Teal color
                          PdfColor.fromHex('#7ED8D1'),
                        ],
                        begin: pw.Alignment.centerLeft,
                        end: pw.Alignment.centerRight,
                      ),
                      borderRadius: pw.BorderRadius.only(
                        bottomLeft: pw.Radius.circular(20),
                        bottomRight: pw.Radius.circular(20),
                      ),
                    ),
                    child: pw.Stack(
                      children: [
                        // Doctor info
                        pw.Positioned(
                          left: 20,
                          top: 20,
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                '${booking.doctor.name}',
                                style: pw.TextStyle(
                                  fontSize: 24,
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white,
                                ),
                              ),
                              pw.SizedBox(height: 4),
                              pw.Text(
                                booking.doctor.qualifications.join(", "),
                                style: pw.TextStyle(
                                  fontSize: 14,
                                  color: PdfColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Stethoscope icon placeholder (circular background)
                        pw.Positioned(
                          right: 20,
                          top: 20,
                          child: pw.Container(
                            width: 60,
                            height: 60,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                '🩺',
                                style: pw.TextStyle(
                                  fontSize: 30,
                                  color: PdfColors.grey,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Patient information form
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Column(
                      children: [
                        // Patient Name
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 2,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Patient Name:',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Container(
                                    width: double.infinity,
                                    padding: const pw.EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                          color: PdfColors.grey400,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: pw.Text(
                                      booking.patientName,
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 40),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Date:',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Container(
                                    width: double.infinity,
                                    padding: const pw.EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                          color: PdfColors.grey400,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: pw.Text(
                                      DateFormat(
                                        "dd-MM-yyyy",
                                      ).format(DateTime.now()),
                                      style: pw.TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        pw.SizedBox(height: 20),

                        // Age and Gender
                        pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 1,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Age:',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Container(
                                    width: double.infinity,
                                    padding: const pw.EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                          color: PdfColors.grey400,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: pw.Text(
                                      booking.patientAge.toString(),
                                      style: pw.TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.SizedBox(width: 40),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text(
                                    'Gender:',
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      color: PdfColors.grey600,
                                    ),
                                  ),
                                  pw.SizedBox(height: 2),
                                  pw.Container(
                                    width: double.infinity,
                                    padding: const pw.EdgeInsets.only(
                                      bottom: 5,
                                    ),
                                    decoration: pw.BoxDecoration(
                                      border: pw.Border(
                                        bottom: pw.BorderSide(
                                          color: PdfColors.grey400,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: pw.Text(
                                      booking.patientGender,
                                      style: pw.TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Container(),
                            ), // Empty space
                          ],
                        ),

                        pw.SizedBox(height: 20),

                        // Diagnosis section
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'Diagnosis:',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                            pw.SizedBox(height: 2),
                            pw.Container(
                              width: double.infinity,
                              padding: const pw.EdgeInsets.only(bottom: 5),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey400,
                                    width: 1,
                                  ),
                                ),
                              ),
                              child: pw.Text(
                                notesController.isNotEmpty
                                    ? notesController
                                    : '',
                                style: pw.TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 40),

                  // Rx Symbol
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Text(
                      'Rx',
                      style: pw.TextStyle(
                        fontSize: 48,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#2E5984'),
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Medicines prescription area
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          if (selectedMedicines.isNotEmpty)
                            ...selectedMedicines
                                .map(
                                  (medicine) => pw.Container(
                                    margin: const pw.EdgeInsets.only(
                                      bottom: 15,
                                    ),
                                    child: pw.Text(
                                      medicine,
                                      style: pw.TextStyle(
                                        fontSize: 14,
                                        fontWeight: pw.FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          // Add empty lines for manual writing
                          ...List.generate(
                            6,
                            (index) => pw.Container(
                              margin: const pw.EdgeInsets.only(bottom: 15),
                              decoration: pw.BoxDecoration(
                                border: pw.Border(
                                  bottom: pw.BorderSide(
                                    color: PdfColors.grey300,
                                    width: 1,
                                  ),
                                ),
                              ),
                              height: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 40),

                  // Signature area
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 20),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.center,
                          children: [
                            pw.Container(
                              width: 150,
                              height: 60,
                              child: signatureWidget != null
                                  ? pw.Center(child: signatureWidget)
                                  : pw.Container(),
                            ),
                            pw.Container(
                              width: 150,
                              height: 1,
                              color: PdfColors.grey400,
                            ),
                            pw.SizedBox(height: 5),
                            pw.Text(
                              'Signature',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 20),

                  // Footer with clinic info
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    decoration: pw.BoxDecoration(
                      border: pw.Border(
                        top: pw.BorderSide(color: PdfColors.grey300, width: 1),
                      ),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        // Clinic name (only if not empty)
                        pw.Expanded(
                          child: booking.doctor.locationName.isNotEmpty
                              ? pw.Text(
                                  booking.doctor.locationName.toUpperCase(),
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.grey700,
                                  ),
                                )
                              : pw.Container(),
                        ),
                        // Contact info
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            /*   pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                // pw.Text(
                                //   '📍 ${booking.doctor.locationName}',
                                //   style: pw.TextStyle(
                                //     fontSize: 10,
                                //     color: PdfColors.grey600,
                                //   ),
                                // ),
                              ],
                            ),
                            pw.SizedBox(height: 2), */
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Text(
                                  '☎ ${booking.doctor.contactNumber}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 2),
                            pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Text(
                                  '✉ ${booking.doctor.email}',
                                  style: pw.TextStyle(
                                    fontSize: 10,
                                    color: PdfColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
