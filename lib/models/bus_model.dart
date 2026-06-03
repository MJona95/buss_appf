class BusModel {
  final String id;
  final String number;
  final String model;
  final int capacity;
  final String operatingHours;
  final String currentLocation;
  final String phoneNumber;
  final String status; // 'En Servicio', 'En Mantenimiento'

  BusModel({
    required this.id,
    required this.number,
    required this.model,
    required this.capacity,
    required this.operatingHours,
    required this.currentLocation,
    required this.phoneNumber,
    required this.status,
  });

  bool get isEnServicio => status.toLowerCase() == 'en servicio';

  factory BusModel.fromDbMap(Map<String, dynamic> map) {
    return BusModel(
      id: map['id'] as String,
      number: map['number'] as String,
      model: map['model'] as String,
      capacity: map['capacity'] as int,
      operatingHours: map['operating_hours'] as String,
      currentLocation: map['current_location'] as String,
      phoneNumber: map['phone_number'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'number': number,
      'model': model,
      'capacity': capacity,
      'operating_hours': operatingHours,
      'current_location': currentLocation,
      'phone_number': phoneNumber,
      'status': status,
    };
  }
}
