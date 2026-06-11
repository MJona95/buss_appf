class GoogleMapsApi {
  // Google Maps API Key placeholder
  // Replace with a valid key from Google Cloud Console
  static const String apiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

  // Endpoints
  static const String staticMapUrl =
      'https://maps.googleapis.com/maps/api/staticmap';
  static const String directionsUrl =
      'https://maps.googleapis.com/maps/api/directions/json';
  static const String placeAutocompleteUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String geocodingUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// Generates a static map image URL for a fallback or thumbnail view.
  static String getStaticMapThumbnail({
    required double latitude,
    required double longitude,
    int zoom = 15,
    String size = '600x300',
    String mapType = 'roadmap',
  }) {
    return '$staticMapUrl?center=$latitude,$longitude&zoom=$zoom&size=$size&maptype=$mapType&markers=color:red%7C$latitude,$longitude&key=$apiKey';
  }
}
