class Trip {
  final String id;
  final String name;
  final String originName;
  final String destinationName;
  final double price;
  final String currency;
  final String transportType;
  final String? serviceType;
  final String? horaSalida;
  final String? horaLlegada;
  final bool isBookmarked;
  final bool isAvailable;

  const Trip({
    required this.id,
    required this.name,
    required this.originName,
    required this.destinationName,
    required this.price,
    this.currency = 'NIO',
    this.transportType = 'public',
    this.serviceType,
    this.horaSalida,
    this.horaLlegada,
    required this.isBookmarked,
    this.isAvailable = true,
  });

  String get companyName => name;
  String get duration => '$originName → $destinationName';
  double get rating => 0;
  String get imageUrl => '';
  bool get esExpreso => serviceType == 'expreso';
  bool get tieneHorario => horaSalida != null && horaLlegada != null;
  String get horarioLabel =>
      'Sale $horaSalida · Llega $horaLlegada (estimado)';

  Trip copyWith({
    String? id,
    String? name,
    String? originName,
    String? destinationName,
    double? price,
    String? currency,
    String? transportType,
    String? serviceType,
    String? horaSalida,
    String? horaLlegada,
    bool? isBookmarked,
    bool? isAvailable,
  }) {
    return Trip(
      id: id ?? this.id,
      name: name ?? this.name,
      originName: originName ?? this.originName,
      destinationName: destinationName ?? this.destinationName,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      transportType: transportType ?? this.transportType,
      serviceType: serviceType ?? this.serviceType,
      horaSalida: horaSalida ?? this.horaSalida,
      horaLlegada: horaLlegada ?? this.horaLlegada,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
