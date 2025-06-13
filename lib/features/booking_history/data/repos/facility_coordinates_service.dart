import 'package:graduation_project/core/utils/service_locator.dart';
import 'package:graduation_project/features/facilities/data/repos/facilities_repo_impl.dart';

class FacilityCoordinatesService {
  final FacilitiesRepoImpl facilitiesRepo;

  FacilityCoordinatesService() : facilitiesRepo = getIt<FacilitiesRepoImpl>();

  Future<Map<String, double>?> getFacilityCoordinates(
      String facilityName) async {
    try {
      print('🗺️ Getting coordinates for facility: $facilityName');

      // Fetch all facilities
      final result = await facilitiesRepo.fetchFacilities();

      return result.fold(
        (failure) {
          print('❌ Failed to fetch facilities: ${failure.errMessage}');
          return null;
        },
        (facilities) {
          // Find facility by name (case-insensitive)
          final facility = facilities.firstWhere(
            (f) =>
                f.name?.toLowerCase().trim() ==
                facilityName.toLowerCase().trim(),
            orElse: () => facilities.firstWhere(
              (f) =>
                  f.name?.toLowerCase().contains(facilityName.toLowerCase()) ??
                  false,
              orElse: () => throw Exception('Facility not found'),
            ),
          );

          if (facility.address?.latitude != null &&
              facility.address?.longitude != null) {
            print(
                '✅ Found coordinates for $facilityName: ${facility.address!.latitude}, ${facility.address!.longitude}');
            return {
              'latitude': facility.address!.latitude!,
              'longitude': facility.address!.longitude!,
            };
          } else {
            print('❌ No coordinates found for facility: $facilityName');
            return null;
          }
        },
      );
    } catch (e) {
      print('❌ Error getting facility coordinates: $e');
      return null;
    }
  }

  // Fallback method using city name if facility coordinates are not found
  Future<Map<String, double>?> getCityCoordinates(String cityName) async {
    // Basic coordinates for major Egyptian cities as fallback
    final cityCoordinates = {
      'cairo': {'latitude': 30.0444, 'longitude': 31.2357},
      'giza': {'latitude': 30.0131, 'longitude': 31.2089},
      'alexandria': {'latitude': 31.2001, 'longitude': 29.9187},
      'luxor': {'latitude': 25.6872, 'longitude': 32.6396},
      'aswan': {'latitude': 24.0889, 'longitude': 32.8998},
    };

    final cityKey = cityName.toLowerCase().trim();
    if (cityCoordinates.containsKey(cityKey)) {
      print('✅ Using city coordinates for $cityName');
      return cityCoordinates[cityKey]!
          .map((key, value) => MapEntry(key, value.toDouble()));
    }

    print('❌ No coordinates found for city: $cityName');
    return null;
  }
}
