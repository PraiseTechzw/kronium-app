import 'package:cloud_firestore/cloud_firestore.dart';

class Project {
  final String id;
  final String title;
  final String description;
  final String location;
  final String size; // e.g. "10 acres", "500 sqm"
  final List<String> mediaUrls; // Appwrite media URLs
  final List<BookedDate> bookedDates;
  final List<String> features;
  final bool approved;
  final double progress;
  final DateTime? date; // <-- Add this line
  final String? category;
  final double? transportCost;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.size,
    required this.mediaUrls,
    required this.bookedDates,
    this.features = const [],
    this.approved = false,
    this.progress = 0.0,
    this.date, // <-- Add this line
    this.category,
    this.transportCost,
  });

  // Firestore serialization
  factory Project.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Project(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      location: data['location'] ?? '',
      size: data['size'] ?? '',
      mediaUrls: List<String>.from(data['mediaUrls'] ?? []),
      bookedDates: (data['bookedDates'] as List<dynamic>? ?? [])
          .map((e) => BookedDate.fromMap(e))
          .toList(),
      features: List<String>.from(data['features'] ?? []),
      approved: data['approved'] ?? false,
      progress: (data['progress'] is int)
        ? (data['progress'] as int).toDouble()
        : (data['progress'] ?? 0.0),
      date: data['date'] != null ? (data['date'] as Timestamp).toDate() : null, // <-- Add this line
      category: data['category'],
      transportCost: (data['transportCost'] is int)
        ? (data['transportCost'] as int).toDouble()
        : (data['transportCost'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'location': location,
    'size': size,
    'mediaUrls': mediaUrls,
    'bookedDates': bookedDates.map((e) => e.toMap()).toList(),
    'features': features,
    'approved': approved,
    'progress': progress,
    'date': date != null ? Timestamp.fromDate(date!) : null, // <-- Add this line
    'category': category,
    'transportCost': transportCost,
  };
}

class BookedDate {
  final DateTime date;
  final String clientId;
  final String status; // booked, cancelled, completed

  BookedDate({
    required this.date,
    required this.clientId,
    required this.status,
  });

  factory BookedDate.fromMap(Map<String, dynamic> map) => BookedDate(
    date: (map['date'] as Timestamp).toDate(),
    clientId: map['clientId'] ?? '',
    status: map['status'] ?? 'booked',
  );

  Map<String, dynamic> toMap() => {
    'date': Timestamp.fromDate(date),
    'clientId': clientId,
    'status': status,
  };
}