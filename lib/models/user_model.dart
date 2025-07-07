import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String? profileImage;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final List<String> favoriteServices;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profileImage,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.favoriteServices = const [],
  });

  // Create from Firestore document
  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      address: data['address'],
      createdAt: data['createdAt']?.toDate(),
      updatedAt: data['updatedAt']?.toDate(),
      isActive: data['isActive'] ?? true,
      favoriteServices: List<String>.from(data['favoriteServices'] ?? []),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'address': address,
      'isActive': isActive,
      'favoriteServices': favoriteServices,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? address,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    List<String>? favoriteServices,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      favoriteServices: favoriteServices ?? this.favoriteServices,
    );
  }
} 