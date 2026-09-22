import 'dart:convert';
import 'dart:io';
import 'dart:math';

const routes = [
  {
    'name': 'somoto_esteli',
    'id': '00000000-0000-4000-8000-000000000201',
    'idx': 1,
    'coords': '-86.58185,13.48858;-86.35200,13.07620',
  },
  {
    'name': 'esteli_managua',
    'id': '00000000-0000-4000-8000-000000000202',
    'idx': 2,
    'coords': '-86.35200,13.07620;-86.19338,12.13422',
  },
  {
    'name': 'ocotal_managua',
    'id': '00000000-0000-4000-8000-000000000203',
    'idx': 3,
    'coords': '-86.47670,13.62220;-86.19338,12.13422',
  },
  {
    'name': 'somoto_managua',
    'id': '00000000-0000-4000-8000-000000000204',
    'idx': 4,
    'coords': '-86.58185,13.48858;-86.35200,13.07620;-86.19338,12.13422',
  },
];

const pointsPerRoute = 240;

void main(List<String> args) async {
  final cacheDir = Directory(r'C:\Users\mgutierrez\AppData\Local\Temp\opencode');
  final points = <Map<String, Object>>[];

  for (final route in routes) {
    final name = route['name'] as String;
    final cache = File('${cacheDir.path}\\osrm_$name.json');
    List<dynamic> raw;
    if (cache.existsSync()) {
      raw = jsonDecode(cache.readAsStringSync()) as List<dynamic>;
    } else {
      raw = await _fetchOsrm(route['coords'] as String);
      cache.writeAsStringSync(jsonEncode(raw));
    }
    final sampled = _downsample(raw, pointsPerRoute);
    stdout.writeln('$name ${raw.length} -> ${sampled.length}');
    var orden = 1;
    for (final pair in sampled) {
      final lon = (pair[0] as num).toDouble();
      final lat = (pair[1] as num).toDouble();
      final idx = route['idx'] as int;
      final id =
          '00000000-0000-4000-8000-00000$idx${orden.toString().padLeft(6, '0')}';
      points.add({
        'id': id,
        'ruta_id': route['id'] as String,
        'orden': orden,
        'latitud': double.parse(lat.toStringAsFixed(6)),
        'longitud': double.parse(lon.toStringAsFixed(6)),
      });
      orden++;
    }
  }

  _writeDart(points);
  _writeSql(points);
  stdout.writeln('wrote ${points.length} points');
}

Future<List<dynamic>> _fetchOsrm(String coords) async {
  final uri = Uri.parse(
    'https://router.project-osrm.org/route/v1/driving/$coords?overview=full&geometries=geojson',
  );
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final geometry =
        (json['routes'] as List).first['geometry'] as Map<String, dynamic>;
    return geometry['coordinates'] as List<dynamic>;
  } finally {
    client.close();
  }
}

List<List<dynamic>> _downsample(List<dynamic> raw, int target) {
  if (raw.length <= target) {
    return raw.map((e) => e as List<dynamic>).toList();
  }
  final step = (raw.length - 1) / (target - 1);
  final picked = <List<dynamic>>[];
  for (var i = 0; i < target; i++) {
    final index = min(raw.length - 1, (i * step).round());
    picked.add(raw[index] as List<dynamic>);
  }
  return picked;
}

void _writeDart(List<Map<String, Object>> points) {
  final buffer = StringBuffer()..writeln('const rutaPuntosSeed = [');
  for (final point in points) {
    buffer.writeln('  {');
    buffer.writeln("    'id': '${point['id']}',");
    buffer.writeln("    'ruta_id': '${point['ruta_id']}',");
    buffer.writeln("    'orden': ${point['orden']},");
    buffer.writeln("    'latitud': ${point['latitud']},");
    buffer.writeln("    'longitud': ${point['longitud']},");
    buffer.writeln('  },');
  }
  buffer.writeln('];');
  File('lib/core/database/catalog_ruta_puntos_seed.dart')
      .writeAsStringSync(buffer.toString());
}

void _writeSql(List<Map<String, Object>> points) {
  final buffer = StringBuffer();
  buffer.writeln('insert into ruta_puntos (id, ruta_id, orden, latitud, longitud) values');
  for (var i = 0; i < points.length; i++) {
    final p = points[i];
    final comma = i == points.length - 1 ? ';' : ',';
    buffer.writeln(
      "    ('${p['id']}', '${p['ruta_id']}', ${p['orden']}, ${p['latitud']}, ${p['longitud']})$comma",
    );
  }
  File(r'C:\Users\mgutierrez\AppData\Local\Temp\opencode\ruta_puntos_inserts.sql')
      .writeAsStringSync(buffer.toString());
}
