import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/chat_model.dart';
import 'package:kronium/core/appwrite_client.dart';

import 'dart:io';

import 'package:kronium/models/service_model.dart';

class FirebaseService extends GetxController {
  static FirebaseService get instance => Get.find();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Services Collection
  CollectionReference get servicesCollection => _firestore.collection('services');
  
  // Bookings Collection
  CollectionReference get bookingsCollection => _firestore.collection('bookings');
  
  // Admins Collection
  CollectionReference get adminsCollection => _firestore.collection('admins');
  
  // Users Collection
  CollectionReference get usersCollection => _firestore.collection('users');
  
  // Chat Collections
  CollectionReference get chatRoomsCollection => _firestore.collection('chat_rooms');
  CollectionReference get chatMessagesCollection => _firestore.collection('chat_messages');
  
  // Get all services
  Stream<List<Service>> getServices() {
    return servicesCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Service.fromFirestore(doc);
      }).toList();
    });
  }
  
  // Get service by ID
  Future<Service?> getServiceById(String id) async {
    final doc = await servicesCollection.doc(id).get();
    if (doc.exists) {
      return Service.fromFirestore(doc);
    }
    return null;
  }
  
  // Add new service (Admin only)
  Future<void> addService(Service service) async {
    await servicesCollection.add({
      'title': service.title,
      'category': service.category,
      'description': service.description,
      'features': service.features,
      'imageUrl': service.imageUrl,
      'videoUrl': service.videoUrl,
      'price': service.price,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Update service (Admin only)
  Future<void> updateService(String id, Map<String, dynamic> data) async {
    await servicesCollection.doc(id).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Delete service (Admin only)
  Future<void> deleteService(String id) async {
    await servicesCollection.doc(id).delete();
  }
  
  // Get all bookings
  Stream<List<Booking>> getBookings() {
    return bookingsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Booking.fromFirestore(doc);
      }).toList();
    });
  }
  
  // Add new booking
  Future<void> addBooking(Booking booking) async {
    await bookingsCollection.add({
      'serviceName': booking.serviceName,
      'clientName': booking.clientName,
      'clientEmail': booking.clientEmail,
      'clientPhone': booking.clientPhone,
      'date': booking.date,
      'status': booking.status.name,
      'price': booking.price,
      'location': booking.location,
      'notes': booking.notes,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete booking by document ID
  Future<void> deleteBooking(String bookingId) async {
    await bookingsCollection.doc(bookingId).delete();
  }
  
  // Update booking status (Admin only)
  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    await bookingsCollection.doc(id).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Upload image to Appwrite Storage using helper
  Future<String> uploadImage(File file, String path) async {
    try {
      // Use AppwriteService helper for upload
      final fileId = await AppwriteService.uploadFile(
        bucketId: 'images',
        path: file.path,
        bytes: await file.readAsBytes(),
        fileName: file.path.split('/').last,
      );
      if (fileId == null) throw Exception('Upload failed');
      return 'https://cloud.appwrite.io/v1/storage/buckets/images/files/$fileId/view?project=6867ce2e001b592626ae';
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Upload video to Appwrite Storage using helper
  Future<String> uploadVideo(File file, String path) async {
    try {
      // Use AppwriteService helper for upload
      final fileId = await AppwriteService.uploadFile(
        bucketId: 'videos',
        path: file.path,
        bytes: await file.readAsBytes(),
        fileName: file.path.split('/').last,
      );
      if (fileId == null) throw Exception('Upload failed');
      return 'https://cloud.appwrite.io/v1/storage/buckets/videos/files/$fileId/view?project=6867ce2e001b592626ae';
    } catch (e) {
      throw Exception('Failed to upload video: $e');
    }
  }
  
  // Get admin statistics
  Future<Map<String, dynamic>> getAdminStats() async {
    final servicesSnapshot = await servicesCollection.count().get();
    final bookingsSnapshot = await bookingsCollection.count().get();
    final pendingBookingsSnapshot = await bookingsCollection
        .where('status', isEqualTo: BookingStatus.pending.name)
        .count()
        .get();
    
    return {
      'totalServices': servicesSnapshot.count,
      'totalBookings': bookingsSnapshot.count,
      'pendingBookings': pendingBookingsSnapshot.count,
    };
  }
  
  // Add admin to Firestore
  Future<void> addAdminToFirestore(String uid, String name, String email, String companyName) async {
    await adminsCollection.doc(uid).set({
      'name': name,
      'email': email,
      'companyName': companyName,
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Chat Methods
  // Get or create chat room for customer
  Future<String> getOrCreateChatRoom(String customerId, String customerName, String customerEmail) async {
    // Check if chat room already exists
    final existingRooms = await chatRoomsCollection
        .where('customerId', isEqualTo: customerId)
        .where('isActive', isEqualTo: true)
        .get();
    
    if (existingRooms.docs.isNotEmpty) {
      return existingRooms.docs.first.id;
    }
    
    // Create new chat room
    final chatRoom = ChatRoom(
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      createdAt: DateTime.now(),
    );
    
    final docRef = await chatRoomsCollection.add(chatRoom.toFirestore());
    return docRef.id;
  }
  
  // Send message
  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    await chatMessagesCollection.add(message.toFirestore());
    
    // Update last message time in chat room
    await chatRoomsCollection.doc(chatRoomId).update({
      'lastMessageAt': FieldValue.serverTimestamp(),
    });
  }
  
  // Get messages for a chat room
  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    return chatMessagesCollection
        .where('chatRoomId', isEqualTo: chatRoomId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatMessage.fromFirestore(doc);
      }).toList();
    });
  }
  
  // Get all chat rooms (for admin)
  Stream<List<ChatRoom>> getChatRooms() {
    return chatRoomsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ChatRoom.fromFirestore(doc);
      }).toList();
    });
  }
  
  // Get chat room by customer ID
  Future<ChatRoom?> getChatRoomByCustomerId(String customerId) async {
    final doc = await chatRoomsCollection
        .where('customerId', isEqualTo: customerId)
        .where('isActive', isEqualTo: true)
        .get();
    
    if (doc.docs.isNotEmpty) {
      return ChatRoom.fromFirestore(doc.docs.first);
    }
    return null;
  }
} 