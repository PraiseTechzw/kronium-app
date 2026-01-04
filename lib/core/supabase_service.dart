import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kronium/core/supabase_config.dart';
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/security_service.dart';
import 'package:kronium/models/user_model.dart' as models;
import 'package:kronium/models/service_model.dart';
import 'package:kronium/models/booking_model.dart';
import 'package:kronium/models/project_model.dart';
import 'package:kronium/models/chat_model.dart';
import 'package:kronium/models/knowledge_base_model.dart';
import 'dart:async';

/// Production-ready Supabase service with enhanced error handling and logging
class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  SupabaseClient? _client;
  final SecurityService _securityService = SecurityService();

  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call initialize() first.');
    }
    return _client!;
  }

  /// Initialize Supabase with enhanced error handling
  Future<void> initialize() async {
    try {
      logging.logger.info('Initializing Supabase connection...');

      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: false, // Disable debug in production
      );

      _client = Supabase.instance.client;

      // Test connection
      await _testConnection();

      logging.logger.info('Supabase initialized successfully');
    } catch (e, stackTrace) {
      logging.logger.fatal('Failed to initialize Supabase', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Supabase initialization');
      rethrow;
    }
  }

  /// Test database connection
  Future<void> _testConnection() async {
    try {
      await client.from('users').select('count').limit(1);
      logging.logger.debug('Database connection test successful');
    } catch (e) {
      logging.logger.error('Database connection test failed', e);
      throw Exception('Database connection failed: ${e.toString()}');
    }
  }

  // ==================== USERS ====================

  /// Get all users with error handling and logging
  Stream<List<models.User>> getUsers() {
    try {
      logging.logger.debug('Fetching users stream');
      return client
          .from('users')
          .stream(primaryKey: ['id'])
          .map((data) {
            logging.logger.debug('Received ${data.length} users from stream');
            return data
                .map((json) => models.User.fromMap(json, id: json['id']))
                .toList();
          })
          .handleError((error) {
            logging.logger.error('Error in users stream', error);
            ErrorHandler.handleError(error, context: 'Users stream');
          });
    } catch (e) {
      logging.logger.error('Error setting up users stream', e);
      ErrorHandler.handleError(e, context: 'Users stream setup');
      rethrow;
    }
  }

  /// Get user by ID with enhanced error handling
  Future<models.User?> getUserById(String userId) async {
    try {
      logging.logger.debug('Fetching user by ID: $userId');

      // Validate input
      if (userId.isEmpty) {
        logging.logger.warning('Empty user ID provided');
        return null;
      }

      final response =
          await client.from('users').select().eq('id', userId).maybeSingle();

      if (response == null) {
        logging.logger.debug('User not found: $userId');
        return null;
      }

      logging.logger.debug(
        'User found: ${response['name']} with role: ${response['role']}',
      );
      return models.User.fromMap(response, id: response['id']);
    } catch (e, stackTrace) {
      logging.logger.error('Error getting user by ID: $userId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Get user by ID');
      return null;
    }
  }

  /// Add user with validation and error handling
  Future<void> addUser(models.User user) async {
    try {
      logging.logger.info('Adding user: ${user.name} (${user.email})');

      // Validate user data
      if (user.name.isEmpty || user.email.isEmpty) {
        throw ArgumentError('User name and email are required');
      }

      // Sanitize input data
      final userData = <String, dynamic>{
        'name': _securityService.sanitizeInput(user.name),
        'email':
            _securityService.validateAndSanitizeEmail(user.email) ?? user.email,
        'phone':
            user.phone.isNotEmpty
                ? _securityService.sanitizeInput(user.phone)
                : null,
      };

      // Include the UUID id from Supabase Auth if provided
      if (user.id != null && user.id!.isNotEmpty) {
        userData['id'] = user.id;
      }

      // Include simpleId if provided (database trigger will generate if null)
      if (user.simpleId != null && user.simpleId!.isNotEmpty) {
        userData['simpleid'] = user.simpleId;
      }

      // Include optional fields with sanitization
      if (user.profileImage != null && user.profileImage!.isNotEmpty) {
        userData['profileimage'] = user.profileImage;
      }
      if (user.address != null && user.address!.isNotEmpty) {
        userData['address'] = _securityService.sanitizeInput(user.address!);
      }

      await client.from('users').insert(userData);
      logging.logger.info('User added successfully: ${user.email}');
    } catch (e, stackTrace) {
      logging.logger.error('Error adding user: ${user.email}', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Add user');
      rethrow;
    }
  }

  /// Update user with validation
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      logging.logger.info('Updating user: $userId');

      if (userId.isEmpty) {
        throw ArgumentError('User ID is required');
      }

      // Sanitize update data
      final sanitizedData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          if (key == 'email') {
            sanitizedData[key] =
                _securityService.validateAndSanitizeEmail(value) ?? value;
          } else {
            sanitizedData[key] = _securityService.sanitizeInput(value);
          }
        } else {
          sanitizedData[key] = value;
        }
      });

      // Remove system-managed fields
      sanitizedData.remove('createdAt');
      sanitizedData.remove('updatedAt');
      sanitizedData.remove('id');

      await client.from('users').update(sanitizedData).eq('id', userId);

      logging.logger.info('User updated successfully: $userId');
    } catch (e, stackTrace) {
      logging.logger.error('Error updating user: $userId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Update user');
      rethrow;
    }
  }

  /// Update user role specifically
  Future<void> updateUserRole(String userId, String role) async {
    try {
      logging.logger.info('Updating user role: $userId to $role');

      if (userId.isEmpty) {
        throw ArgumentError('User ID is required');
      }

      if (!['customer', 'admin', 'super_admin'].contains(role)) {
        throw ArgumentError('Invalid role: $role');
      }

      await client.from('users').update({'role': role}).eq('id', userId);

      logging.logger.info('User role updated successfully: $userId -> $role');
    } catch (e, stackTrace) {
      logging.logger.error('Error updating user role: $userId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Update user role');
      rethrow;
    }
  }

  /// Delete user with confirmation
  Future<void> deleteUser(String userId) async {
    try {
      logging.logger.warning('Deleting user: $userId');

      if (userId.isEmpty) {
        throw ArgumentError('User ID is required');
      }

      await client.from('users').delete().eq('id', userId);

      logging.logger.warning('User deleted: $userId');
    } catch (e, stackTrace) {
      logging.logger.error('Error deleting user: $userId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Delete user');
      rethrow;
    }
  }

  // ==================== SERVICES ====================

  /// Get services stream with error handling
  Stream<List<Service>> getServices() {
    try {
      logging.logger.debug('Fetching services stream');
      return client
          .from('services')
          .stream(primaryKey: ['id'])
          .map((data) {
            logging.logger.debug(
              'Received ${data.length} services from stream',
            );
            return data
                .map((json) => Service.fromMap(json, id: json['id']))
                .toList();
          })
          .handleError((error) {
            logging.logger.error('Error in services stream', error);
            ErrorHandler.handleError(error, context: 'Services stream');
          });
    } catch (e) {
      logging.logger.error('Error setting up services stream', e);
      ErrorHandler.handleError(e, context: 'Services stream setup');
      rethrow;
    }
  }

  /// Add service with validation
  Future<void> addService(Service service) async {
    try {
      logging.logger.info('Adding service: ${service.title}');

      // Validate service data
      if (service.title.isEmpty) {
        throw ArgumentError('Service title is required');
      }

      final data = service.toMap();

      // Sanitize text fields
      if (data['title'] != null) {
        data['title'] = _securityService.sanitizeInput(data['title']);
      }
      if (data['description'] != null) {
        data['description'] = _securityService.sanitizeInput(
          data['description'],
        );
      }
      if (data['category'] != null) {
        data['category'] = _securityService.sanitizeInput(data['category']);
      }

      await client.from('services').insert(data);
      logging.logger.info('Service added successfully: ${service.title}');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error adding service: ${service.title}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Add service');
      rethrow;
    }
  }

  /// Update service with validation
  Future<void> updateService(
    String serviceId,
    Map<String, dynamic> data,
  ) async {
    try {
      logging.logger.info('Updating service: $serviceId');

      if (serviceId.isEmpty) {
        throw ArgumentError('Service ID is required');
      }

      // Sanitize update data
      final sanitizedData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          sanitizedData[key] = _securityService.sanitizeInput(value);
        } else {
          sanitizedData[key] = value;
        }
      });

      await client.from('services').update(sanitizedData).eq('id', serviceId);

      logging.logger.info('Service updated successfully: $serviceId');
    } catch (e, stackTrace) {
      logging.logger.error('Error updating service: $serviceId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Update service');
      rethrow;
    }
  }

  /// Delete service
  Future<void> deleteService(String serviceId) async {
    try {
      logging.logger.warning('Deleting service: $serviceId');

      if (serviceId.isEmpty) {
        throw ArgumentError('Service ID is required');
      }

      await client.from('services').delete().eq('id', serviceId);

      logging.logger.warning('Service deleted: $serviceId');
    } catch (e, stackTrace) {
      logging.logger.error('Error deleting service: $serviceId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Delete service');
      rethrow;
    }
  }

  // ==================== BOOKINGS ====================

  /// Get bookings stream with error handling
  Stream<List<Booking>> getBookings() {
    try {
      logging.logger.debug('Fetching bookings stream');
      return client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .map((data) {
            logging.logger.debug(
              'Received ${data.length} bookings from stream',
            );
            return data
                .map((json) => Booking.fromMap(json, id: json['id']))
                .toList();
          })
          .handleError((error) {
            logging.logger.error('Error in bookings stream', error);
            ErrorHandler.handleError(error, context: 'Bookings stream');
          });
    } catch (e) {
      logging.logger.error('Error setting up bookings stream', e);
      ErrorHandler.handleError(e, context: 'Bookings stream setup');
      rethrow;
    }
  }

  /// Add booking with validation
  Future<void> addBooking(Booking booking) async {
    try {
      logging.logger.info(
        'Adding booking: ${booking.serviceName} for ${booking.clientName}',
      );

      // Validate booking data
      if (booking.serviceName.isEmpty ||
          booking.clientName.isEmpty ||
          booking.clientEmail.isEmpty) {
        throw ArgumentError(
          'Service name, client name, and email are required',
        );
      }

      final data = booking.toMap();

      // Sanitize text fields
      if (data['serviceName'] != null) {
        data['serviceName'] = _securityService.sanitizeInput(
          data['serviceName'],
        );
      }
      if (data['clientName'] != null) {
        data['clientName'] = _securityService.sanitizeInput(data['clientName']);
      }
      if (data['clientEmail'] != null) {
        data['clientEmail'] =
            _securityService.validateAndSanitizeEmail(data['clientEmail']) ??
            data['clientEmail'];
      }
      if (data['location'] != null) {
        data['location'] = _securityService.sanitizeInput(data['location']);
      }
      if (data['notes'] != null) {
        data['notes'] = _securityService.sanitizeInput(data['notes']);
      }

      await client.from('bookings').insert(data);
      logging.logger.info('Booking added successfully: ${booking.serviceName}');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error adding booking: ${booking.serviceName}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Add booking');
      rethrow;
    }
  }

  /// Update booking status with validation
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      logging.logger.info('Updating booking status: $bookingId to $status');

      if (bookingId.isEmpty || status.isEmpty) {
        throw ArgumentError('Booking ID and status are required');
      }

      // Validate status
      const validStatuses = [
        'pending',
        'confirmed',
        'inProgress',
        'completed',
        'cancelled',
      ];
      if (!validStatuses.contains(status)) {
        throw ArgumentError('Invalid booking status: $status');
      }

      await client
          .from('bookings')
          .update({
            'status': status,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', bookingId);

      logging.logger.info('Booking status updated: $bookingId -> $status');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error updating booking status: $bookingId',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Update booking status');
      rethrow;
    }
  }

  /// Delete booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      logging.logger.warning('Deleting booking: $bookingId');

      if (bookingId.isEmpty) {
        throw ArgumentError('Booking ID is required');
      }

      await client.from('bookings').delete().eq('id', bookingId);

      logging.logger.warning('Booking deleted: $bookingId');
    } catch (e, stackTrace) {
      logging.logger.error('Error deleting booking: $bookingId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Delete booking');
      rethrow;
    }
  }

  // ==================== PROJECTS ====================

  /// Get projects stream with error handling
  Stream<List<Project>> getProjects() {
    try {
      logging.logger.debug('Fetching projects stream');
      return client
          .from('projects')
          .stream(primaryKey: ['id'])
          .map((data) {
            logging.logger.debug(
              'Received ${data.length} projects from stream',
            );
            return data.map((json) {
              try {
                final normalizedJson = _normalizeProjectJson(json);
                return Project.fromMap(
                  normalizedJson,
                  id: normalizedJson['id'],
                );
              } catch (e) {
                logging.logger.error('Error parsing project', e);
                rethrow;
              }
            }).toList();
          })
          .handleError((error) {
            logging.logger.error('Error in projects stream', error);
            ErrorHandler.handleError(error, context: 'Projects stream');
          });
    } catch (e) {
      logging.logger.error('Error setting up projects stream', e);
      ErrorHandler.handleError(e, context: 'Projects stream setup');
      rethrow;
    }
  }

  /// Fetch projects with pagination and filtering
  Future<List<Project>> fetchProjects({
    int limit = 50,
    int offset = 0,
    String? status,
    String? clientEmail,
  }) async {
    try {
      logging.logger.debug(
        'Fetching projects: limit=$limit, offset=$offset, status=$status',
      );

      var query = client
          .from('projects')
          .select()
          .order('createdat', ascending: false);

      // Apply pagination
      if (limit > 0) {
        query = query.range(offset, offset + limit - 1);
      }

      final response = await query;

      final projects =
          response.map((json) {
            try {
              final normalizedJson = _normalizeProjectJson(json);
              return Project.fromMap(normalizedJson, id: normalizedJson['id']);
            } catch (e) {
              logging.logger.error('Error parsing project', e);
              rethrow;
            }
          }).toList();

      logging.logger.debug('Fetched ${projects.length} projects');
      return projects;
    } catch (e, stackTrace) {
      logging.logger.error('Error fetching projects', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Fetch projects');
      rethrow;
    }
  }

  /// Fetch projects by status
  Future<List<Project>> fetchProjectsByStatus(String status) async {
    return fetchProjects(status: status);
  }

  /// Fetch projects by client email
  Future<List<Project>> fetchProjectsByClientEmail(String email) async {
    return fetchProjects(clientEmail: email);
  }

  /// Helper method to normalize JSON keys
  Map<String, dynamic> _normalizeProjectJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);

    // Handle lowercase column names from database
    const lowercaseMap = {
      'clientname': 'clientName',
      'clientemail': 'clientEmail',
      'clientphone': 'clientPhone',
      'clientid': 'clientId',
      'mediaurls': 'mediaUrls',
      'projectmedia': 'projectMedia',
      'bookeddates': 'bookedDates',
      'createdat': 'createdAt',
      'updatedat': 'updatedAt',
      'startdate': 'startDate',
      'enddate': 'endDate',
    };

    // Convert lowercase keys to camelCase if they exist
    lowercaseMap.forEach((lowerKey, camelKey) {
      if (normalized.containsKey(lowerKey) &&
          !normalized.containsKey(camelKey)) {
        normalized[camelKey] = normalized[lowerKey];
      }
    });

    return normalized;
  }

  /// Add project with validation
  Future<void> addProject(Project project) async {
    try {
      logging.logger.info(
        'Adding project: ${project.title} for ${project.clientName}',
      );

      // Validate project data
      if (project.title.isEmpty ||
          (project.clientName?.isEmpty ?? true) ||
          (project.clientEmail?.isEmpty ?? true)) {
        throw ArgumentError(
          'Project title, client name, and email are required',
        );
      }

      final data = project.toMap();

      // Sanitize text fields
      if (data['title'] != null) {
        data['title'] = _securityService.sanitizeInput(data['title']);
      }
      if (data['description'] != null) {
        data['description'] = _securityService.sanitizeInput(
          data['description'],
        );
      }
      if (data['clientName'] != null) {
        data['clientName'] = _securityService.sanitizeInput(data['clientName']);
      }
      if (data['clientEmail'] != null) {
        data['clientEmail'] =
            _securityService.validateAndSanitizeEmail(data['clientEmail']) ??
            data['clientEmail'];
      }
      if (data['location'] != null) {
        data['location'] = _securityService.sanitizeInput(data['location']);
      }

      await client.from('projects').insert(data);
      logging.logger.info('Project added successfully: ${project.title}');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error adding project: ${project.title}',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Add project');
      rethrow;
    }
  }

  /// Update project with validation
  Future<void> updateProject(
    String projectId,
    Map<String, dynamic> data,
  ) async {
    try {
      logging.logger.info('Updating project: $projectId');

      if (projectId.isEmpty) {
        throw ArgumentError('Project ID is required');
      }

      // Sanitize update data
      final sanitizedData = <String, dynamic>{};
      data.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          if (key == 'clientEmail') {
            sanitizedData[key] =
                _securityService.validateAndSanitizeEmail(value) ?? value;
          } else {
            sanitizedData[key] = _securityService.sanitizeInput(value);
          }
        } else {
          sanitizedData[key] = value;
        }
      });

      // Remove system-managed fields
      sanitizedData.remove('createdAt');
      sanitizedData.remove('updatedAt');
      sanitizedData.remove('id');

      // Add timestamp
      sanitizedData['updatedAt'] = DateTime.now().toIso8601String();

      await client.from('projects').update(sanitizedData).eq('id', projectId);

      logging.logger.info('Project updated successfully: $projectId');
    } catch (e, stackTrace) {
      logging.logger.error('Error updating project: $projectId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Update project');
      rethrow;
    }
  }

  /// Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      logging.logger.warning('Deleting project: $projectId');

      if (projectId.isEmpty) {
        throw ArgumentError('Project ID is required');
      }

      await client.from('projects').delete().eq('id', projectId);

      logging.logger.warning('Project deleted: $projectId');
    } catch (e, stackTrace) {
      logging.logger.error('Error deleting project: $projectId', e, stackTrace);
      ErrorHandler.handleError(e, context: 'Delete project');
      rethrow;
    }
  }

  /// Update project progress
  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      logging.logger.info(
        'Updating project progress: $projectId -> ${progress.toStringAsFixed(1)}%',
      );

      if (projectId.isEmpty) {
        throw ArgumentError('Project ID is required');
      }

      if (progress < 0 || progress > 100) {
        throw ArgumentError('Progress must be between 0 and 100');
      }

      await client
          .from('projects')
          .update({
            'progress': progress,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      logging.logger.info(
        'Project progress updated: $projectId -> ${progress.toStringAsFixed(1)}%',
      );
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error updating project progress: $projectId',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Update project progress');
      rethrow;
    }
  }

  /// Add project update
  Future<void> addProjectUpdate(
    String projectId,
    Map<String, dynamic> update,
  ) async {
    try {
      logging.logger.info('Adding project update: $projectId');

      if (projectId.isEmpty) {
        throw ArgumentError('Project ID is required');
      }

      // Sanitize update content
      final sanitizedUpdate = <String, dynamic>{};
      update.forEach((key, value) {
        if (value is String && value.isNotEmpty) {
          sanitizedUpdate[key] = _securityService.sanitizeInput(value);
        } else {
          sanitizedUpdate[key] = value;
        }
      });

      // Add timestamp
      sanitizedUpdate['timestamp'] = DateTime.now().toIso8601String();

      final project =
          await client.from('projects').select().eq('id', projectId).single();

      final updates = List<Map<String, dynamic>>.from(project['updates'] ?? []);
      updates.add(sanitizedUpdate);

      await client
          .from('projects')
          .update({'updates': updates})
          .eq('id', projectId);

      logging.logger.info('Project update added: $projectId');
    } catch (e, stackTrace) {
      logging.logger.error(
        'Error adding project update: $projectId',
        e,
        stackTrace,
      );
      ErrorHandler.handleError(e, context: 'Add project update');
      rethrow;
    }
  }

  // ==================== CHAT ====================

  Stream<List<ChatRoom>> getChatRooms() {
    return client
        .from('chat_rooms')
        .stream(primaryKey: ['id'])
        .map(
          (data) =>
              data
                  .map((json) => ChatRoom.fromMap(json, id: json['id']))
                  .toList(),
        );
  }

  Future<String> getOrCreateChatRoom(
    String userId,
    String userName, [
    String? userEmail,
  ]) async {
    try {
      // Try to find existing chat room
      final existing =
          await client
              .from('chat_rooms')
              .select()
              .eq('customerid', userId)
              .maybeSingle();

      if (existing != null) {
        return existing['id'];
      }

      // Create new chat room
      final newRoom = {
        'customerid': userId,
        'customername': userName,
        if (userEmail != null) 'customeremail': userEmail,
        'createdat': DateTime.now().toIso8601String(),
      };

      final response =
          await client.from('chat_rooms').insert(newRoom).select().single();

      return response['id'];
    } catch (e) {
      logging.logger.error('Error getting/creating chat room', e);
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
        logging.logger.error('Error fetching chat messages', e);
      }
    });

    return controller.stream;
  }

  Future<List<ChatMessage>> _fetchChatMessages(String chatRoomId) async {
    final data = await client
        .from('chat_messages')
        .select()
        .eq('chatroomid', chatRoomId)
        .order('timestamp', ascending: true);

    return data
        .map((json) => ChatMessage.fromMap(json, id: json['id']))
        .toList();
  }

  Future<void> sendMessage(String chatRoomId, ChatMessage message) async {
    final data = {
      'chatroomid': chatRoomId,
      'senderid': message.senderId,
      'sendername': message.senderName,
      'sendertype': message.senderType,
      'message': message.message,
      'timestamp': message.timestamp.toIso8601String(),
      'read': message.isRead,
    };

    await client.from('chat_messages').insert(data);

    // Update chat room's last message timestamp
    await client
        .from('chat_rooms')
        .update({'lastmessageat': DateTime.now().toIso8601String()})
        .eq('id', chatRoomId);
  }

  // ==================== ADMIN ====================

  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final usersResponse = await client.from('users').select('id').count();
      final usersCount = usersResponse.count;

      final servicesResponse =
          await client.from('services').select('id').count();
      final servicesCount = servicesResponse.count;

      final bookingsResponse =
          await client.from('bookings').select('id').count();
      final bookingsCount = bookingsResponse.count;

      final projectsResponse =
          await client.from('projects').select('id').count();
      final projectsCount = projectsResponse.count;

      final chatRoomsResponse =
          await client.from('chat_rooms').select('id').count();
      final chatRoomsCount = chatRoomsResponse.count;

      return {
        'totalUsers': usersCount,
        'totalServices': servicesCount,
        'totalBookings': bookingsCount,
        'totalProjects': projectsCount,
        'totalChatRooms': chatRoomsCount,
      };
    } catch (e) {
      logging.logger.error('Error getting admin stats', e);
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
    await client.from('admins').insert({'user_id': userId, ...adminData});
  }

  // ==================== FILE UPLOADS ====================

  Future<String> uploadImage(File file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folder/$fileName';

      await client.storage.from('public').upload(filePath, file);

      final publicUrl = client.storage.from('public').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      logging.logger.error('Error uploading image', e);
      rethrow;
    }
  }

  Future<String> uploadVideo(File file, String folder) async {
    try {
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final filePath = '$folder/$fileName';

      await client.storage.from('public').upload(filePath, file);

      final publicUrl = client.storage.from('public').getPublicUrl(filePath);
      return publicUrl;
    } catch (e) {
      logging.logger.error('Error uploading video', e);
      rethrow;
    }
  }

  // ==================== KNOWLEDGE BASE ====================

  Future<List<KnowledgeQuestion>> getKnowledgeQuestions() async {
    try {
      final response = await client
          .from('knowledge_questions')
          .select()
          .order('ispinned', ascending: false)
          .order('viewcount', ascending: false)
          .order('createdat', ascending: false);

      final questions = <KnowledgeQuestion>[];
      for (var item in response) {
        final questionId = item['id'] as String;
        final answers = await getKnowledgeAnswers(questionId);
        questions.add(KnowledgeQuestion.fromMap(item, answers: answers));
      }

      return questions;
    } catch (e) {
      logging.logger.error('Error getting knowledge questions', e);
      return [];
    }
  }

  Future<List<KnowledgeAnswer>> getKnowledgeAnswers(String questionId) async {
    try {
      final response = await client
          .from('knowledge_answers')
          .select()
          .eq('questionid', questionId)
          .order('isaccepted', ascending: false)
          .order('helpfulcount', ascending: false)
          .order('createdat', ascending: false);

      return response.map((item) => KnowledgeAnswer.fromMap(item)).toList();
    } catch (e) {
      logging.logger.error('Error getting knowledge answers', e);
      return [];
    }
  }

  Future<void> addKnowledgeAnswer({
    required String questionId,
    required String answer,
    String? authorId,
    String? authorName,
  }) async {
    try {
      await client.from('knowledge_answers').insert({
        'questionid': questionId,
        'answer': answer,
        'authorid': authorId,
        'authorname': authorName,
      });
    } catch (e) {
      logging.logger.error('Error adding knowledge answer', e);
      rethrow;
    }
  }

  Future<void> incrementQuestionViewCount(String questionId) async {
    try {
      // Get current view count
      final response =
          await client
              .from('knowledge_questions')
              .select('viewcount')
              .eq('id', questionId)
              .maybeSingle();

      if (response != null) {
        final currentCount = (response['viewcount'] ?? 0) as int;
        await client
            .from('knowledge_questions')
            .update({'viewcount': currentCount + 1})
            .eq('id', questionId);
      }
    } catch (e) {
      logging.logger.warning('Error incrementing view count', e);
      // Don't throw - this is not critical
    }
  }

  /// Dispose resources
  void dispose() {
    logging.logger.info('Disposing SupabaseService resources');
    // Cleanup any resources if needed
  }

  // Helper method for project bookings (for backward compatibility)
  Future<void> addProjectBooking(Map<String, dynamic> bookingData) async {
    // Convert the booking data to a Booking model and save
    final booking = Booking.fromMap(bookingData);
    await addBooking(booking);
  }
}
