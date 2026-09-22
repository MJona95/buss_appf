import 'package:buss_app/core/services/quote_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuoteService service;

  setUp(() {
    service = QuoteService();
  });

  test('same city uses sameCityFare', () {
    expect(
      service.calculate(pickup: 'Somoto Centro', dropoff: 'Somoto Terminal'),
      QuoteService.sameCityFare,
    );
  });

  test('adjacent cities use base + one hop', () {
    expect(
      service.calculate(pickup: 'Somoto', dropoff: 'Estelí'),
      QuoteService.baseFare + QuoteService.perHop,
    );
  });

  test('somoto to managua is three hops', () {
    expect(
      service.calculate(pickup: 'Somoto', dropoff: 'Managua'),
      QuoteService.baseFare + QuoteService.perHop * 3,
    );
  });

  test('unknown cities fall back', () {
    expect(
      service.calculate(pickup: 'Unknown A', dropoff: 'Unknown B'),
      QuoteService.fallbackFare,
    );
  });
}
