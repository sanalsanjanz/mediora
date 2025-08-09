import 'package:flutter/material.dart';
import 'package:mediora/organizations/genarate_qrcode.dart';

class QRCodeNavigationBanner extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String clinicName;
  final String specialization;

  const QRCodeNavigationBanner({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicName,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      /*  margin: const EdgeInsets.all(16), */
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DoctorQRCodeScreen(
                  doctorId: doctorId,
                  doctorName: doctorName,
                  clinicName: clinicName,
                  specialization: specialization,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // QR Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.qr_code_2,
                    color: Colors.white,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Share Appointment QR',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Let patients book appointments easily',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'WhatsApp • SMS • Social Media',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
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

// Alternative Compact Banner Design
class CompactQRBanner extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String clinicName;
  final String specialization;

  const CompactQRBanner({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicName,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DoctorQRCodeScreen(
                  doctorId: doctorId,
                  doctorName: doctorName,
                  clinicName: clinicName,
                  specialization: specialization,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Color(0xFF3B82F6),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Generate QR Code',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Share for easy appointment booking',
                        style: TextStyle(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons.arrow_forward_ios,
                  color: const Color(0xFF9CA3AF),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Card-style Banner with Stats
class QRCardBanner extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final String clinicName;
  final String specialization;

  const QRCardBanner({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.clinicName,
    required this.specialization,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DoctorQRCodeScreen(
                  doctorId: doctorId,
                  doctorName: doctorName,
                  clinicName: clinicName,
                  specialization: specialization,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.qr_code,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'QR Code Sharing',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Generate & share appointment QR code',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.security,
                        'Secure',
                        Color(0xFF059669),
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.share,
                        'Shareable',
                        Color(0xFF3B82F6),
                      ),
                    ),
                    Expanded(
                      child: _buildFeatureItem(
                        Icons.speed,
                        'Quick Book',
                        Color(0xFFDB2777),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Usage Example - Replace your TextButton with any of these:
class ExampleUsage extends StatelessWidget {
  const ExampleUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Option 1: Gradient Banner (Most Professional)
          QRCodeNavigationBanner(
            doctorId: "PatientController.doctorModel?.user.id ?? ''",
            doctorName: "PatientController.doctorModel?.user.name ?? ''",
            clinicName: 'Mediora Doctors',
            specialization:
                "PatientController.doctorModel?.user.specialization ?? 'General'",
          ),

          // Option 2: Compact Banner (Space-saving)
          CompactQRBanner(
            doctorId: "PatientController.doctorModel?.user.id ?? ''",
            doctorName: "PatientController.doctorModel?.user.name ?? ''",
            clinicName: 'Mediora Doctors',
            specialization:
                "PatientController.doctorModel?.user.specialization ?? 'General'",
          ),

          // Option 3: Card Banner (Feature-rich)
          QRCardBanner(
            doctorId: "PatientController.doctorModel?.user.id ?? ''",
            doctorName: "PatientController.doctorModel?.user.name ?? ''",
            clinicName: 'Mediora Doctors',
            specialization:
                "PatientController.doctorModel?.user.specialization ?? 'General'",
          ),
        ],
      ),
    );
  }
}
