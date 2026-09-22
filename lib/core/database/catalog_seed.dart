const tipoBusId = '00000000-0000-4000-8000-000000000001';
const tipoMicrobusId = '00000000-0000-4000-8000-000000000002';
const tipoTaxiId = '00000000-0000-4000-8000-000000000003';
const tipoCarId = '00000000-0000-4000-8000-000000000004';
const tipoVanId = '00000000-0000-4000-8000-000000000005';

const estacionSomotoId = '00000000-0000-4000-8000-000000000101';
const estacionEsteliId = '00000000-0000-4000-8000-000000000102';
const estacionOcotalId = '00000000-0000-4000-8000-000000000103';
const estacionManaguaId = '00000000-0000-4000-8000-000000000104';

const rutaSomotoEsteliId = '00000000-0000-4000-8000-000000000201';
const rutaEsteliManaguaId = '00000000-0000-4000-8000-000000000202';
const rutaOcotalManaguaId = '00000000-0000-4000-8000-000000000203';
const rutaSomotoManaguaId = '00000000-0000-4000-8000-000000000204';

const vehiculo42Id = '00000000-0000-4000-8000-000000000301';
const vehiculo15Id = '00000000-0000-4000-8000-000000000302';
const vehiculo88Id = '00000000-0000-4000-8000-000000000303';
const vehiculoVanId = '00000000-0000-4000-8000-000000000304';

const tiposVehiculoSeed = [
  {
    'id': tipoBusId,
    'codigo': 'bus',
    'nombre': 'Autobús',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': tipoMicrobusId,
    'codigo': 'microbus',
    'nombre': 'Microbús',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': tipoTaxiId,
    'codigo': 'taxi',
    'nombre': 'Taxi',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': tipoCarId,
    'codigo': 'car',
    'nombre': 'Auto',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': tipoVanId,
    'codigo': 'van',
    'nombre': 'Van',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];

const estacionesSeed = [
  {
    'id': estacionSomotoId,
    'nombre': 'Terminal de Buses de Somoto',
    'latitud': 13.48858,
    'longitud': -86.58185,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': estacionEsteliId,
    'nombre': 'Terminal COTRAN Sur (Estelí)',
    'latitud': 13.07620,
    'longitud': -86.35200,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': estacionOcotalId,
    'nombre': 'Terminal de Buses de Ocotal',
    'latitud': 13.62220,
    'longitud': -86.47670,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': estacionManaguaId,
    'nombre': 'Terminal El Mayoreo (Managua)',
    'latitud': 12.13422,
    'longitud': -86.19338,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];

const rutasSeed = [
  {
    'id': rutaSomotoEsteliId,
    'nombre': 'Somoto - Estelí',
    'origen_nombre': 'Somoto',
    'destino_nombre': 'Estelí',
    'origen_lat': 13.48858,
    'origen_lng': -86.58185,
    'destino_lat': 13.07620,
    'destino_lng': -86.35200,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': rutaEsteliManaguaId,
    'nombre': 'Estelí - Managua',
    'origen_nombre': 'Estelí',
    'destino_nombre': 'Managua',
    'origen_lat': 13.07620,
    'origen_lng': -86.35200,
    'destino_lat': 12.13422,
    'destino_lng': -86.19338,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': rutaOcotalManaguaId,
    'nombre': 'Ocotal - Managua',
    'origen_nombre': 'Ocotal',
    'destino_nombre': 'Managua',
    'origen_lat': 13.62220,
    'origen_lng': -86.47670,
    'destino_lat': 12.13422,
    'destino_lng': -86.19338,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': rutaSomotoManaguaId,
    'nombre': 'Somoto - Managua',
    'origen_nombre': 'Somoto',
    'destino_nombre': 'Managua',
    'origen_lat': 13.48858,
    'origen_lng': -86.58185,
    'destino_lat': 12.13422,
    'destino_lng': -86.19338,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];

const vehiculosSeed = [
  {
    'id': vehiculo42Id,
    'nombre': 'Unidad 42',
    'placa': '42',
    'tipo_vehiculo_id': tipoBusId,
    'tipo_transporte': 'public',
      'capacidad': 18,
      'velocidad_maxima': 80,
      'hora_salida': '06:00',
      'activo': 1,
      'creado_en': '2026-01-01T00:00:00Z',
    },
    {
      'id': vehiculo15Id,
      'nombre': 'Unidad 15',
      'placa': '15',
      'tipo_vehiculo_id': tipoBusId,
      'tipo_transporte': 'public',
      'capacidad': 44,
      'velocidad_maxima': 80,
      'hora_salida': '08:30',
      'activo': 0,
      'creado_en': '2026-01-01T00:00:00Z',
    },
    {
      'id': vehiculo88Id,
      'nombre': 'Unidad 88',
      'placa': '88',
      'tipo_vehiculo_id': tipoBusId,
      'tipo_transporte': 'public',
      'capacidad': 21,
      'velocidad_maxima': 80,
      'hora_salida': '05:00',
      'activo': 1,
      'creado_en': '2026-01-01T00:00:00Z',
    },
    {
      'id': vehiculoVanId,
      'nombre': 'Van ejecutiva',
      'placa': 'VAN-01',
      'tipo_vehiculo_id': tipoVanId,
      'tipo_transporte': 'private',
      'capacidad': 12,
      'velocidad_maxima': 90,
      'hora_salida': '07:00',
      'activo': 1,
      'creado_en': '2026-01-01T00:00:00Z',
    },
];

const vehiculoRutasSeed = [
  {
    'id': '00000000-0000-4000-8000-000000000401',
    'vehiculo_id': vehiculo42Id,
    'ruta_id': rutaSomotoEsteliId,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000402',
    'vehiculo_id': vehiculo42Id,
    'ruta_id': rutaSomotoManaguaId,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000403',
    'vehiculo_id': vehiculo15Id,
    'ruta_id': rutaEsteliManaguaId,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000404',
    'vehiculo_id': vehiculo88Id,
    'ruta_id': rutaOcotalManaguaId,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000405',
    'vehiculo_id': vehiculoVanId,
    'ruta_id': rutaSomotoManaguaId,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];

const rutaEstacionesSeed = [
  {
    'id': '00000000-0000-4000-8000-000000000501',
    'ruta_id': rutaSomotoEsteliId,
    'estacion_id': estacionSomotoId,
    'orden_parada': 1,
  },
  {
    'id': '00000000-0000-4000-8000-000000000502',
    'ruta_id': rutaSomotoEsteliId,
    'estacion_id': estacionEsteliId,
    'orden_parada': 2,
  },
  {
    'id': '00000000-0000-4000-8000-000000000503',
    'ruta_id': rutaEsteliManaguaId,
    'estacion_id': estacionEsteliId,
    'orden_parada': 1,
  },
  {
    'id': '00000000-0000-4000-8000-000000000504',
    'ruta_id': rutaEsteliManaguaId,
    'estacion_id': estacionManaguaId,
    'orden_parada': 2,
  },
  {
    'id': '00000000-0000-4000-8000-000000000505',
    'ruta_id': rutaOcotalManaguaId,
    'estacion_id': estacionOcotalId,
    'orden_parada': 1,
  },
  {
    'id': '00000000-0000-4000-8000-000000000506',
    'ruta_id': rutaOcotalManaguaId,
    'estacion_id': estacionManaguaId,
    'orden_parada': 2,
  },
  {
    'id': '00000000-0000-4000-8000-000000000507',
    'ruta_id': rutaSomotoManaguaId,
    'estacion_id': estacionSomotoId,
    'orden_parada': 1,
  },
  {
    'id': '00000000-0000-4000-8000-000000000508',
    'ruta_id': rutaSomotoManaguaId,
    'estacion_id': estacionEsteliId,
    'orden_parada': 2,
  },
  {
    'id': '00000000-0000-4000-8000-000000000509',
    'ruta_id': rutaSomotoManaguaId,
    'estacion_id': estacionManaguaId,
    'orden_parada': 3,
  },
];

const tarifasSeed = [
  {
    'id': '00000000-0000-4000-8000-000000000601',
    'ruta_id': rutaSomotoEsteliId,
    'tipo_vehiculo_id': tipoBusId,
    'monto': 45.00,
    'moneda': 'NIO',
    'vigente_desde': '2026-01-01T00:00:00Z',
    'vigente_hasta': null,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000602',
    'ruta_id': rutaEsteliManaguaId,
    'tipo_vehiculo_id': tipoBusId,
    'monto': 90.00,
    'moneda': 'NIO',
    'vigente_desde': '2026-01-01T00:00:00Z',
    'vigente_hasta': null,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000603',
    'ruta_id': rutaOcotalManaguaId,
    'tipo_vehiculo_id': tipoBusId,
    'monto': 110.00,
    'moneda': 'NIO',
    'vigente_desde': '2026-01-01T00:00:00Z',
    'vigente_hasta': null,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000604',
    'ruta_id': rutaSomotoManaguaId,
    'tipo_vehiculo_id': tipoBusId,
    'monto': 130.00,
    'moneda': 'NIO',
    'vigente_desde': '2026-01-01T00:00:00Z',
    'vigente_hasta': null,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000605',
    'ruta_id': rutaSomotoManaguaId,
    'tipo_vehiculo_id': tipoVanId,
    'monto': 220.00,
    'moneda': 'NIO',
    'vigente_desde': '2026-01-01T00:00:00Z',
    'vigente_hasta': null,
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];

const horariosSeed = [
  {
    'id': '00000000-0000-4000-8000-000000000701',
    'ruta_id': rutaSomotoEsteliId,
    'vehiculo_id': vehiculo42Id,
    'hora_salida': '05:30',
    'hora_llegada': '06:47',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000702',
    'ruta_id': rutaSomotoManaguaId,
    'vehiculo_id': vehiculo42Id,
    'hora_salida': '07:00',
    'hora_llegada': '10:50',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000703',
    'ruta_id': rutaEsteliManaguaId,
    'vehiculo_id': vehiculo15Id,
    'hora_salida': '08:30',
    'hora_llegada': '11:03',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000704',
    'ruta_id': rutaOcotalManaguaId,
    'vehiculo_id': vehiculo88Id,
    'hora_salida': '05:00',
    'hora_llegada': '08:58',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
  {
    'id': '00000000-0000-4000-8000-000000000705',
    'ruta_id': rutaSomotoManaguaId,
    'vehiculo_id': vehiculoVanId,
    'hora_salida': '07:00',
    'hora_llegada': '10:31',
    'activo': 1,
    'creado_en': '2026-01-01T00:00:00Z',
  },
];
