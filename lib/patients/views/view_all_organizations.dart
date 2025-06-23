import 'package:flutter/material.dart';

class ViewAllOrganizations extends StatefulWidget {
  const ViewAllOrganizations({Key? key}) : super(key: key);

  @override
  State<ViewAllOrganizations> createState() => _ViewAllOrganizationsState();
}

class _ViewAllOrganizationsState extends State<ViewAllOrganizations> {
  final TextEditingController _searchController = TextEditingController();
  List<Clinic> _filteredClinics = [];

  // Sample clinic data
  final List<Clinic> _allClinics = [
    Clinic(
      id: '1',
      name: 'City Medical Center',
      location: 'Downtown, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?w=400',
      rating: 4.8,
      distance: '2.5 km',
    ),
    Clinic(
      id: '2',
      name: 'Sunrise Health Clinic',
      location: 'Brooklyn Heights, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1576091160399-112ba8d25d1f?w=400',
      rating: 4.6,
      distance: '3.1 km',
    ),
    Clinic(
      id: '3',
      name: 'Green Valley Medical',
      location: 'Queens, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1586773860418-d37222d8ebc8?w=400',
      rating: 4.9,
      distance: '1.8 km',
    ),
    Clinic(
      id: '4',
      name: 'Metropolitan Health Hub',
      location: 'Manhattan, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1551190822-a9333d879b1f?w=400',
      rating: 4.7,
      distance: '4.2 km',
    ),
    Clinic(
      id: '5',
      name: 'Harmony Wellness Center',
      location: 'Staten Island, NY',
      imageUrl:
          'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400',
      rating: 4.5,
      distance: '5.7 km',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _filteredClinics = _allClinics;
    _searchController.addListener(_filterClinics);
  }

  void _filterClinics() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClinics = _allClinics.where((clinic) {
        return clinic.name.toLowerCase().contains(query) ||
            clinic.location.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Find Clinics',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search clinics or locations...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 16,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF64748B),
                        size: 24,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF64748B),
                              ),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Results Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredClinics.length} clinics found',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Color(0xFF3B82F6),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Near you',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Clinics List
          Expanded(
            child: _filteredClinics.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredClinics.length,
                    itemBuilder: (context, index) {
                      return _buildClinicCard(_filteredClinics[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicCard(Clinic clinic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // Handle clinic tap
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Clinic Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(clinic.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Clinic Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: Color(0xFF64748B),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              clinic.location,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Rating
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Color(0xFFF59E0B),
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  clinic.rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFA16207),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Distance
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              clinic.distance,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFCBD5E1),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.search_off,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No clinics found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search terms',
            style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class Clinic {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final String distance;

  Clinic({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.distance,
  });
}
