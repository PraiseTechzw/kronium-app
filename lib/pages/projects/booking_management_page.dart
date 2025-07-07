import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

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

  final List<String> _filterOptions = ['All', 'Upcoming', 'Completed', 'Cancelled'];
  final List<String> _sortOptions = ['Newest', 'Oldest', 'Price: High to Low', 'Price: Low to High'];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      setState(() => _isLoading = true);
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Replace with your actual data loading
      _bookings.addAll([
        Booking(
          id: 'BKG001',
          serviceName: 'Solar Panel Installation',
          clientName: 'John Smith',
          date: DateTime.now().add(const Duration(days: 2)),
          status: BookingStatus.upcoming,
          price: 8500,
          location: '123 Green St',
          contact: '555-123-4567',
        ),
        Booking(
          id: 'BKG002',
          serviceName: 'Greenhouse Construction',
          clientName: 'Sarah Johnson',
          date: DateTime.now().subtract(const Duration(days: 1)),
          status: BookingStatus.completed,
          price: 3500,
          location: '456 Farm Rd',
          contact: '555-987-6543',
        ),
      ]);
      
      _applyFilters();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load bookings',
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    // Apply status filter
    _filteredBookings.clear();
    _filteredBookings.addAll(_bookings.where((booking) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Upcoming') return booking.status == BookingStatus.upcoming;
      if (_selectedFilter == 'Completed') return booking.status == BookingStatus.completed;
      if (_selectedFilter == 'Cancelled') return booking.status == BookingStatus.cancelled;
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
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('Complete'),
                    ),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
        backgroundColor: Colors.green,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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