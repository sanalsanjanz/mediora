import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

makeCall({required String phone, required BuildContext context}) async {
  if (phone.isNotEmpty) {
    // You need to add url_launcher to your pubspec.yaml
    // import 'package:url_launcher/url_launcher.dart';
    final uri = Uri(scheme: 'tel', path: phone);
    launchUrl(uri);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Phone number not available')));
  }
}

Future<void> navigateToLocation({
  required double latitude,
  required double longitude,
  required BuildContext context,
}) async {
  final googleMapsUrl =
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  final appleMapsUrl = 'http://maps.apple.com/?daddr=$latitude,$longitude';

  final uri = Theme.of(context).platform == TargetPlatform.iOS
      ? Uri.parse(appleMapsUrl)
      : Uri.parse(googleMapsUrl);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not launch maps')));
  }
}
