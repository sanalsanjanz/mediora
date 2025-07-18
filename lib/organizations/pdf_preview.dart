// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/apis/patients/prescreption_api.dart';
import 'package:mediora/organizations/prescription_one.dart';
import 'package:printing/printing.dart';

class PdfPreviewPage extends StatefulWidget {
  final String bookingId;
  const PdfPreviewPage({super.key, required this.bookingId});

  @override
  State<PdfPreviewPage> createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool type1 = true;
  bool loading = false;
  var locationDetails;
  String routeName = "";
  (String, String) branchWarehouse = ("", "");
  String totalOutstanding = "0";
  @override
  void initState() {
    super.initState();
    getLocatinDetails();
  }

  getLocatinDetails() async {
    setState(() {
      loading = true;
    });
    locationDetails = await PrescriptionAPI.getPrescriptions(
      bookingId: widget.bookingId,
    );

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        /*  actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SizedBox(
              height: 25,
              child: ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [
                  type1,
                  !type1,
                ], // Track the selection of buttons
                selectedColor: Colors.white,
                disabledColor: const Color(0xffF6F6F6),
                fillColor: colorPrimary,
                color: Colors.black,
                selectedBorderColor: colorPrimary,
                borderColor: Colors.grey,
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Default',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Model 2',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
                onPressed: (int index) {
                  setState(() {
                    loading = true;
                  });
                  if (index == 0) {
                    setState(() {
                      // _sel1ectedMethod = ;
                      type1 = true;
                    });
/*                     context.read<SalesController>().billModel.account =
                        accountController.text; */
                    // context.read<SalesController>().billModel.bType = "LOCAL";
                    // bTypeController.text = "LOCAL";
                    // context
                    //     .read<SalesController>()
                    //     .updateBillItemsWithTaxType(taxType: "L");
                    // assignController(true);
                  } else {
                    setState(() {
                      type1 = false;
                    });
                    /*  context.read<SalesController>().billModel.account =
                      
                        accountController.text; */
                  }
                  setState(() {
                    loading = false;
                  });
                },
              ),
            ),
          ),
        ], */
        // foregroundColor: colorWhite,
        // backgroundColor: colorPrimary,
        /*  leading: IconButton(
          onPressed: () {
            // context.read<SalesController>().clearItems();
            navKey.currentState!.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ), */
        title: Text(
          "Prescription",
          style: const TextStyle(color: Colors.black),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : /*  type1
          ? */ PdfPreview(
              previewPageMargin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              loadingWidget: CircularProgressIndicator(),
              scrollViewDecoration: const BoxDecoration(color: Colors.white),
              pdfPreviewPageDecoration: const BoxDecoration(
                color: Colors.white,
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName:
                  "${"${widget.bookingId.replaceAll("/", "-").trim()} ${PatientController.doctorModel?.user.name.trim()}"}.pdf",
              actions: /* !shouldedit
            ? []
            :  */ [
                IconButton(
                  onPressed: () async {
                    /*   await context.read<SalesController>().clearItems();
                    navKey.currentState?.pop(); */
                    // onDeletePressed();
                  },
                  icon: const Icon(Icons.close),
                ),
                // IconButton(
                //   onPressed: () {
                //     // onEditPressed();
                //   },
                //   icon: const Icon(LineIcons.edit),
                // ),
              ],
              actionBarTheme: PdfActionBarTheme(
                elevation: 0,
                backgroundColor: Colors.grey.shade500,
                iconColor: Colors.black,
              ),
              build: (context) {
                return genaratePdf3(locationDetails);
              },
            ),
      /* : PdfPreview(
              previewPageMargin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              loadingWidget: const CircularProgressIndicator(),
              scrollViewDecoration: const BoxDecoration(color: Colors.white),
              pdfPreviewPageDecoration: const BoxDecoration(
                color: Colors.white,
              ),
              canChangeOrientation: false,
              canChangePageFormat: false,
              canDebug: false,
              pdfFileName: "${widget.bookingId}.pdf",
              actions: [
                IconButton(
                  onPressed: () async {
                    /*   await context.read<SalesController>().clearItems();
                    navKey.currentState?.pop(); */
                    // onDeletePressed();
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
              actionBarTheme: PdfActionBarTheme(
                elevation: 0,
                backgroundColor: Colors.grey.shade500,
                iconColor: Colors.black,
              ),
              build: (context) {
                return genaratePdf3(
                  widget.billModel,
                  widget.shop,
                  widget.refNo,
                  widget.shopData!,
                  "Prescription",
                  locationDetails,
                  routeName,
                  branchWarehouse,
                  totalOutstanding,
                );
              },
            ), */
    );
  }
}
