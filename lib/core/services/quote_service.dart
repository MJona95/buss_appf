class QuoteService {
  static const Map<String, int> cityIndex = {
    'somoto': 0,
    'esteli': 1,
    'estelí': 1,
    'ocotal': 2,
    'managua': 3,
  };

  static const double baseFare = 40;
  static const double perHop = 25;
  static const double sameCityFare = 45;
  static const double fallbackFare = 80;

  double calculate({
    required String pickup,
    required String dropoff,
  }) {
    final from = matchCity(pickup);
    final to = matchCity(dropoff);
    if (from == null || to == null) return fallbackFare;

    final hops = (from - to).abs();
    if (hops == 0) return sameCityFare;
    return baseFare + hops * perHop;
  }

  int? matchCity(String value) {
    final normalized = value.toLowerCase().trim();
    for (final entry in cityIndex.entries) {
      if (normalized.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
}
