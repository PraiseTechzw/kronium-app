import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:animate_do/animate_do.dart';

import 'package:intl/intl.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/widgets/admin_scaffold.dart';

class AdminBookingsPage extends StatelessWidget {
  const AdminBookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = Get.find<FirebaseService>();

    return AdminScaffold(
      title: 'Manage Bookings',
      body: StreamBuilder<List<Booking>>(
        stream: firebaseService.getBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.warning_2, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading bookings',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.calendar, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bookings will appear here when customers make them',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return FadeInUp(
                delay: Duration(milliseconds: index * 100),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ExpansionTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(booking.status),
                        color: _getStatusColor(booking.status),
                        size: 20,
                      ),
                    ),
                    title: Text(
                      booking.clientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          booking.serviceName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStatusText(booking.status),
                            style: TextStyle(
                              color: _getStatusColor(booking.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Email', booking.clientEmail),
                            _buildInfoRow('Phone', booking.clientPhone),
                            _buildInfoRow('Date', DateFormat('MMM dd, yyyy').format(booking.date)),
                            _buildInfoRow('Price', '\$${booking.price}'),
                            _buildInfoRow('Location', booking.location),
                            if (booking.notes.isNotEmpty)
                              _buildInfoRow('Notes', booking.notes),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateBookingStatus(booking, BookingStatus.confirmed),
                                    icon: const Icon(Iconsax.tick_circle, size: 16),
                                    label: const Text('Confirm'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.green,
                                      side: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateBookingStatus(booking, BookingStatus.cancelled),
                                    icon: const Icon(Iconsax.close_circle, size: 16),
                                    label: const Text('Cancel'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _updateBookingStatus(booking, BookingStatus.completed),
                                    icon: const Icon(Iconsax.verify, size: 16),
                                    label: const Text('Complete'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.blue,
                                      side: const BorderSide(color: Colors.blue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.inProgress:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Iconsax.clock;
      case BookingStatus.confirmed:
        return Iconsax.tick_circle;
      case BookingStatus.inProgress:
        return Iconsax.clock;
      case BookingStatus.completed:
        return Iconsax.tick_square;
      case BookingStatus.cancelled:
        return Iconsax.close_circle;
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.inProgress:
        return 'In Progress';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _updateBookingStatus(Booking booking, BookingStatus newStatus) {
    final firebaseService = Get.find<FirebaseService>();
    firebaseService.updateBookingStatus(booking.id!, newStatus);

    Get.snackbar(
      'Status Updated',
      'Booking status updated to ${_getStatusText(newStatus)}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
} 