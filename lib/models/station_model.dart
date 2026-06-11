class StationModel {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String nextRoute;
  final int nextTimeMins;
  final double latitude;
  final double longitude;

  StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.nextRoute,
    required this.nextTimeMins,
    required this.latitude,
    required this.longitude,
  });

  factory StationModel.fromDbMap(Map<String, dynamic> map) {
    final idVal = map['id'] as String;

    // Map station IDs to mock geographic coordinates for interactive map rendering
    double lat = 12.865416; // default Nicaragua coordinates
    double lng = -86.273062;

    if (idVal == 'st_1') {
      lat = 13.48858; // Somoto
      lng = -86.58185;
    } else if (idVal == 'st_2') {
      lat = 13.07620; // Estelí
      lng = -86.35200;
    } else if (idVal == 'st_3') {
      lat = 13.62220; // Ocotal
      lng = -86.47670;
    } else if (idVal == 'st_4') {
      lat = 12.13422; // Managua
      lng = -86.19338;
    }

    return StationModel(
      id: idVal,
      name: map['name'] as String,
      address: map['address'] as String,
      distance: (map['distance'] as num).toDouble(),
      nextRoute: map['next_route'] as String,
      nextTimeMins: map['next_time_mins'] as int,
      latitude: lat,
      longitude: lng,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'distance': distance,
      'next_route': nextRoute,
      'next_time_mins': nextTimeMins,
    };
  }
}
