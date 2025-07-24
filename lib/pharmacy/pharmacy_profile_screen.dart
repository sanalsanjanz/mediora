import 'package:flutter/material.dart';
import 'package:mediora/models/pharmacy/pharmacy_model.dart';
import 'edit_profile_screen.dart';

class PharmacyProfileScreen extends StatelessWidget {
  final PharmacyAuthModel pharmacy;

  const PharmacyProfileScreen({super.key, required this.pharmacy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // Modern App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.teal,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.teal, Color(0xFF00695C)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60), // Account for app bar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(pharmacy.image),
                        radius: 50,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      pharmacy.pharmacyName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddUpdatePharmacyPage(pharmacy: pharmacy),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Card
                  _buildSectionCard(
                    title: 'Basic Information',
                    icon: Icons.info_outline,
                    children: [
                      _buildInfoTile(
                        icon: Icons.person,
                        label: 'Pharmacist',
                        value: pharmacy.pharmacistName,
                      ),
                      _buildInfoTile(
                        icon: Icons.work_outline,
                        label: 'Experience',
                        value: '${pharmacy.experience} years',
                      ),
                      _buildInfoTile(
                        icon: Icons.description,
                        label: 'About',
                        value: pharmacy.about,
                        isExpandable: true,
                      ),
                      _buildInfoTile(
                        icon: Icons.verified,
                        label: 'License Number',
                        value: pharmacy.licenseNumber,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contact Information Card
                  _buildSectionCard(
                    title: 'Contact Information',
                    icon: Icons.contact_phone,
                    children: [
                      _buildInfoTile(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: pharmacy.locationName,
                      ),
                      _buildInfoTile(
                        icon: Icons.email,
                        label: 'Email',
                        value: pharmacy.email,
                      ),
                      _buildInfoTile(
                        icon: Icons.phone,
                        label: 'Contact',
                        value: pharmacy.contactNumber,
                      ),
                      _buildInfoTile(
                        icon: Icons.account_circle,
                        label: 'Username',
                        value: pharmacy.username,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Services & Payment Card
                  _buildSectionCard(
                    title: 'Services & Payment',
                    icon: Icons.medical_services,
                    children: [
                      _buildChipSection(
                        label: 'Services',
                        items: pharmacy.services,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      _buildChipSection(
                        label: 'Payment Methods',
                        items: pharmacy.paymentMethods,
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Ratings & Reviews Card
                  _buildSectionCard(
                    title: 'Ratings & Reviews',
                    icon: Icons.star,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.star,
                              label: 'Rating',
                              value: pharmacy.ratings ?? 'N/A',
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatItem(
                              icon: Icons.reviews,
                              label: 'Reviews',
                              value: pharmacy.reviewsCount?.toString() ?? 'N/A',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Working Hours Card
                  _buildWorkingHoursCard(),

                  const SizedBox(height: 20),

                  // System Information Card
                  _buildSectionCard(
                    title: 'System Information',
                    icon: Icons.settings,
                    children: [
                      _buildInfoTile(
                        icon: Icons.notifications,
                        label: 'FCM Token',
                        value: pharmacy.fcmToken.length > 30
                            ? '${pharmacy.fcmToken.substring(0, 30)}...'
                            : pharmacy.fcmToken,
                        isExpandable: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3440),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isExpandable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E3440),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: isExpandable ? null : 2,
                  overflow: isExpandable ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String label,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.schedule,
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Working Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3440),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pharmacy.workingHours.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final hour = pharmacy.workingHours[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hour.isHoliday
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    hour.isHoliday ? Icons.close : Icons.access_time,
                    color: hour.isHoliday ? Colors.red : Colors.green,
                    size: 20,
                  ),
                ),
                title: Text(
                  hour.day,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  hour.isHoliday ? 'Holiday' : '${hour.open} - ${hour.close}',
                  style: TextStyle(
                    color: hour.isHoliday ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: hour.isHoliday
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hour.isHoliday ? 'Closed' : 'Open',
                    style: TextStyle(
                      color: hour.isHoliday ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
