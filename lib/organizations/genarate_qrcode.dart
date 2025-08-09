import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:mediora/apis/patients/organization/organization_api_links.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share_plus/share_plus.dart';

class DoctorQRCodeScreen extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String clinicName;
  final String specialization;

  const DoctorQRCodeScreen({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicName,
    this.specialization = '',
  });

  @override
  State<DoctorQRCodeScreen> createState() => _DoctorQRCodeScreenState();
}

class _DoctorQRCodeScreenState extends State<DoctorQRCodeScreen> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isSharing = false;

  String get _qrUrl => '$qrCodeBooking${widget.doctorId}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const ui.Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Appointment QR Code',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        // padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                /*   boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ], */
              ),
              child: Column(
                children: [
                  // Doctor Info
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Color(0xFF667EEA),

                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(
                          Icons.local_hospital_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.doctorName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.specialization.isNotEmpty
                                  ? widget.specialization
                                  : 'Medical Professional',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.clinicName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // QR Code Section
                  RepaintBoundary(
                    key: _qrKey,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          // QR Code
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClassicQrWidget(data: _qrUrl),
                          ),

                          const SizedBox(height: 24),

                          // Instructions
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F9FF),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFBAE6FD),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.qr_code_scanner,
                                  color: Color(0xFF667EEA),
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Scan & Book Appointment',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0C4A6E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Scan this QR code to quickly book an appointment with ${widget.doctorName}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF0C4A6E),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Security Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.security,
                                color: Color(0xFF059669),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Secure & Verified',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _copyToClipboard,
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy Link'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Color(0xFF667EEA)),
                            foregroundColor: Color(0xFF764BA2),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSharing ? null : _shareQRCode,
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.share),
                          label: Text(_isSharing ? 'Sharing...' : 'Share QR'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF764BA2),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _qrUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareQRCode() async {
    setState(() {
      _isSharing = true;
    });

    try {
      // Capture the QR code widget as image
      RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/doctor_qr_${widget.doctorId}.png';

        // Save image to file
        File imageFile = File(imagePath);
        await imageFile.writeAsBytes(pngBytes);

        // Share the image with text
        await Share.shareXFiles(
          [XFile(imagePath)],
          text:
              '📅 Book appointment with ${widget.doctorName} at ${widget.clinicName}\n\n'
              '🏥 Scan the QR code for quick booking\n'
              '🔒 Secure booking system\n\n'
              '$_qrUrl',
          subject: 'Book Appointment - ${widget.doctorName}',
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing QR code: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      _isSharing = false;
    });
  }
}

class ClassicQrWidget extends StatelessWidget {
  final String data;
  const ClassicQrWidget({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    return PrettyQrView.data(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.H,
      decoration: const PrettyQrDecoration(
        // white background + standard quiet zone
        background: Colors.white,
        quietZone: PrettyQrQuietZone.zero,

        // use SquaresSymbol and turn rounding -> 0 for classic blocky modules
        shape: PrettyQrSquaresSymbol(
          color: Color(0xFF000000),
          density: 1.0,
          rounding: 0.0,
        ),

        // optional center logo — remove this block if logo causes trouble
        image: PrettyQrDecorationImage(
          image: AssetImage('assets/1.png'),
          position: PrettyQrDecorationImagePosition.embedded,
          scale: 0.18,
        ),
      ),
    );
  }
}

/* // Usage Example:
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor QR Code',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Use a modern font
      ),
      home: const DoctorQRCodeScreen(
        doctorId: 'DOC123456',
        doctorName: 'Sarah Johnson',
        clinicName: 'City Medical Center',
        specialization: 'Cardiologist',
      ),
    );
  }
}
 */
