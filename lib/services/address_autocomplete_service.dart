import 'dart:convert';
import 'package:http/http.dart' as http;

class AddressAutocompleteService {
  static const String _apiKey = 'AIzaSyCrYI_tNzWLRw928UgxpNd0HjqNKluYJj4';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  static Future<List<AddressSuggestion>> getAddressSuggestions({
    required String input,
    String? countryCode,
    String? language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/autocomplete/json');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'input': input,
          'key': _apiKey,
          'language': language,
          'components': countryCode != null ? 'country:$countryCode' : null,
          'types': 'address',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          return predictions.map((prediction) => AddressSuggestion.fromJson(prediction)).toList();
        } else {
          throw Exception('Google Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get address suggestions: $e');
    }
  }

  static Future<AddressDetails?> getAddressDetails({
    required String placeId,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/details/json');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'place_id': placeId,
          'key': _apiKey,
          'fields': 'address_components,formatted_address,geometry,name',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          return AddressDetails.fromJson(data['result']);
        } else {
          throw Exception('Google Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get address details: $e');
    }
  }

  static Future<List<AddressSuggestion>> getNearbyAddresses({
    required double latitude,
    required double longitude,
    int radius = 1000,
    String? language = 'en',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/nearbysearch/json');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'location': '$latitude,$longitude',
          'radius': radius,
          'key': _apiKey,
          'language': language,
          'type': 'establishment',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results.map((result) => AddressSuggestion.fromNearbyJson(result)).toList();
        } else {
          throw Exception('Google Places API error: ${data['status']}');
        }
      } else {
        throw Exception('HTTP error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get nearby addresses: $e');
    }
  }
}

class AddressSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;
  final List<String> types;

  AddressSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
    required this.types,
  });

  factory AddressSuggestion.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};
    
    return AddressSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }

  factory AddressSuggestion.fromNearbyJson(Map<String, dynamic> json) {
    return AddressSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['vicinity'] ?? json['name'] ?? '',
      mainText: json['name'] ?? '',
      secondaryText: json['vicinity'] ?? '',
      types: List<String>.from(json['types'] ?? []),
    );
  }
}

class AddressDetails {
  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final String? streetNumber;
  final String? route;
  final String? locality;
  final String? administrativeAreaLevel1;
  final String? administrativeAreaLevel2;
  final String? country;
  final String? postalCode;
  final String? name;

  AddressDetails({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.streetNumber,
    this.route,
    this.locality,
    this.administrativeAreaLevel1,
    this.administrativeAreaLevel2,
    this.country,
    this.postalCode,
    this.name,
  });

  factory AddressDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};
    final addressComponents = json['address_components'] as List? ?? [];
    
    String? streetNumber;
    String? route;
    String? locality;
    String? administrativeAreaLevel1;
    String? administrativeAreaLevel2;
    String? country;
    String? postalCode;

    for (final component in addressComponents) {
      final types = List<String>.from(component['types'] ?? []);
      
      if (types.contains('street_number')) {
        streetNumber = component['long_name'];
      } else if (types.contains('route')) {
        route = component['long_name'];
      } else if (types.contains('locality')) {
        locality = component['long_name'];
      } else if (types.contains('administrative_area_level_1')) {
        administrativeAreaLevel1 = component['long_name'];
      } else if (types.contains('administrative_area_level_2')) {
        administrativeAreaLevel2 = component['long_name'];
      } else if (types.contains('country')) {
        country = component['long_name'];
      } else if (types.contains('postal_code')) {
        postalCode = component['long_name'];
      }
    }

    return AddressDetails(
      placeId: json['place_id'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      streetNumber: streetNumber,
      route: route,
      locality: locality,
      administrativeAreaLevel1: administrativeAreaLevel1,
      administrativeAreaLevel2: administrativeAreaLevel2,
      country: country,
      postalCode: postalCode,
      name: json['name'],
    );
  }

  String get fullStreetAddress {
    final parts = <String>[];
    if (streetNumber != null) parts.add(streetNumber!);
    if (route != null) parts.add(route!);
    return parts.join(' ');
  }

  String get cityState {
    final parts = <String>[];
    if (locality != null) parts.add(locality!);
    if (administrativeAreaLevel1 != null) parts.add(administrativeAreaLevel1!);
    return parts.join(', ');
  }
}
