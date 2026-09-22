import 'package:flutter_test/flutter_test.dart';
import 'package:buss_app/features/map/presentation/widgets/vehicle_marker_builder.dart';

void main() {
  test('los tipos predefinidos cubren bus, microbus, taxi, car y van', () {
    expect(
      VehicleMarkerBuilder.tipos,
      containsAll(['bus', 'microbus', 'taxi', 'car', 'van']),
    );
  });

  test('los vehículos públicos se clasifican como bus', () {
    expect(VehicleMarkerBuilder.classification('bus'), 'bus');
    expect(VehicleMarkerBuilder.classification('microbus'), 'bus');
  });

  test('los vehículos particulares se clasifican como car', () {
    expect(VehicleMarkerBuilder.classification('taxi'), 'car');
    expect(VehicleMarkerBuilder.classification('car'), 'car');
    expect(VehicleMarkerBuilder.classification('van'), 'car');
  });

  test('tipo desconocido por defecto es público', () {
    expect(VehicleMarkerBuilder.isParticular('otro'), isFalse);
    expect(VehicleMarkerBuilder.classification('otro'), 'bus');
  });

  test('isParticular distingue público de particular', () {
    expect(VehicleMarkerBuilder.isParticular('bus'), isFalse);
    expect(VehicleMarkerBuilder.isParticular('van'), isTrue);
  });
}