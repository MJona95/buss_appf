class StationModel {
  final String id;
  final String name;
  final String address;
  final double distance;
  final String nextRoute;
  final int nextTimeMins;

  StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.nextRoute,
    required this.nextTimeMins,
  });

  factory StationModel.fromDbMap(Map<String, dynamic> map) {
    return StationModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      distance: (map['distance'] as num).toDouble(),
      nextRoute: map['next_route'] as String,
      nextTimeMins: map['next_time_mins'] as int,
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
