import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum BookingStatus { pending, confirmed, inProgress, completed, cancelled }

class Booking {
  final String? id;
  final String serviceName;
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final DateTime date;
  final BookingStatus status;
  final double price;
  final String location;
  final String notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Booking({
    this.id,
    required this.serviceName,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.date,
    required this.status,
    required this.price,
    required this.location,
    required this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Firestore document
  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Booking(
      id: doc.id,
      serviceName: data['serviceName'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'date': Timestamp.fromDate(date),
      'status': status.name,
      'price': price,
      'location': location,
      'notes': notes,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Booking copyWith({
    String? id,
    String? serviceName,
    String? clientName,
    String? clientEmail,
    String? clientPhone,
    DateTime? date,
    BookingStatus? status,
    double? price,
    String? location,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      clientEmail: clientEmail ?? this.clientEmail,
      clientPhone: clientPhone ?? this.clientPhone,
      date: date ?? this.date,
      status: status ?? this.status,
      price: price ?? this.price,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get status color
  Color get statusColor {
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

  // Get status text
  String get statusText {
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
}