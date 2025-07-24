
class MockProjectBookingData {
  static final MockProjectBookingData _instance = MockProjectBookingData._internal();
  factory MockProjectBookingData() => _instance;
  MockProjectBookingData._internal();

  final List<MockBooking> _bookings = [];
  final List<DateTime> _bookedDates = [];

  List<MockBooking> get bookings => List.unmodifiable(_bookings);
  List<DateTime> get bookedDates => List.unmodifiable(_bookedDates);

  void addBooking(MockBooking booking) {
    _bookings.add(booking);
    _bookedDates.add(booking.date);
  }

  void removeBooking(MockBooking booking) {
    _bookings.removeWhere((b) => b.id == booking.id);
    _bookedDates.removeWhere((d) => d == booking.date);
  }

  void removeDate(DateTime date) {
    _bookedDates.removeWhere((d) => d == date);
    _bookings.removeWhere((b) => b.date == date);
  }

  bool isDateBooked(DateTime date) {
    return _bookedDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
  }

  void clear() {
    _bookings.clear();
    _bookedDates.clear();
  }
}

class MockBooking {
  final String id;
  final String clientName;
  final String clientContact;
  final DateTime date;
  final String location;
  final String size;
  final double transportCost;
  final String status; // e.g. 'booked', 'cancelled', 'completed'

  MockBooking({
    required this.id,
    required this.clientName,
    required this.clientContact,
    required this.date,
    required this.location,
    required this.size,
    required this.transportCost,
    required this.status,
  });
} 