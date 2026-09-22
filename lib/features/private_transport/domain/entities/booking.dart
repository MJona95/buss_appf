class Booking {
  final String id;
  final String pickupLocation;
  final String dropoffLocation;
  final String departureDate;
  final String pickupTime;
  final String status;
  final double quoteAmount;
  final String syncStatus;

  const Booking({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.departureDate,
    required this.pickupTime,
    required this.status,
    required this.quoteAmount,
    required this.syncStatus,
  });

  bool get isPendingSync => syncStatus == 'pending';

  String get shortId => id.length <= 7 ? id : id.substring(0, 7);

  Booking copyWith({
    String? id,
    String? pickupLocation,
    String? dropoffLocation,
    String? departureDate,
    String? pickupTime,
    String? status,
    double? quoteAmount,
    String? syncStatus,
  }) {
    return Booking(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      departureDate: departureDate ?? this.departureDate,
      pickupTime: pickupTime ?? this.pickupTime,
      status: status ?? this.status,
      quoteAmount: quoteAmount ?? this.quoteAmount,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
