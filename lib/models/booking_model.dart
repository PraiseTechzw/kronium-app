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
  final String? priority;
  final bool isUrgent;
  final String? emergencyContact;
  final String? contactPerson;
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
    this.priority,
    this.isUrgent = false,
    this.emergencyContact,
    this.contactPerson,
    this.createdAt,
    this.updatedAt,
  });

  // Create from Map
  factory Booking.fromMap(Map<String, dynamic> data, {String? id}) {
    return Booking(
      id: id ?? data['id'],
      serviceName: data['serviceName'] ?? '',
      clientName: data['clientName'] ?? '',
      clientEmail: data['clientEmail'] ?? '',
      clientPhone: data['clientPhone'] ?? '',
      date:
          data['date'] is DateTime
              ? data['date']
              : (data['date'] != null
                  ? DateTime.parse(data['date'].toString())
                  : DateTime.now()),
      status: BookingStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BookingStatus.pending,
      ),
      price: (data['price'] ?? 0).toDouble(),
      location: data['location'] ?? '',
      notes: data['notes'] ?? '',
      priority: data['priority'],
      isUrgent: data['is_urgent'] ?? false,
      emergencyContact: data['emergency_contact'],
      contactPerson: data['contact_person'],
      createdAt:
          data['createdAt'] is DateTime
              ? data['createdAt']
              : (data['createdAt'] != null
                  ? DateTime.parse(data['createdAt'].toString())
                  : null),
      updatedAt:
          data['updatedAt'] is DateTime
              ? data['updatedAt']
              : (data['updatedAt'] != null
                  ? DateTime.parse(data['updatedAt'].toString())
                  : null),
    );
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'serviceName': serviceName,
      'clientName': clientName,
      'clientEmail': clientEmail,
      'clientPhone': clientPhone,
      'date': date.toIso8601String(),
      'status': status.name,
      'price': price,
      'location': location,
      'notes': notes,
      'priority': priority,
      'is_urgent': isUrgent,
      'emergency_contact': emergencyContact,
      'contact_person': contactPerson,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
    String? priority,
    bool? isUrgent,
    String? emergencyContact,
    String? contactPerson,
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
      priority: priority ?? this.priority,
      isUrgent: isUrgent ?? this.isUrgent,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      contactPerson: contactPerson ?? this.contactPerson,
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
