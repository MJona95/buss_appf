class BookingModel {
  final String id;
  final String pickupLocation;
  final String dropoffLocation;
  final String departureDate;
  final String pickupTime;
  final String status;

  BookingModel({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.departureDate,
    required this.pickupTime,
    required this.status,
  });

  factory BookingModel.fromDbMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      pickupLocation: map['pickup_location'] as String,
      dropoffLocation: map['dropoff_location'] as String,
      departureDate: map['departure_date'] as String,
      pickupTime: map['pickup_time'] as String,
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'departure_date': departureDate,
      'pickup_time': pickupTime,
      'status': status,
    };
  }
}
