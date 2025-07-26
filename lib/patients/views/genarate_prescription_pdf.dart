import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:mediora/models/booking_details_model.dart';
import 'package:mediora/models/doctors_model.dart';
import 'package:mediora/models/patient_model.dart';
import 'package:mediora/models/prescription_details_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Professional font sizes following medical prescription standards
const double titleText = 18;
const double headerText = 16;
const double mediumText = 12;
const double smallText = 10;
const double xsmallText = 8;

Future<Uint8List> generatePrescriptionPdf(
  PrescriptionDetailsModel prescriptionModel,
  BookingDetailsModel booking,
  PatientModel doctorModel,
) async {
  final pdf = pw.Document();
  final materialIconsFont = pw.Font.ttf(
    await rootBundle.load('assets/MaterialIcons-Regular.ttf'),
  );

  final prescription = prescriptionModel.prescriptions.first;
  final doctorName = doctorModel.name;
  final clinicName = booking.doctor.clinicName.isNotEmpty
      ? booking.doctor.clinicName
      : "Medical Clinic";
  final qualifications = booking.doctor.qualifications.join(", ");
  final specialization = booking.doctor.specialization;

  final formattedDate = DateFormat('dd MMM yyyy').format(prescription.date);
  final formattedTime = DateFormat('hh:mm a').format(prescription.date);

  List<List<dynamic>> medicineData = prescription.medicines
      .asMap()
      .entries
      .map((entry) => [(entry.key + 1).toString(), entry.value])
      .toList();

  const int itemsPerPage = 9; // Reduced for better spacing
  int totalPages = (medicineData.length / itemsPerPage).ceil();

  for (int page = 0; page < totalPages; page++) {
    final medicinesOnPage = medicineData
        .skip(page * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(
          40,
        ), // Increased margin for professional look
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (page == 0)
                buildProfessionalHeader(
                  doctorName,
                  clinicName,
                  qualifications,
                  specialization,
                  formattedDate,
                  formattedTime,
                  booking.doctor,
                  materialIconsFont,
                ),
              pw.SizedBox(height: 25),
              if (page == 0) buildPatientInformation(prescription, booking),
              if (page == 0) pw.SizedBox(height: 10),
              buildPrescriptionTitle(materialIconsFont),
              pw.SizedBox(height: 10),
              buildProfessionalMedicineTable(medicinesOnPage, 15),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Text(
                    "${prescription.days} Days",
                    style: pw.TextStyle(
                      fontSize: smallText,
                      color: PdfColors.grey800,
                    ),
                  ),
                ],
              ),
              pw.Spacer(),
              if (page == totalPages - 1) ...[
                buildNotesSection(prescription),
                pw.SizedBox(height: 10),
                buildProfessionalFooter(
                  doctorName,
                  booking.doctor.contactNumber,
                  prescription.signatureBase64,
                ),
              ],
              /* if (page < totalPages - 1) ...[
                pw.SizedBox(height: 20),
                pw.Text(
                  "Continued on next page...",
                  style: pw.TextStyle(
                    fontSize: smallText,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ], */
            ],
          );
        },
      ),
    );
  }

  return pdf.save();
}

pw.Widget buildProfessionalHeader(
  String doctorName,
  String clinicName,
  String qualifications,
  String specialization,
  String date,
  String time,
  DoctorsModel doctorModel,
  pw.Font? materialIconsFont,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 20),
    decoration: pw.BoxDecoration(
      // border: pw.Border.all(color: PdfColors.grey400, width: 2),
      // borderRadius: pw.BorderRadius.circular(10),
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey400, width: 2),
      ),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Doctor's name and credentials
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    doctorName,
                    style: pw.TextStyle(
                      fontSize: titleText,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    qualifications,
                    style: pw.TextStyle(
                      fontSize: mediumText,
                      color: PdfColors.grey800,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    specialization,
                    style: pw.TextStyle(
                      fontSize: smallText,
                      color: PdfColors.grey700,
                      fontStyle: pw.FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  "Date: $date",
                  style: pw.TextStyle(
                    fontSize: smallText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Time: $time",
                  style: pw.TextStyle(
                    fontSize: smallText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 15),
        // Clinic information
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                clinicName,
                style: pw.TextStyle(
                  fontSize: headerText,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                children: [
                  pw.Text(
                    String.fromCharCode(0xe0cd), // phone icon
                    style: pw.TextStyle(
                      font: materialIconsFont,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    doctorModel.contactNumber,
                    style: pw.TextStyle(fontSize: smallText),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    String.fromCharCode(0xe0be), // email icon
                    style: pw.TextStyle(
                      font: materialIconsFont,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    doctorModel.email,
                    style: pw.TextStyle(fontSize: smallText),
                  ),
                ],
              ),

              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Text(
                    String.fromCharCode(0xe0c8), // location icon
                    style: pw.TextStyle(
                      font: materialIconsFont,
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    doctorModel.locationName,
                    style: pw.TextStyle(fontSize: smallText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget buildPatientInformation(
  Prescription prescription,
  BookingDetailsModel booking,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey50,
      border: pw.Border.all(color: PdfColors.grey300),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PATIENT INFORMATION',
          style: pw.TextStyle(
            fontSize: mediumText,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Expanded(
              flex: 2,
              child: pw.Text(
                'Name: ${booking.patient.name}',
                style: pw.TextStyle(
                  fontSize: mediumText,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Age: ${booking.patient.age}',
                style: pw.TextStyle(fontSize: smallText),
              ),
            ),
            pw.Expanded(
              child: pw.Text(
                'Gender: ${booking.patient.gender}',
                style: pw.TextStyle(fontSize: smallText),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Patient ID: ${booking.id}',
          style: pw.TextStyle(fontSize: smallText, color: PdfColors.grey600),
        ),
      ],
    ),
  );
}

pw.Widget buildPrescriptionTitle(pw.Font font) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: PdfColors.grey300, width: 2),
      ),
    ),
    child: pw.Row(
      children: [
        /* pw.Text(
          String.fromCharCode(0xe3c9), // email icon
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            color: PdfColors.grey600,
          ),
        ),
        pw.SizedBox(width: 15), */
        pw.Text(
          "PRESCRIPTION",
          style: pw.TextStyle(
            fontSize: headerText,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
            letterSpacing: 1.2,
          ),
        ),
      ],
    ),
  );
}

pw.Widget buildProfessionalMedicineTable(
  List<List<dynamic>> medicineData,
  int totalRows,
) {
  return pw.Container(
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 1.5),
      // borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Table(
      columnWidths: {0: pw.FixedColumnWidth(60), 1: pw.FlexColumnWidth(5)},
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      children: [
        // Header row
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey500),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Text(
                "S.No",
                style: pw.TextStyle(
                  fontSize: smallText,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              child: pw.Text(
                "Medicine Name & Instructions",
                style: pw.TextStyle(
                  fontSize: smallText,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.left,
              ),
            ),
          ],
        ),
        // Medicine rows
        ...medicineData.map(
          (medicine) => pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text(
                  medicine[0].toString(),
                  style: pw.TextStyle(
                    fontSize: smallText,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                child: pw.Text(
                  medicine[1].toString(),
                  style: pw.TextStyle(fontSize: smallText),
                  textAlign: pw.TextAlign.left,
                ),
              ),
            ],
          ),
        ),
        // Empty rows for consistent table height
        // if (medicineData.length < totalRows)
        //   ...List.generate(
        //     totalRows - medicineData.length,
        //     (index) => pw.TableRow(
        //       decoration: pw.BoxDecoration(
        //         color: (medicineData.length + index) % 2 == 0
        //             ? PdfColors.white
        //             : PdfColors.blue50,
        //       ),
        //       children: [
        //         pw.Container(
        //           padding: const pw.EdgeInsets.all(12),
        //           height: 25,
        //           child: pw.Text(""),
        //         ),
        //         pw.Container(
        //           padding: const pw.EdgeInsets.all(12),
        //           height: 25,
        //           child: pw.Text(""),
        //         ),
        //       ],
        //     ),
        //   ),
      ],
    ),
  );
}

pw.Widget buildNotesSection(Prescription prescription) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey100),
      borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Text(
          "DOCTOR'S NOTES & INSTRUCTIONS",
          style: pw.TextStyle(
            fontSize: mediumText,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.black,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          prescription.notes ??
              'No additional notes or special instructions provided.',
          style: pw.TextStyle(fontSize: smallText, color: PdfColors.grey800),
        ),
      ],
    ),
  );
}

pw.Widget buildProfessionalFooter(
  String doctorName,
  String contactNumber,
  String? signatureBase64,
) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(15),
    decoration: pw.BoxDecoration(
      // border: pw.Border.all(color: PdfColors.grey300),
      // borderRadius: pw.BorderRadius.circular(8),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "For any queries, please contact:",
              style: pw.TextStyle(
                fontSize: xsmallText,
                color: PdfColors.grey600,
              ),
            ),
            pw.Text(
              contactNumber,
              style: pw.TextStyle(
                fontSize: smallText,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            if (signatureBase64 != null && signatureBase64.isNotEmpty)
              pw.Container(
                height: 50,
                width: 120,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Image(
                  pw.MemoryImage(base64Decode(signatureBase64)),
                  fit: pw.BoxFit.contain,
                ),
              )
            else
              pw.Container(
                height: 50,
                width: 120,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Center(
                  child: pw.Text(
                    "Digital Signature",
                    style: pw.TextStyle(
                      fontSize: xsmallText,
                      color: PdfColors.grey500,
                    ),
                  ),
                ),
              ),
            pw.SizedBox(height: 5),
            pw.Container(
              padding: const pw.EdgeInsets.only(top: 5),
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey400)),
              ),
              child: pw.Text(
                " $doctorName",
                style: pw.TextStyle(
                  fontSize: smallText,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
