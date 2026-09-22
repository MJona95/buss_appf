class GeoPunto {
  final double latitud;
  final double longitud;

  const GeoPunto({required this.latitud, required this.longitud});
}

class VehiculoEnRuta {
  final String id;
  final String nombre;
  final String? placa;
  final String tipoCodigo;
  final int velocidadMaxima;
  final String horaSalida;
  final String? horaLlegada;
  final String rutaId;

  const VehiculoEnRuta({
    required this.id,
    required this.nombre,
    required this.placa,
    required this.tipoCodigo,
    required this.velocidadMaxima,
    required this.horaSalida,
    this.horaLlegada,
    required this.rutaId,
  });
}

class RutaMapa {
  final String id;
  final String nombre;
  final String origenNombre;
  final String destinoNombre;
  final List<GeoPunto> puntos;
  final List<VehiculoEnRuta> vehiculos;

  const RutaMapa({
    required this.id,
    required this.nombre,
    required this.origenNombre,
    required this.destinoNombre,
    required this.puntos,
    this.vehiculos = const [],
  });

  RutaMapa copyWith({List<VehiculoEnRuta>? vehiculos}) {
    return RutaMapa(
      id: id,
      nombre: nombre,
      origenNombre: origenNombre,
      destinoNombre: destinoNombre,
      puntos: puntos,
      vehiculos: vehiculos ?? this.vehiculos,
    );
  }
}
