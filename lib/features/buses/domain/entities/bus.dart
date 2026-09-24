class Bus {
  final String id;
  final String name;
  final String? plate;
  final String vehicleType;
  final String transportType;
  final String? serviceType;
  final int capacity;
  final bool active;
  final String assignedRoutes;
  final String? horaSalida;
  final String? horaLlegada;

  const Bus({
    required this.id,
    required this.name,
    required this.plate,
    required this.vehicleType,
    required this.transportType,
    required this.capacity,
    required this.active,
    this.serviceType,
    this.assignedRoutes = '',
    this.horaSalida,
    this.horaLlegada,
  });

  String get number => (plate == null || plate!.isEmpty) ? name : plate!;
  String get model => vehicleType;
  String get operatingHours =>
      transportType == 'private' ? 'Privado' : 'Público';
  String get serviceLabel =>
      serviceType == 'expreso' ? 'Expreso' : 'Ruteado';
  String get currentLocation =>
      assignedRoutes.isEmpty ? 'Sin ruta asignada' : assignedRoutes;
  String get phoneNumber => '';
  String get status => active ? 'En Servicio' : 'En Mantenimiento';
  bool get isEnServicio => active;
  bool get tieneHorario => horaSalida != null && horaLlegada != null;
  String get horarioLabel =>
      'Sale $horaSalida · Llega $horaLlegada (estimado)';

  Bus copyWith({
    String? id,
    String? name,
    String? plate,
    String? vehicleType,
    String? transportType,
    String? serviceType,
    int? capacity,
    bool? active,
    String? assignedRoutes,
    String? horaSalida,
    String? horaLlegada,
  }) {
    return Bus(
      id: id ?? this.id,
      name: name ?? this.name,
      plate: plate ?? this.plate,
      vehicleType: vehicleType ?? this.vehicleType,
      transportType: transportType ?? this.transportType,
      serviceType: serviceType ?? this.serviceType,
      capacity: capacity ?? this.capacity,
      active: active ?? this.active,
      assignedRoutes: assignedRoutes ?? this.assignedRoutes,
      horaSalida: horaSalida ?? this.horaSalida,
      horaLlegada: horaLlegada ?? this.horaLlegada,
    );
  }
}
