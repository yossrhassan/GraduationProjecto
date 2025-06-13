import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class MapsLauncher {
  static Future<void> launchMapsWithCoordinates({
    required double latitude,
    required double longitude,
    String? destinationName,
  }) async {
    try {
      // Create a formatted destination name for better UX
      final destination = destinationName ?? 'Destination';
      
      if (Platform.isAndroid) {
        // Use Google Maps for Android
        final googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_name=${Uri.encodeComponent(destination)}'
        );
        
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to generic maps URL
          await _launchFallbackMaps(latitude, longitude, destination);
        }
      } else if (Platform.isIOS) {
        // Use Apple Maps for iOS
        final appleMapsUrl = Uri.parse(
          'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d'
        );
        
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to Google Maps
          await _launchFallbackMaps(latitude, longitude, destination);
        }
      } else {
        // Fallback for other platforms
        await _launchFallbackMaps(latitude, longitude, destination);
      }
    } catch (e) {
      print('Error launching maps: $e');
      // If all else fails, try a basic Google Maps URL
      await _launchFallbackMaps(latitude, longitude, destinationName ?? 'Destination');
    }
  }

  static Future<void> _launchFallbackMaps(double latitude, double longitude, String destination) async {
    final fallbackUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'
    );
    
    try {
      if (await canLaunchUrl(fallbackUrl)) {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps application';
      }
    } catch (e) {
      print('Failed to launch fallback maps: $e');
      throw 'Unable to open maps application';
    }
  }

  // Alternative method using facility name for search-based navigation
  static Future<void> launchMapsWithSearch({
    required String facilityName,
    String? city,
  }) async {
    try {
      final searchQuery = city != null ? '$facilityName, $city' : facilityName;
      final encodedQuery = Uri.encodeComponent(searchQuery);
      
      if (Platform.isAndroid) {
        final googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/$encodedQuery'
        );
        
        if (await canLaunchUrl(googleMapsUrl)) {
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch Google Maps';
        }
      } else if (Platform.isIOS) {
        final appleMapsUrl = Uri.parse(
          'https://maps.apple.com/?q=$encodedQuery'
        );
        
        if (await canLaunchUrl(appleMapsUrl)) {
          await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
        } else {
          // Fallback to Google Maps
          final googleMapsUrl = Uri.parse(
            'https://www.google.com/maps/search/$encodedQuery'
          );
          await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        }
      } else {
        // Fallback for other platforms
        final googleMapsUrl = Uri.parse(
          'https://www.google.com/maps/search/$encodedQuery'
        );
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching maps with search: $e');
      throw 'Unable to open maps application';
    }
  }
} 