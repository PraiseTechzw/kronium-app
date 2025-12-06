import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kronium/core/supabase_config.dart';
import 'package:kronium/models/user_model.dart' as models;
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/project_model.dart';
import 'package:kronium/models/chat_model.dart';
import 'dart:async';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  // Initialize Supabase
  Future<void> initialize() async {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // ==================== USERS ====================
  
  Stream<List<models.User>> getUsers() {
    return client
        .from('users')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => models.User.fromMap(json, id: json['id'])).toList());
  }

  Future<models.User?> getUserById(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (response == null) {
        return null;
      }
      
      return models.User.fromMap(response, id: response['id']);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> addUser(models.User user) async {
    try {
      final userData = user.toMap();
      // Include the UUID id from Supabase Auth if provided
      if (user.id != null && user.id!.isNotEmpty) {
        userData['id'] = user.id;
      }
      // Clean up the data - remove null values except for optional fields
      userData.removeWhere((key, value) => value == null && key != 'id' && key != 'simpleId' && key != 'profileImage' && key != 'address');
      
      // Ensure createdAt and updatedAt are ISO strings if present
      if (userData['createdAt'] != null && userData['createdAt'] is DateTime) {
        userData['createdAt'] = (userData['createdAt'] as DateTime).toIso8601String();
      }
      if (userData['updatedAt'] != null && userData['updatedAt'] is DateTime) {
        userData['updatedAt'] = (userData['updatedAt'] as DateTime).toIso8601String();
      }
      
      await client.from('users').insert(userData);
    } catch (e) {
      print('Error adding user to database: $e');
      print('User data: ${user.toMap()}');
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await client
        .from('users')
        .update(data)
        .eq('id', userId);
  }

  Future<void> deleteUser(String userId) async {
    await client
        .from('users')
        .delete()
        .eq('id', userId);
  }

  // ==================== SERVICES ====================
  
  Stream<List<Service>> getServices() {
    return client
        .from('services')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => Service.fromMap(json, id: json['id'])).toList());
  }

  Future<void> addService(Service service) async {
    final data = service.toMap();
    await client.from('services').insert(data);
  }

  Future<void> updateService(String serviceId, Map<String, dynamic> data) async {
    await client
        .from('services')
        .update(data)
        .eq('id', serviceId);
  }

  Future<void> deleteService(String serviceId) async {
    await client
        .from('services')
        .delete()
        .eq('id', serviceId);
  }

  // ==================== BOOKINGS ====================
  
  Stream<List<Booking>> getBookings() {
    return client
        .from('bookings')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => Booking.fromMap(json, id: json['id'])).toList());
  }

  Future<void> addBooking(Booking booking) async {
    final data = booking.toMap();
    await client.from('bookings').insert(data);
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    await client
        .from('bookings')
        .update({'status': status})
        .eq('id', bookingId);
  }

  Future<void> deleteBooking(String bookingId) async {
    await client
        .from('bookings')
        .delete()
        .eq('id', bookingId);
  }

  // ==================== PROJECTS ====================
  
  Stream<List<Project>> getProjects() {
    return client
        .from('projects')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => Project.fromMap(json, id: json['id'])).toList());
  }

  Future<void> addProject(Project project) async {
    final data = project.toMap();
    await client.from('projects').insert(data);
  }

  Future<void> updateProject(String projectId, Map<String, dynamic> data) async {
    await client
        .from('projects')
        .update(data)
        .eq('id', projectId);
  }

  Future<void> deleteProject(String projectId) async {
    await client
        .from('projects')
        .delete()
        .eq('id', projectId);
  }

  Future<void> updateProjectProgress(String projectId, double progress) async {
    await client
        .from('projects')
        .update({'progress': progress})
        .eq('id', projectId);
  }

  Future<void> addProjectUpdate(String projectId, Map<String, dynamic> update) async {
    final project = await client
        .from('projects')
        .select()
        .eq('id', projectId)
        .single();
    
    final updates = List<Map<String, dynamic>>.from(project['updates'] ?? []);
    updates.add(update);
    
    await client
        .from('projects')
        .update({'updates': updates})
        .eq('id', projectId);
  }

  // ==================== CHAT ====================
  
  Stream<List<ChatRoom>> getChatRooms() {
    return client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((json) => ChatRoom.fromMap(json, id: json['id'])).toList());
  }

  Future<String> getOrCreateChatRoom(String userId, String userName, [String? userEmail]) async {
    try {
      // Try to find existing chat room
      final existing = await client
          .from('chat_rooms')
          .select()
          .eq('customer_id', userId)
          .maybeSingle();
      
      if (existing != null) {
        return existing['id'];
      }
      
      // Create new chat room
      final newRoom = {
        'customer_id': userId,
        'customer_name': userName,
        if (userEmail != null) 'customer_email': userEmail,
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final response = await client
          .from('chat_rooms')
          .insert(newRoom)
          .select()
          .single();
      
      return response['id'];
    } catch (e) {
      print('Error getting/creating chat room: $e');
      rethrow;
    }
  }

  Stream<List<ChatMessage>> getChatMessages(String chatRoomId) {
    final controller = StreamController<List<ChatMessage>>();
    
    // Initial fetch
    _fetchChatMessages(chatRoomId).then((messages) {
      controller.add(messages);
    });
    
    // Set up periodic polling (every 2 seconds for real-time feel)
    Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (controller.isClosed) {
        timer.cancel();
        return;
      }
      try {
        final messages = await _fetchChatMessages(chatRoomId);
        controller.add(messages);
      } catch (e) {
        print('Error fetching chat messages: $e');
      }
    });
    
    return controller.stream;
  }
  
  Future<List<ChatMessage>> _fetchChatMessages(String chatRoomId) async {
    final data = await client
        .from('chat_messages')
        .select()
        .eq('chat_room_id', chatRoomId)
        .order('timestamp', ascending: true);
    
    return data.map((json) => ChatMessage.fromMap(json, id: json['id'])).toList();
  }

  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    final data = message.toMap();
    data['chat_room_id'] = chatRoomId;
    
    await client.from('chat_messages').insert(data);
    
    // Update chat room's last message timestamp
    await client
        .from('chat_rooms')
        .update({'last_message_at': DateTime.now().toIso8601String()})
        .eq('id', chatRoomId);
  }

  // ==================== ADMIN ====================
  
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final usersResponse = await client
          .from('users')
          .select('id')
          .count();
      final usersCount = usersResponse.count;
      
      final servicesResponse = await client
          .from('services')
          .select('id')
          .count();
      final servicesCount = servicesResponse.count;
      
      final bookingsResponse = await client
          .from('bookings')
          .select('id')
          .count();
      final bookingsCount = bookingsResponse.count;
      
      final projectsResponse = await client
          .from('projects')
          .select('id')
          .count();
      final projectsCount = projectsResponse.count;
      
      final chatRoomsResponse = await client
          .from('chat_rooms')
          .select('id')
          .count();
      final chatRoomsCount = chatRoomsResponse.count;
      
      return {
        'totalUsers': usersCount,
        'totalServices': servicesCount,
        'totalBookings': bookingsCount,
        'totalProjects': projectsCount,
        'totalChatRooms': chatRoomsCount,
      };
    } catch (e) {
      print('Error getting admin stats: $e');
      return {
        'totalUsers': 0,
        'totalServices': 0,
        'totalBookings': 0,
        'totalProjects': 0,
        'totalChatRooms': 0,
      };
    }
  }

  Future<void> addAdmin(String userId, Map<String, dynamic> adminData) async {
    await client
        .from('admins')
        .insert({
          'user_id': userId,
          ...adminData,
        });
  }

  // ==================== FILE UPLOADS ====================
  
  Future<String> uploadImage(File file, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folder/$fileName';
      
      await client.storage.from('public').upload(filePath, file);
      
      final publicUrl = client.storage.from('public').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<String> uploadVideo(File file, String folder) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folder/$fileName';
      
      await client.storage.from('public').upload(filePath, file);
      
      final publicUrl = client.storage.from('public').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      print('Error uploading video: $e');
      rethrow;
    }
  }

  // Helper method for project bookings (for backward compatibility)
  Future<void> addProjectBooking(Map<String, dynamic> bookingData) async {
    // Convert the booking data to a Booking model and save
    final booking = Booking.fromMap(bookingData);
    await addBooking(booking);
  }
}

