import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kronium/core/app_theme.dart';
import 'mock_project_booking_data.dart';

class BookingsManagementPage extends StatefulWidget {
  const BookingsManagementPage({super.key});

  @override
  State<BookingsManagementPage> createState() => _BookingsManagementPageState();
}

class _BookingsManagementPageState extends State<BookingsManagementPage> {
  final List<Booking> _bookings = [];
  final List<Booking> _filteredBookings = [];
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _selectedSort = 'Newest';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All Projects',
    'Greenhouses',
    'Steel Structures',
    'Solar Systems',
    'Construction',
    'Logistics',
    'IoT & Automation',
    'Upcoming',
    'Completed',
    'Cancelled',
  ];
  final List<String> _sortOptions = ['Newest', 'Oldest', 'Price: High to Low', 'Price: Low to High'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    setState(() {
      _bookings.clear();
      _bookings.addAll(MockProjectBookingData().bookings as Iterable<Booking>);
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    // Apply status and category filter
    _filteredBookings.clear();
    _filteredBookings.addAll(_bookings.where((booking) {
      if (_selectedFilter == 'All Projects') return true;
      if (_selectedFilter == 'Upcoming') return booking.status == BookingStatus.upcoming;
      if (_selectedFilter == 'Completed') return booking.status == BookingStatus.completed;
      if (_selectedFilter == 'Cancelled') return booking.status == BookingStatus.cancelled;
      // Category filter (by serviceName)
      if (_filterOptions.contains(_selectedFilter)) {
        return booking.serviceName.toLowerCase().contains(_selectedFilter.toLowerCase());
      }
      return true;
    }));

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      _filteredBookings.retainWhere((booking) =>
          booking.clientName.toLowerCase().contains(query) ||
          booking.serviceName.toLowerCase().contains(query) ||
          booking.id.toLowerCase().contains(query));
    }

    // Apply sorting
    _filteredBookings.sort((a, b) {
      switch (_selectedSort) {
        case 'Oldest':
          return a.date.compareTo(b.date);
        case 'Price: High to Low':
          return b.price.compareTo(a.price);
        case 'Price: Low to High':
          return a.price.compareTo(b.price);
        case 'Newest':
        default:
          return b.date.compareTo(a.date);
      }
    });

    setState(() {});
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return Colors.orange;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  void _showBookingDetails(Booking booking) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Booking #${booking.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text('Service'),
              subtitle: Text(booking.serviceName),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Client'),
              subtitle: Text(booking.clientName),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date'),
              subtitle: Text(DateFormat.yMMMd().format(booking.date)),
              trailing: booking.status == BookingStatus.upcoming
                  ? IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
                      onPressed: () => _showRescheduleDatePicker(booking),
                    )
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Price'),
              subtitle: Text('\$${booking.price}'),
            ),
            const SizedBox(height: 20),
            if (booking.status == BookingStatus.upcoming)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(booking, BookingStatus.cancelled),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(booking, BookingStatus.completed),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                      ),
                      child: const Text('Complete'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _removeBooking(booking),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Remove'),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text('Close'),
              ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(Booking booking, BookingStatus newStatus) {
    final index = _bookings.indexWhere((b) => b.id == booking.id);
    if (index != -1) {
      setState(() {
        _bookings[index] = booking.copyWith(status: newStatus);
        _applyFilters();
      });
      Get.back();
      Get.snackbar(
        'Status Updated',
        'Booking #${booking.id} updated',
        backgroundColor: AppTheme.primaryColor,
      );
    }
  }

  void _removeBooking(Booking booking) {
    MockProjectBookingData().removeBooking(
      MockBooking(
        id: booking.id,
        clientName: booking.clientName,
        clientContact: booking.contact,
        date: booking.date,
        location: booking.location,
        size: '',
        transportCost: 0,
        status: booking.status.toString().split('.').last,
      ),
    );
    _loadBookings();
    Get.snackbar('Booking Removed', 'The booking has been removed and the date is now available.', backgroundColor: AppTheme.primaryColor);
  }

  // Simulated taken dates for demo
  final List<DateTime> _takenDates = [
    DateTime(2024, 6, 10),
    DateTime(2024, 6, 15),
    DateTime(2024, 6, 20),
  ];

  void _showRescheduleDatePicker(Booking booking) async {
    DateTime now = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: booking.date.isAfter(now) ? booking.date : now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.surfaceLight,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      if (_takenDates.any((d) => d.year == picked.year && d.month == picked.month && d.day == picked.day)) {
        // Date is taken, propose next available
        DateTime nextAvailable = picked.add(const Duration(days: 1));
        while (_takenDates.any((d) => d.year == nextAvailable.year && d.month == nextAvailable.month && d.day == nextAvailable.day)) {
          nextAvailable = nextAvailable.add(const Duration(days: 1));
        }
        Get.snackbar(
          'Date Unavailable',
          'The selected date is already booked. Next available: ${nextAvailable.toLocal().toString().split(' ')[0]}',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        setState(() {
          final index = _bookings.indexWhere((b) => b.id == booking.id);
          if (index != -1) {
            _bookings[index] = booking.copyWith(date: picked);
            _applyFilters();
          }
        });
        Get.snackbar(
          'Date Rescheduled',
          'Booking rescheduled to: ${picked.toLocal().toString().split(' ')[0]}',
          backgroundColor: AppTheme.primaryColor,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Bookings Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search bookings...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    ),
                  ),
                  onChanged: (value) => _applyFilters(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedFilter,
                        items: _filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedFilter = value!);
                          _applyFilters();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Filter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedSort,
                        items: _sortOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedSort = value!);
                          _applyFilters();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Sort',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bookings List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredBookings.isEmpty
                    ? const Center(child: Text('No bookings found'))
                    : ListView.builder(
                        itemCount: _filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _filteredBookings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text(booking.serviceName),
                              subtitle: Text(booking.clientName),
                              trailing: Chip(
                                label: Text(
                                  booking.status.toString().split('.').last,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _getStatusColor(booking.status),
                              ),
                              onTap: () => _showBookingDetails(booking),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

enum BookingStatus { upcoming, completed, cancelled }

class Booking {
  final String id;
  final String serviceName;
  final String clientName;
  final DateTime date;
  final BookingStatus status;
  final double price;
  final String location;
  final String contact;

  Booking({
    required this.id,
    required this.serviceName,
    required this.clientName,
    required this.date,
    required this.status,
    required this.price,
    required this.location,
    required this.contact,
  });

  Booking copyWith({
    String? id,
    String? serviceName,
    String? clientName,
    DateTime? date,
    BookingStatus? status,
    double? price,
    String? location,
    String? contact,
  }) {
    return Booking(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      date: date ?? this.date,
      status: status ?? this.status,
      price: price ?? this.price,
      location: location ?? this.location,
      contact: contact ?? this.contact,
    );
  }
}