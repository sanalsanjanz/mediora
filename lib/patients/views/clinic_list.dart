import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mediora/apis/patients/api_helpers.dart';
import 'package:mediora/apis/patients/preference_controller.dart';
import 'package:mediora/models/clinic_model.dart';
import 'package:mediora/patients/views/organization_screen.dart';
import 'package:mediora/patients/views/view_all_organizations.dart';
import 'package:mediora/widgets/shimmer_box.dart';

Widget clinicGrid() {
  return FutureBuilder(
    future: ApiHelpers.getAllClinics(
      lat: PatientController.patientModel?.lat ?? 0,
      lon: PatientController.patientModel?.lon ?? 0,
    ),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF667EEA).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            FontAwesome.hospital_solid,
                            color: const Color(0xFF667EEA),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Nearest Clinics/Hospitals",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View More',
                            style: TextStyle(
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Color(0xFF667EEA),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                // height: 240,
                child: GridView.builder(
                  padding: EdgeInsets.all(12),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  // scrollDirection: Axis.horizontal,
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: shimmerBox(height: 200),
                    );
                  },
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisExtent: 180,
                    mainAxisSpacing: 15,
                    crossAxisSpacing: 15,
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (snapshot.hasData) {
        return buildSection(
          type: "pharmacy",
          count: 1,
          title: "Nearest Clinics/Hospitals",
          icon: FontAwesome.hospital_solid,
          items: snapshot.requireData,
          onViewMore: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => ViewAllOrganizations()));
          },
        );
      } else {
        return Center(child: Text("Error"));
      }
    },
  );
}

Widget buildSection({
  required String title,
  required String type,
  required int count,
  required IconData icon,
  required List<ClinicModel> items,
  required VoidCallback onViewMore,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF667EEA).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: onViewMore,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'View More',
                    style: TextStyle(
                      color: Color(0xFF667EEA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Color(0xFF667EEA),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SizedBox(
        // height: 240,
        child: GridView.builder(
          padding: EdgeInsets.all(12),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          // scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        OrganizationScreen(data: items[index]),
                  ),
                );
              },
              child: buildCard(items[index]),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: count,
            mainAxisExtent: count == 2 ? 250 : 230,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
        ),
      ),
    ],
  );
}

Widget buildCard(ClinicModel item) {
  return Container(
    // width: 280,
    // margin: const EdgeInsets.only(right: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image
        Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            image: DecorationImage(
              image: CachedNetworkImageProvider(item.image ?? ""),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          ),
        ),

        // Content
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.my_location_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item.locationName,
                    style: const TextStyle(
                      /*  fontSize: 14, */
                      color: Color(0xFF64748B),
                    ),
                  ),
                  /* const Spacer(),
                  if (item['rating'] != null) ...[
                    const Icon(Icons.star, size: 16, color: Color(0xFFEAB308)),
                    const SizedBox(width: 4),
                    Text(
                      item['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ], */
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ApiHelpers.calculateDistanceString(item.lat, item.lon),
                    style: const TextStyle(
                      /*                       fontSize: 14, */
                      color: Color(0xFF64748B),
                    ),
                  ),
                  /* const Spacer(),
                  if (item['rating'] != null) ...[
                    const Icon(Icons.star, size: 16, color: Color(0xFFEAB308)),
                    const SizedBox(width: 4),
                    Text(
                      item['rating'].toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ], */
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    ),
  );
}
