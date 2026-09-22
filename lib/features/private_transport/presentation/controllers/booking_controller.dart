import 'package:flutter/foundation.dart';

import 'package:buss_app/core/services/quote_service.dart';

import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/usecases/booking_usecases.dart';

class BookingController extends ChangeNotifier {
  BookingController({
    required BookingRepository repository,
    required QuoteService quoteService,
  })  : _getBookings = GetBookings(repository),
        _createBooking = CreateBooking(
          repository: repository,
          quoteService: quoteService,
        );

  final GetBookings _getBookings;
  final CreateBooking _createBooking;

  List<Booking> _bookings = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _bookings = await _getBookings();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking?> submit({
    required String pickup,
    required String dropoff,
    required String date,
    required String time,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();
    try {
      final booking = await _createBooking(
        pickup: pickup,
        dropoff: dropoff,
        date: date,
        time: time,
      );
      await load();
      return booking;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
