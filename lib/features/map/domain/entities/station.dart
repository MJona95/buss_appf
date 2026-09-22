class Station {
  final String id;
  final String name;
  final double distance;
  final String nextRoute;
  final double latitude;
  final double longitude;
  final String? rutaId;
  final String? horaSalida;
  final String? horaLlegada;

  const Station({
    required this.id,
    required this.name,
    required this.distance,
    required this.nextRoute,
    required this.latitude,
    required this.longitude,
    this.rutaId,
    this.horaSalida,
    this.horaLlegada,
  });

  String get address => nextRoute;
  int get nextTimeMins => 0;
  bool get tieneHorario => horaSalida != null && horaLlegada != null;
  String get horarioLabel =>
      'Sale $horaSalida · Llega $horaLlegada (estimado)';

  Station copyWith({
    String? id,
    String? name,
    double? distance,
    String? nextRoute,
    double? latitude,
    double? longitude,
    String? rutaId,
    String? horaSalida,
    String? horaLlegada,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      distance: distance ?? this.distance,
      nextRoute: nextRoute ?? this.nextRoute,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      rutaId: rutaId ?? this.rutaId,
      horaSalida: horaSalida ?? this.horaSalida,
      horaLlegada: horaLlegada ?? this.horaLlegada,
    );
  }
}
