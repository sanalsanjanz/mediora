import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

double mediumText = 12;
double smallText = 10;
double xsmallText = 8;
Future<Uint8List> genaratePdf3(var locationDetails) async {
  final pdf = pw.Document();
  String warrentyDate = DateFormat("dd/MM/yyyy").format(
    DateTime(
      DateTime.now().year + 1,
      DateTime.now().month,
      DateTime.now().day - 1,
    ),
  );
  /* Uint8List? companyLogo = await loadImageAsUint8List(
    locationDetails != null && locationDetails.img.isNotEmpty
        ? locationDetails.imageUrl
        : "",
  ); */
  double calculateTaxPercentage({
    required double taxAmount,
    required double qty,
    required double rate,
    required double discount,
    required double subtotal,
  }) {
    double amountBeforeTax = (rate * qty) - discount;
    double taxPercentage = (taxAmount / amountBeforeTax) * 100;
    return taxPercentage;
  }

  // ignore: unused_element
  // double calculateBillTaxPercentage(double billAmount, double taxAmount) {
  //   if (billAmount <= 0) {
  //     throw ArgumentError("Bill amount must be greater than zero.");
  //   }
  //   return (taxAmount / billAmount) * 100;
  // }

  final notoFont = await loadFont('asset/font/NotoSans-Regular.ttf');
  // final hacenTunisia = await loadFont('asset/font/HacenTunisia.ttf');
  SharedPreferences sp = await SharedPreferences.getInstance();
  String company = sp.getString("company") ?? "";
  String salesPerson = sp.getString("emp_name") ?? "";
  final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  List<List<dynamic>> itemData = [];

  pw.Row keyValueRow(String key, String value, {PdfColor? textColor}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          key,
          style: pw.TextStyle(
            color: textColor,
            font: notoFont,
            fontSize: smallText,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Text(
          value,
          style: pw.TextStyle(
            color: textColor,
            font: notoFont,
            fontSize: smallText,
          ),
        ),
      ],
    );
  }

  pdf.addPage(
    pw.MultiPage(
      margin: pw.EdgeInsets.all(20),
      header: (pw.Context context) {
        return headerSection(
          /*     companyLogo, */
          formattedDate,
          company,
          salesPerson,
          locationDetails,
        );
      },
      footer: (pw.Context context) {
        return context.pageNumber != context.pagesCount
            ? pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 5),
                child: pw.Text(
                  '${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              )
            : pw.Container(
                alignment: pw.Alignment.center,
                margin: const pw.EdgeInsets.only(top: 5),
                child: pw.Text(
                  'This is a computer genarated invoice, no signature is required',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                ),
              );
      },
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return [
          pw.TableHelper.fromTextArray(
            columnWidths: {
              0: pw.FlexColumnWidth(1),
              1: pw.FlexColumnWidth(6),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(2),
              5: pw.FlexColumnWidth(2),
              6: pw.FlexColumnWidth(2),
              7: pw.FlexColumnWidth(1),
              8: pw.FlexColumnWidth(2),
              9: pw.FlexColumnWidth(2),
            },
            context: context,
            border: pw.TableBorder.all(color: PdfColors.grey300),
            headerStyle: pw.TextStyle(
              fontSize: xsmallText,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
            headerAlignment: pw.Alignment.center,
            cellStyle: pw.TextStyle(fontSize: xsmallText, font: notoFont),
            headerDecoration: pw.BoxDecoration(color: PdfColors.white),
            cellPadding: const pw.EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 3,
            ),
            headerPadding: const pw.EdgeInsets.symmetric(vertical: 5),
            headers: [
              '#',
              "Product",
              'Qty',
              "UOM",
              'Price',
              'Disc',
              'Sub Total',
              "VAT %",
              'Tax Amt',
              'Total',
            ],
            headerAlignments: {
              0: pw.Alignment.center,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
              6: pw.Alignment.center,
              7: pw.Alignment.center,
              8: pw.Alignment.center,
              9: pw.Alignment.center,
            },
            cellAlignments: {
              0: pw.Alignment.centerRight,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerLeft,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
              7: pw.Alignment.centerRight,
              8: pw.Alignment.centerRight,
              9: pw.Alignment.centerRight,
            },
            data: itemData,
          ),
          pw.SizedBox(height: 20),
          //Summary
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [],
          ),
          pw.SizedBox(height: 50),

          // Footer Section
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'For : ${company.toUpperCase()}',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                // font: notoFont,
                fontSize: mediumText,
              ),
            ),
          ),
          pw.SizedBox(height: 50),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Authorized Signatory',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: mediumText,
              ),
            ),
          ),
        ];
      },
    ),
  );

  return pdf.save();
}

pw.Widget headerSection(
  // companyLogo,
  formattedDate,
  company,
  salesPerson,
  locationDetails,
) {
  return pw.Column(
    children: [
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          pw.Row(
            children: [
              /*  if (companyLogo != null) */
              /*    buildImageWidget(companyLogo, locationDetails), */
              pw.Spacer(),
              pw.Center(
                child: pw.Text(
                  "TAX INVOICE",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 15),
      pw.SizedBox(
        height: 40,
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Invoice No",
                      style: pw.TextStyle(
                        fontSize: xsmallText,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      "billModel.invoiceNo,",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Invoice Date : ",
                      style: pw.TextStyle(
                        fontSize: xsmallText,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      formattedDate.toUpperCase(),
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  /*   mainAxisAlignment: pw.MainAxisAlignment.start, */
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Sales Person : ",
                      style: pw.TextStyle(
                        fontSize: xsmallText,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      salesPerson.toUpperCase(),
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(
        height: 40,
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Location : ",
                      style: pw.TextStyle(
                        fontSize: xsmallText,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text("", style: pw.TextStyle(fontSize: xsmallText)),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  /*   mainAxisAlignment: pw.MainAxisAlignment.start, */
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Warehouse : ",
                      style: pw.TextStyle(
                        fontSize: xsmallText,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      "branchWarehouse",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(
        height: 120,
        child: pw.Row(
          children: [
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        "Customer",
                        style: pw.TextStyle(
                          fontSize: xsmallText,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    pw.Text(
                      "shopData.shopName.toUpperCase()",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.Text(
                      "billModel.address",
                      /*  "${locationDetails.$3}\n${locationDetails.$2} ${locationDetails.$4}\n${locationDetails.$5}" */
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Mobile ",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                  ],
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey200, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  /*   mainAxisAlignment: pw.MainAxisAlignment.start, */
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Center(
                      child: pw.Text(
                        "Supllier",
                        style: pw.TextStyle(
                          fontSize: xsmallText,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Divider(color: PdfColors.grey200),
                    pw.Text(
                      company.toUpperCase(),
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    /*  pw.Text(
                      locationDetails != null ? locationDetails.place : "",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      locationDetails != null ? locationDetails.country : "",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      "Mobile  :  ${locationDetails?.mobile ?? ""}",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "Email    :  ${locationDetails?.email ?? ""}",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      "TRN     :  ${locationDetails?.regnNo ?? ""}",
                      style: pw.TextStyle(fontSize: xsmallText),
                    ), */
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Future<pw.Font> loadFont(String path) async {
  final fontData = await rootBundle.load(path);
  return pw.Font.ttf(fontData);
}

// double getProductTaxAmount(AddBillModel billModel, Item product) {
//   String taxType = billModel.bType[0].toUpperCase();

//   return switch (taxType) {
//     // Local tax calculation (SGST + CGST)
//     'L' => product.sgst + product.cgst,
//     // Unregistered tax calculation (IGST)
//     'U' => 0.0,
//     // Interstate tax calculation (IGST)
//     'I' => product.igst,
//     _ => throw ArgumentError('Invalid taxType: $taxType'),
//   };
// }

// String calculatePercentage(double amount, double totalAmount) {
//   if (totalAmount == 0) {
//     return "0";
//   }
//   return ((amount / totalAmount) * 100).round().toString();
// }

// String convertTo12Hour(String time24) {
//   if (time24.isNotEmpty) {
//     List<String> parts = time24.split(':');
//     int hour = int.parse(parts[0]);
//     String minute = parts[1];
//     String period = hour >= 12 ? 'PM' : 'AM';
//     hour = hour % 12;
//     hour = hour == 0 ? 12 : hour;
//     return '$hour:$minute $period';
//   } else {
//     return "";
//   }
// }
/* 
double getTaxAmount(AddBillModel billModel) {
  String taxType = billModel.bType[0].toUpperCase();
  double taxTotal = 0.0;
  switch (taxType) {
    case 'L':
      // Local tax calculation (SGST + CGST)
      taxTotal = billModel.sgst + billModel.cgst;
      break;
    case 'U':
      // Unregistered tax calculation (IGST)
      taxTotal = 0.0;
      break;
    case 'I':
      // Interstate tax calculation (IGST)
      taxTotal = billModel.igst;
      break;
    default:
      throw ArgumentError('Invalid taxType: $taxType');
  }

  return taxTotal;
} */

pw.Widget buildImageWidget(Uint8List? companyLogo, var company) {
  try {
    if (companyLogo != null && companyLogo.isNotEmpty) {
      // Check if the data can be used to create a valid MemoryImage
      final memoryImage = pw.MemoryImage(companyLogo);
      return pw.Image(memoryImage, height: 50, width: 50);
    } else {
      // Use a placeholder or skip rendering if the data is invalid
      return pw.Container(
        decoration: pw.BoxDecoration(
          shape: pw.BoxShape.circle,
          color: PdfColors.grey100,
        ),
        padding: pw.EdgeInsets.all(8),
        child: pw.Center(
          child: pw.Text(
            company.companyName.split("").first.toUpperCase(),
            style: pw.TextStyle(color: PdfColors.black),
          ),
        ),
      );
    }
  } catch (e) {
    // Handle the error gracefully and provide fallback
    return pw.Container(
      decoration: pw.BoxDecoration(
        shape: pw.BoxShape.circle,
        color: PdfColors.grey100,
      ),
      padding: pw.EdgeInsets.all(8),
      child: pw.Center(
        child: pw.Text(
          company.companyName.split("").first.toUpperCase(),
          style: pw.TextStyle(color: PdfColors.red),
        ),
      ),
    );
  }
}
